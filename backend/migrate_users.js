/**
 * migrate_users.js
 * สร้างตาราง users ใน database japan_travel ที่มีอยู่แล้ว
 * รันด้วย: node migrate_users.js
 */
const pool = require("./db");

async function migrate() {
  try {
    console.log("🔄 กำลังสร้างตาราง users...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id            INT AUTO_INCREMENT PRIMARY KEY,
        username      VARCHAR(100) NOT NULL UNIQUE,
        email         VARCHAR(200) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log("✅ สร้างตาราง users สำเร็จ!");

    // แสดงโครงสร้างตาราง
    const [rows] = await pool.query("DESCRIBE users");
    console.log("\nโครงสร้างตาราง users:");
    console.table(rows);
  } catch (err) {
    console.error("❌ Error:", err.message);
  } finally {
    await pool.end();
  }
}

migrate();
