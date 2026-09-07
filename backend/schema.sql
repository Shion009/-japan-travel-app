-- สร้าง database
CREATE DATABASE IF NOT EXISTS japan_travel
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE japan_travel;

-- ตาราง regions
CREATE TABLE IF NOT EXISTS regions (
  id      VARCHAR(50)  PRIMARY KEY,
  th      VARCHAR(100) NOT NULL,
  jp      VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ตาราง categories
CREATE TABLE IF NOT EXISTS categories (
  id      VARCHAR(50)  PRIMARY KEY,
  th      VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ตาราง spots
CREATE TABLE IF NOT EXISTS spots (
  id                   VARCHAR(50)   PRIMARY KEY,
  name                 VARCHAR(200)  NOT NULL,
  name_jp              VARCHAR(200)  NOT NULL,
  region               VARCHAR(50)   NOT NULL,
  category             VARCHAR(50)   NOT NULL,
  season               VARCHAR(100)  NOT NULL,
  blurb                TEXT          NOT NULL,
  detail               TEXT          NOT NULL,
  highlight            TEXT          NOT NULL,
  image_url            TEXT,
  opening_hours        VARCHAR(255),
  fee                  VARCHAR(255),
  address              TEXT,
  access               TEXT,
  recommended_duration VARCHAR(100),
  best_time            VARCHAR(255),
  tips                 TEXT,
  activities           JSON,
  rating               DECIMAL(2, 1) DEFAULT 4.7,
  coordinates          VARCHAR(100),
  seasonal_advice      TEXT,
  FOREIGN KEY (region)   REFERENCES regions(id),
  FOREIGN KEY (category) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ตาราง users (สำหรับระบบ login/register)
CREATE TABLE IF NOT EXISTS users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(100) NOT NULL UNIQUE,
  email         VARCHAR(200) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
