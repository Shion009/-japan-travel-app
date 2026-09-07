const path    = require("path");
const fs      = require("fs");
const express = require("express");
const cors    = require("cors");
const multer  = require("multer");
const bcrypt  = require("bcryptjs");
const jwt     = require("jsonwebtoken");
const pool    = require("./db");

const app  = express();
const PORT = process.env.PORT || 4000;

const ADMIN_KEY  = process.env.ADMIN_KEY  || "changeme123";
const JWT_SECRET = process.env.JWT_SECRET || "jwt_secret_japan_travel_2024";
const JWT_EXPIRE = process.env.JWT_EXPIRE || "7d";

const UPLOAD_DIR = path.join(__dirname, "uploads");
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename:    (req, file, cb) => {
    const ext = path.extname(file.originalname) || ".jpg";
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (/^image\/(jpeg|png|webp|gif)$/.test(file.mimetype)) cb(null, true);
    else cb(new Error("รองรับเฉพาะไฟล์รูปภาพ (jpg, png, webp, gif)"));
  },
});

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(UPLOAD_DIR));
app.use("/admin",   express.static(path.join(__dirname, "public", "admin")));

// ---------- Helpers ----------

function requireAdmin(req, res, next) {
  const key = req.header("x-admin-key") || req.query["x-admin-key"];
  if (key !== ADMIN_KEY)
    return res.status(401).json({ error: "unauthorized: ต้องใส่ x-admin-key ให้ถูกต้อง" });
  next();
}

function requireAuth(req, res, next) {
  const authHeader = req.header("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer "))
    return res.status(401).json({ error: "unauthorized: ต้องใส่ Bearer token" });
  const token = authHeader.slice(7);
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ error: "unauthorized: token ไม่ถูกต้องหรือหมดอายุ" });
  }
}

function absoluteUrl(req, relativePath) {
  if (!relativePath) return null;
  if (/^https?:\/\//i.test(relativePath)) return relativePath;
  return `${req.protocol}://${req.get("host")}${relativePath}`;
}

/** แปลง row จาก DB (snake_case) → JSON ที่ Flutter คาดหวัง (camelCase) */
function serializeSpot(req, row) {
  let activities = null;
  if (row.activities) {
    try {
      activities = typeof row.activities === "string" ? JSON.parse(row.activities) : row.activities;
    } catch {
      activities = null;
    }
  }

  return {
    id:                  row.id,
    name:                row.name,
    nameJp:              row.name_jp || row.nameJp,
    region:              row.region,
    category:            row.category,
    season:              row.season,
    blurb:               row.blurb,
    detail:              row.detail,
    highlight:           row.highlight,
    imageUrl:            absoluteUrl(req, row.image_url || row.imageUrl),
    openingHours:        row.opening_hours || row.openingHours || null,
    fee:                 row.fee || null,
    address:             row.address || null,
    access:              row.access || null,
    recommendedDuration: row.recommended_duration || row.recommendedDuration || null,
    bestTime:            row.best_time || row.bestTime || null,
    tips:                row.tips || null,
    activities:          activities || (Array.isArray(row.activities) ? row.activities : null),
    rating:              row.rating ? Number(row.rating) : null,
    coordinates:         row.coordinates || null,
    seasonalAdvice:      row.seasonal_advice || row.seasonalAdvice || null,
  };
}

// ---------- Health ----------

app.get("/api/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ ok: true, db: "mysql" });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ---------- Seed (ใช้ครั้งเดียวสำหรับ import ข้อมูลลง cloud DB) ----------

app.post("/api/admin/seed", requireAdmin, async (req, res) => {
  try {
    const sqlFile = path.join(__dirname, "init.sql");
    if (!fs.existsSync(sqlFile)) {
      return res.status(404).json({ error: "init.sql not found" });
    }

    const raw = fs.readFileSync(sqlFile, "utf8");

    // แยก statements ตาม ; และกรองออก
    const statements = raw
      .split(";")
      .map((s) => s.trim())
      .filter((s) => s.length > 0 && !s.startsWith("--"));

    const results = { ok: 0, skipped: 0, errors: [] };

    for (const stmt of statements) {
      try {
        await pool.query(stmt);
        results.ok++;
      } catch (e) {
        if (e.code === "ER_DUP_ENTRY" || e.code === "ER_TABLE_EXISTS_ERROR") {
          results.skipped++;
        } else {
          results.errors.push({ stmt: stmt.slice(0, 80), error: e.message });
        }
      }
    }

    const [spotCount] = await pool.query("SELECT COUNT(*) as cnt FROM spots");
    const [userCount] = await pool.query("SELECT COUNT(*) as cnt FROM users");

    res.json({
      message: "Seed เสร็จสิ้น!",
      statements: results.ok,
      skipped: results.skipped,
      errors: results.errors,
      db: { spots: spotCount[0].cnt, users: userCount[0].cnt },
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


/** แปลงลิงก์แชร์ เช่น Google Drive หรือ Dropbox ให้เป็น Direct Image URL อัตโนมัติ */
function normalizeImageUrl(url) {
  if (!url || typeof url !== "string") return url;
  const trimmed = url.trim();

  // Google Drive: /file/d/ID/... หรือ ?id=ID
  const driveMatch = trimmed.match(/drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)/) ||
                     trimmed.match(/drive\.google\.com\/open\?id=([a-zA-Z0-9_-]+)/);
  if (driveMatch) {
    return `https://lh3.googleusercontent.com/d/${driveMatch[1]}`;
  }

  // Dropbox: dl=0 -> raw=1
  if (trimmed.includes("dropbox.com") && trimmed.includes("dl=0")) {
    return trimmed.replace("dl=0", "raw=1");
  }

  return trimmed;
}

/** Proxy รูปภาพเพื่อแก้ปัญหา CORS และ Hotlink Protection บนเว็บ */
app.get("/api/proxy-image", async (req, res) => {
  const targetUrl = req.query.url;
  if (!targetUrl) return res.status(400).send("Missing url parameter");

  try {
    const parsed = new URL(targetUrl);
    if (!["http:", "https:"].includes(parsed.protocol)) {
      return res.status(400).send("Invalid protocol");
    }

    const response = await fetch(targetUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "Accept": "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
      },
    });

    if (!response.ok) {
      return res.status(response.status).send(`Failed to fetch image: ${response.statusText}`);
    }

    const contentType = response.headers.get("content-type") || "image/jpeg";
    res.setHeader("Content-Type", contentType);
    res.setHeader("Cache-Control", "public, max-age=86400");
    res.setHeader("Access-Control-Allow-Origin", "*");

    const arrayBuffer = await response.arrayBuffer();
    res.send(Buffer.from(arrayBuffer));
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// ---------- Auth endpoints ----------

/** POST /api/auth/register */
app.post("/api/auth/register", async (req, res) => {
  try {
    const { username, email, password } = req.body || {};
    if (!username || !email || !password)
      return res.status(400).json({ error: "ต้องระบุ username, email และ password" });
    if (password.length < 6)
      return res.status(400).json({ error: "password ต้องมีอย่างน้อย 6 ตัวอักษร" });

    // ตรวจสอบว่า email หรือ username ซ้ำ
    const [existing] = await pool.query(
      "SELECT id FROM users WHERE email = ? OR username = ?",
      [email.trim().toLowerCase(), username.trim()]
    );
    if (existing.length)
      return res.status(409).json({ error: "email หรือ username นี้ถูกใช้งานแล้ว" });

    const password_hash = await bcrypt.hash(password, 12);
    const [result] = await pool.query(
      "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)",
      [username.trim(), email.trim().toLowerCase(), password_hash]
    );

    const user = { id: result.insertId, username: username.trim(), email: email.trim().toLowerCase() };
    const token = jwt.sign(user, JWT_SECRET, { expiresIn: JWT_EXPIRE });
    res.status(201).json({ token, user });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** POST /api/auth/login */
app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body || {};
    if (!email || !password)
      return res.status(400).json({ error: "ต้องระบุ email และ password" });

    const [rows] = await pool.query(
      "SELECT * FROM users WHERE email = ?",
      [email.trim().toLowerCase()]
    );
    if (!rows.length)
      return res.status(401).json({ error: "email หรือ password ไม่ถูกต้อง" });

    const dbUser = rows[0];
    const valid  = await bcrypt.compare(password, dbUser.password_hash);
    if (!valid)
      return res.status(401).json({ error: "email หรือ password ไม่ถูกต้อง" });

    const user  = { id: dbUser.id, username: dbUser.username, email: dbUser.email };
    const token = jwt.sign(user, JWT_SECRET, { expiresIn: JWT_EXPIRE });
    res.json({ token, user });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** GET /api/auth/me — ต้องมี Bearer token */
app.get("/api/auth/me", requireAuth, async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, username, email, created_at FROM users WHERE id = ?",
      [req.user.id]
    );
    if (!rows.length) return res.status(404).json({ error: "ไม่พบผู้ใช้" });
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- Database viewer (admin only) ----------

app.get("/api/db", requireAdmin, async (req, res) => {
  try {
    const [regions]    = await pool.query("SELECT * FROM regions");
    const [categories] = await pool.query("SELECT * FROM categories");
    const [spots]      = await pool.query("SELECT * FROM spots");
    let users = [];
    try {
      const [userRows] = await pool.query("SELECT id, username, email, created_at FROM users");
      users = userRows;
    } catch {
      // ตาราง users อาจจะยังไม่ได้ migrate
    }
    res.json({ regions, categories, spots, users });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/db/download", requireAdmin, async (req, res) => {
  try {
    const [regions]    = await pool.query("SELECT * FROM regions");
    const [categories] = await pool.query("SELECT * FROM categories");
    const [spots]      = await pool.query("SELECT * FROM spots");
    let users = [];
    try {
      const [userRows] = await pool.query("SELECT id, username, email, created_at FROM users");
      users = userRows;
    } catch {
      // ตาราง users อาจจะยังไม่ได้ migrate
    }
    const json = JSON.stringify({ regions, categories, spots, users }, null, 2);
    res.setHeader("Content-Disposition", "attachment; filename=db.json");
    res.setHeader("Content-Type", "application/json");
    res.send(json);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- Public read endpoints ----------

app.get("/api/regions", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT id, th, jp FROM regions ORDER BY id");
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/categories", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT id, th FROM categories ORDER BY id");
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/spots", async (req, res) => {
  try {
    const { region, category, search } = req.query;
    let sql    = "SELECT * FROM spots WHERE 1=1";
    const params = [];

    if (region)   { sql += " AND region = ?";   params.push(region); }
    if (category) { sql += " AND category = ?"; params.push(category); }
    if (search) {
      const q = `%${String(search).trim()}%`;
      sql += " AND (name LIKE ? OR name_jp LIKE ? OR blurb LIKE ?)";
      params.push(q, q, q);
    }

    sql += " ORDER BY CAST(id AS UNSIGNED)";

    const [rows] = await pool.query(sql, params);
    res.json(rows.map((r) => serializeSpot(req, r)));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/api/spots/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM spots WHERE id = ?", [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: "ไม่พบสถานที่นี้" });
    res.json(serializeSpot(req, rows[0]));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- Admin write endpoints ----------

app.post("/api/spots", requireAdmin, upload.single("image"), async (req, res) => {
  try {
    const body     = req.body || {};
    const required = ["name", "nameJp", "region", "category", "season", "blurb", "detail", "highlight"];
    for (const f of required)
      if (!body[f]) return res.status(400).json({ error: `ต้องระบุ ${f}` });

    const id       = String(Date.now());
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : (body.imageUrl ? normalizeImageUrl(body.imageUrl) : null);

    await pool.query(
      `INSERT INTO spots (
        id, name, name_jp, region, category, season, blurb, detail, highlight, image_url,
        opening_hours, fee, address, access, recommended_duration, best_time, tips, rating, coordinates, seasonal_advice
       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, body.name, body.nameJp, body.region, body.category,
        body.season, body.blurb, body.detail, body.highlight, imageUrl,
        body.openingHours || null, body.fee || null, body.address || null, body.access || null,
        body.recommendedDuration || null, body.bestTime || null, body.tips || null,
        body.rating ? Number(body.rating) : 4.7, body.coordinates || null, body.seasonalAdvice || null
      ]
    );

    const [rows] = await pool.query("SELECT * FROM spots WHERE id = ?", [id]);
    res.status(201).json(serializeSpot(req, rows[0]));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put("/api/spots/:id", requireAdmin, upload.single("image"), async (req, res) => {
  try {
    const [existing] = await pool.query("SELECT * FROM spots WHERE id = ?", [req.params.id]);
    if (!existing.length) return res.status(404).json({ error: "ไม่พบสถานที่นี้" });

    const body     = req.body || {};
    const old      = existing[0];
    const imageUrl = req.file
      ? `/uploads/${req.file.filename}`
      : (body.imageUrl ? normalizeImageUrl(body.imageUrl) : old.image_url);

    // ลบรูปเก่าถ้า upload ใหม่
    if (req.file && old.image_url && old.image_url.startsWith("/uploads/")) {
      fs.unlink(path.join(__dirname, old.image_url), () => {});
    }

    await pool.query(
      `UPDATE spots SET
         name=?, name_jp=?, region=?, category=?, season=?,
         blurb=?, detail=?, highlight=?, image_url=?,
         opening_hours=?, fee=?, address=?, access=?,
         recommended_duration=?, best_time=?, tips=?,
         rating=?, coordinates=?, seasonal_advice=?
       WHERE id=?`,
      [
        body.name                || old.name,
        body.nameJp              || old.name_jp,
        body.region              || old.region,
        body.category            || old.category,
        body.season              || old.season,
        body.blurb               || old.blurb,
        body.detail              || old.detail,
        body.highlight           || old.highlight,
        imageUrl,
        body.openingHours        !== undefined ? body.openingHours        : old.opening_hours,
        body.fee                 !== undefined ? body.fee                 : old.fee,
        body.address             !== undefined ? body.address             : old.address,
        body.access              !== undefined ? body.access              : old.access,
        body.recommendedDuration !== undefined ? body.recommendedDuration : old.recommended_duration,
        body.bestTime            !== undefined ? body.bestTime            : old.best_time,
        body.tips                !== undefined ? body.tips                : old.tips,
        body.rating              !== undefined ? Number(body.rating)      : old.rating,
        body.coordinates         !== undefined ? body.coordinates         : old.coordinates,
        body.seasonalAdvice      !== undefined ? body.seasonalAdvice      : old.seasonal_advice,
        req.params.id,
      ]
    );

    const [rows] = await pool.query("SELECT * FROM spots WHERE id = ?", [req.params.id]);
    res.json(serializeSpot(req, rows[0]));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete("/api/spots/:id", requireAdmin, async (req, res) => {
  try {
    const [existing] = await pool.query("SELECT image_url FROM spots WHERE id = ?", [req.params.id]);
    if (!existing.length) return res.status(404).json({ error: "ไม่พบสถานที่นี้" });

    const imageUrl = existing[0].image_url;
    await pool.query("DELETE FROM spots WHERE id = ?", [req.params.id]);

    if (imageUrl && imageUrl.startsWith("/uploads/"))
      fs.unlink(path.join(__dirname, imageUrl), () => {});

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- Admin User Management Endpoints ----------

/** GET /api/admin/users */
app.get("/api/admin/users", requireAdmin, async (req, res) => {
  try {
    const { search } = req.query;
    let sql = "SELECT id, username, email, created_at FROM users WHERE 1=1";
    const params = [];

    if (search) {
      const q = `%${String(search).trim()}%`;
      sql += " AND (username LIKE ? OR email LIKE ?)";
      params.push(q, q);
    }

    sql += " ORDER BY id DESC";

    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** POST /api/admin/users */
app.post("/api/admin/users", requireAdmin, async (req, res) => {
  try {
    const { username, email, password } = req.body || {};
    if (!username || !email || !password) {
      return res.status(400).json({ error: "ต้องระบุ username, email และ password" });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: "password ต้องมีอย่างน้อย 6 ตัวอักษร" });
    }

    const [existing] = await pool.query(
      "SELECT id FROM users WHERE email = ? OR username = ?",
      [email.trim().toLowerCase(), username.trim()]
    );
    if (existing.length) {
      return res.status(409).json({ error: "email หรือ username นี้ถูกใช้งานแล้ว" });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const [result] = await pool.query(
      "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)",
      [username.trim(), email.trim().toLowerCase(), password_hash]
    );

    const [newUser] = await pool.query(
      "SELECT id, username, email, created_at FROM users WHERE id = ?",
      [result.insertId]
    );
    res.status(201).json(newUser[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** PUT /api/admin/users/:id */
app.put("/api/admin/users/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email, password } = req.body || {};

    if (!username || !email) {
      return res.status(400).json({ error: "ต้องระบุ username และ email" });
    }

    const [existing] = await pool.query("SELECT * FROM users WHERE id = ?", [id]);
    if (!existing.length) {
      return res.status(404).json({ error: "ไม่พบผู้ใช้นี้" });
    }

    // ตรวจสอบ username / email ซ้ำกับคนอื่น
    const [duplicate] = await pool.query(
      "SELECT id FROM users WHERE (email = ? OR username = ?) AND id != ?",
      [email.trim().toLowerCase(), username.trim(), id]
    );
    if (duplicate.length) {
      return res.status(409).json({ error: "email หรือ username นี้ถูกใช้งานโดยผู้ใช้อื่นแล้ว" });
    }

    if (password) {
      if (password.length < 6) {
        return res.status(400).json({ error: "password ต้องมีอย่างน้อย 6 ตัวอักษร" });
      }
      const password_hash = await bcrypt.hash(password, 12);
      await pool.query(
        "UPDATE users SET username = ?, email = ?, password_hash = ? WHERE id = ?",
        [username.trim(), email.trim().toLowerCase(), password_hash, id]
      );
    } else {
      await pool.query(
        "UPDATE users SET username = ?, email = ? WHERE id = ?",
        [username.trim(), email.trim().toLowerCase(), id]
      );
    }

    const [updated] = await pool.query(
      "SELECT id, username, email, created_at FROM users WHERE id = ?",
      [id]
    );
    res.json(updated[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** DELETE /api/admin/users/:id */
app.delete("/api/admin/users/:id", requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const [existing] = await pool.query("SELECT id FROM users WHERE id = ?", [id]);
    if (!existing.length) {
      return res.status(404).json({ error: "ไม่พบผู้ใช้นี้" });
    }

    await pool.query("DELETE FROM users WHERE id = ?", [id]);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- Error handler ----------
app.use((err, req, res, next) => {
  if (err) return res.status(400).json({ error: err.message });
  next();
});

app.listen(PORT, () => {
  console.log(`Japan travel API running on http://localhost:${PORT}`);
  console.log(`Admin panel: http://localhost:${PORT}/admin`);
  console.log(`Database: MySQL → japan_travel`);
});
