# เที่ยวญี่ปุ่น — Japan Travel Guide

โปรเจกต์เต็มระบบ 3 ส่วน:

```
japan-travel-app/
├── backend/        Node.js + Express REST API (+ ไฟล์ static admin panel)
└── flutter_app/     Flutter mobile app (Android/iOS) ที่ดึงข้อมูลผ่าน API
```

## 1) Backend API

```bash
cd backend
npm install
npm start
```

รันที่ `http://localhost:4000`

- ข้อมูลเก็บในไฟล์ `backend/data/db.json` (ง่ายต่อการดูและแก้ไขตรง ๆ ได้ ไม่ต้องติดตั้งฐานข้อมูลแยก)
- รูปที่อัปโหลดผ่านแอดมินจะถูกเก็บใน `backend/uploads/` และเสิร์ฟที่ `/uploads/<filename>`
- ค่า `ADMIN_KEY` (default: `changeme123`) ใช้เป็น secret สำหรับ endpoint ที่แก้ไขข้อมูล — **ควรเปลี่ยนก่อนใช้งานจริง** โดยตั้ง environment variable `ADMIN_KEY`

### Endpoints หลัก

| Method | Path                | คำอธิบาย                                   | ต้องใช้ x-admin-key |
|--------|----------------------|---------------------------------------------|:---:|
| GET    | `/api/regions`       | รายชื่อภูมิภาคทั้งหมด                        |  |
| GET    | `/api/categories`    | รายชื่อหมวดหมู่ทั้งหมด                        |  |
| GET    | `/api/spots`         | รายการสถานที่ (query: `region`, `category`, `search`) |  |
| GET    | `/api/spots/:id`     | รายละเอียดสถานที่ 1 รายการ                    |  |
| POST   | `/api/spots`         | เพิ่มสถานที่ใหม่ (multipart: ฟิลด์ข้อมูล + `image` ไฟล์ หรือ `imageUrl`) | ✅ |
| PUT    | `/api/spots/:id`     | แก้ไขสถานที่                                  | ✅ |
| DELETE | `/api/spots/:id`     | ลบสถานที่                                    | ✅ |

## 2) หน้าเว็บแอดมิน (ใส่/แก้ไขข้อมูล + อัปโหลดรูป)

เปิดที่ `http://localhost:4000/admin` หลังรัน backend แล้ว
กรอก **API base** และ **x-admin-key** มุมขวาบน (ค่า default ตรงกับ backend ที่ยังไม่เปลี่ยน key)

ใช้เพิ่ม/แก้ไข/ลบสถานที่ท่องเที่ยว พร้อมอัปโหลดรูปภาพจริงแทนรูป placeholder ที่ seed มาให้

## 3) Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

App จะเรียก API จาก `http://localhost:4000` เป็นค่าเริ่มต้น ปรับได้ตอนรันด้วย:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:4000
```

**หมายเหตุการเชื่อมต่อ:**
- Android emulator → ใช้ `http://10.0.2.2:4000` แทน `localhost`
- iOS simulator / macOS / web / Windows / Linux desktop → `http://localhost:4000` ใช้ได้ตรง ๆ
- เครื่องจริง (มือถือจริง) → ต้องใช้ IP วง LAN ของเครื่องที่รัน backend เช่น `http://192.168.1.10:4000` และมือถือกับคอมต้องอยู่ WiFi วงเดียวกัน

### โครงสร้างแอป

```
lib/
├── main.dart               entry point
├── models/spot.dart         โมเดล Region, SpotCategory, Spot
├── services/api_service.dart  เรียก REST API
├── theme/app_theme.dart     ธีมสี/ฟอนต์ (คอนทราสต์สูง อ่านง่าย)
├── widgets/spot_card.dart   การ์ดแสดงสถานที่ (รูป + gradient scrim กันข้อความจมกับพื้นหลัง)
└── screens/
    ├── home_screen.dart     ค้นหา + กรองภูมิภาค/หมวดหมู่ + กริดสถานที่
    └── detail_screen.dart   หน้ารายละเอียด
```

### ดีไซน์

- โทนสีอิงจากสีญี่ปุ่นดั้งเดิม: น้ำเงินคราม (ai), แดงชาด (shu), กระดาษวาชิ (washi), หมึกดำ (sumi)
- ทุกรูปภาพมี gradient scrim สีเข้มไล่ระดับด้านล่าง เพื่อให้ตัวอักษรสีขาวที่วางทับอ่านออกชัดเจนเสมอ ไม่กลืนกับพื้นหลังไม่ว่ารูปจะสว่างหรือมืด
- ป้ายภูมิภาคบนการ์ดใช้กล่องพื้นขาวทึบ ไม่ใช่ตัวอักษรลอยบนรูปตรง ๆ เพื่อคอนทราสต์ที่แน่นอน

## ขั้นตอนถัดไปที่แนะนำก่อนใช้งานจริง

- เปลี่ยนระบบยืนยันตัวตนแอดมินจาก shared-secret header เป็น JWT/session login จริง
- ย้ายจากไฟล์ JSON ไปเป็นฐานข้อมูล (PostgreSQL/MySQL) หากข้อมูลเพิ่มมากขึ้นหรือมีผู้ใช้พร้อมกันหลายคน
- อัปโหลดรูปไปเก็บบน cloud storage (S3 หรือใกล้เคียง) แทนดิสก์ในเครื่อง server เพื่อความทนทานเมื่อ deploy จริง
- เพิ่ม HTTPS และ rate-limiting ที่ backend ก่อนเปิดใช้งานสาธารณะ
