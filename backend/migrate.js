/**
 * migrate.js
 * นำเข้าข้อมูลจาก data/db.json เข้า MySQL database japan_travel
 * รัน: node migrate.js
 */
const mysql = require("mysql2/promise");
const fs    = require("fs");
const path  = require("path");

const DB_CONFIG = {
  host:     process.env.DB_HOST     || "localhost",
  port:     process.env.DB_PORT     || 3306,
  user:     process.env.DB_USER     || "root",
  password: process.env.DB_PASS     || "",
  multipleStatements: true,
};

async function migrate() {
  const schema  = fs.readFileSync(path.join(__dirname, "schema.sql"), "utf-8");
  const rawDb   = fs.readFileSync(path.join(__dirname, "data", "db.json"), "utf-8");
  const db      = JSON.parse(rawDb);

  console.log("🔌 กำลังเชื่อมต่อ MySQL...");
  const conn = await mysql.createConnection(DB_CONFIG);

  // สร้าง database + ตาราง
  console.log("📐 สร้าง schema...");
  await conn.query(schema);
  await conn.query("USE japan_travel");

  // --- regions ---
  console.log(`📍 นำเข้า ${db.regions.length} ภูมิภาค...`);
  for (const r of db.regions) {
    await conn.query(
      "INSERT INTO regions (id, th, jp) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE th=VALUES(th), jp=VALUES(jp)",
      [r.id, r.th, r.jp]
    );
  }

  // --- categories ---
  console.log(`🏷  นำเข้า ${db.categories.length} หมวดหมู่...`);
  for (const c of db.categories) {
    await conn.query(
      "INSERT INTO categories (id, th) VALUES (?, ?) ON DUPLICATE KEY UPDATE th=VALUES(th)",
      [c.id, c.th]
    );
  }

  // --- spots ---
  console.log(`📌 นำเข้า ${db.spots.length} สถานที่...`);
  for (const s of db.spots) {
    await conn.query(
      `INSERT INTO spots (id, name, name_jp, region, category, season, blurb, detail, highlight, image_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         name=VALUES(name), name_jp=VALUES(name_jp), region=VALUES(region),
         category=VALUES(category), season=VALUES(season), blurb=VALUES(blurb),
         detail=VALUES(detail), highlight=VALUES(highlight), image_url=VALUES(image_url)`,
      [s.id, s.name, s.nameJp, s.region, s.category, s.season, s.blurb, s.detail, s.highlight, s.imageUrl || null]
    );
  }

  await conn.end();

  console.log("\n✅ Migration สำเร็จ!");
  console.log(`   regions   : ${db.regions.length} rows`);
  console.log(`   categories: ${db.categories.length} rows`);
  console.log(`   spots     : ${db.spots.length} rows`);
  console.log("\n🔗 เชื่อมต่อผ่าน phpMyAdmin: http://localhost/phpmyadmin → japan_travel");
}

migrate().catch((err) => {
  console.error("❌ Migration ล้มเหลว:", err.message);
  process.exit(1);
});
