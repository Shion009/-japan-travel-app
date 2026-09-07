-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: japan_travel
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `japan_travel`
--

/*!40000 DROP DATABASE IF EXISTS `japan_travel`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `japan_travel` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `japan_travel`;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `th` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES ('castle','ปราสาท'),('city','ย่านเมือง'),('garden','สวน'),('island','เกาะ-ชายหาด'),('nature','ธรรมชาติ'),('onsen','ออนเซ็น'),('shrine','วัด-ศาลเจ้า');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `th` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jp` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regions`
--

LOCK TABLES `regions` WRITE;
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
INSERT INTO `regions` VALUES ('chubu','ชูบุ','中部'),('chugoku','ชูโกคุ','中国'),('hokkaido','ฮอกไกโด','北海道'),('kansai','คันไซ','関西'),('kanto','คันโต','関東'),('kyushu','คิวชู','九州'),('okinawa','โอกินาว่า','沖縄'),('shikoku','ชิโกกุ','四国'),('tohoku','โทโฮคุ','東北');
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spots`
--

DROP TABLE IF EXISTS `spots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spots` (
  `id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_jp` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `region` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `season` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `blurb` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `detail` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `highlight` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `region` (`region`),
  KEY `category` (`category`),
  CONSTRAINT `spots_ibfk_1` FOREIGN KEY (`region`) REFERENCES `regions` (`id`),
  CONSTRAINT `spots_ibfk_2` FOREIGN KEY (`category`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spots`
--

LOCK TABLES `spots` WRITE;
/*!40000 ALTER TABLE `spots` DISABLE KEYS */;
INSERT INTO `spots` VALUES ('1','ศาลเจ้าฟูชิมิอินาริ','伏見稲荷大社','kansai','shrine','ตลอดปี','อุโมงค์เสาโทริอิสีแดงนับพันต้นทอดยาวขึ้นเขา','ตั้งอยู่ที่เกียวโต เป็นศาลเจ้าที่มีเสาโทริอิสีแดงเรียงต่อกันหลายพันต้นทอดยาวขึ้นไปตามไหล่เขาอินาริ ผู้คนนิยมเดินลอดอุโมงค์เสาเพื่อขอพรเรื่องการค้าขายและความอุดมสมบูรณ์','อุโมงค์เสาโทริอิที่มีชื่อเสียงที่สุดของญี่ปุ่น','https://placehold.co/900x700/1a1a2e/ffffff?text=ศาลเจ้าฟูชิมิอินาริ'),('10','ฮาโกเน่','箱根','kanto','onsen','ฤดูหนาว','เมืองออนเซ็นเชิงเขาฟูจิ ล่องเรือทะเลสาบอาชิ','เมืองตากอากาศริมภูเขาไฟฟูจิ ขึ้นชื่อเรื่องบ่อน้ำพุร้อนธรรมชาติและทิวทัศน์ภูเขาไฟฟูจิที่มองเห็นได้จากทะเลสาบอาชิในวันฟ้าใส','จุดชมภูเขาไฟฟูจิที่สวยที่สุดแห่งหนึ่งใกล้โตเกียว','https://placehold.co/900x700/1a1a2e/ffffff?text=ฮาโกเน่'),('11','หมู่บ้านชิราคาวาโกะ','白川郷','chubu','nature','ฤดูหนาว','หมู่บ้านหลังคาฟางทรงกัสโชกลางหุบเขาหิมะ','หมู่บ้านมรดกโลกที่ยังคงบ้านโบราณทรงหลังคาฟางแบบกัสโช-สึคุริ ซึ่งออกแบบให้ลาดชันเพื่อรับหิมะหนัก','หลังคาฟางทรงกัสโชอายุกว่า 250 ปี','https://placehold.co/900x700/1a1a2e/ffffff?text=หมู่บ้านชิราคาวาโกะ'),('12','เมืองเก่าทาคายามะ','高山','chubu','city','ฤดูใบไม้ร่วง','ย่านเมืองเก่าสไตล์เอโดะ ตลาดเช้าริมแม่น้ำ','เมืองเล็กในเทือกเขาแอลป์ญี่ปุ่นที่ยังคงบรรยากาศย่านการค้าสมัยเอโดะไว้ครบถ้วน มีตลาดเช้าริมแม่น้ำมิยากาวะทุกวัน','ย่านเมืองเก่าที่ได้รับการอนุรักษ์สมบูรณ์ที่สุดแห่งหนึ่ง','https://placehold.co/900x700/1a1a2e/ffffff?text=เมืองเก่าทาคายามะ'),('13','สวนเค็นโรคุเอ็น','兼六園','chubu','garden','ฤดูหนาว','หนึ่งในสามสวนภูมิทัศน์ที่สวยที่สุดของญี่ปุ่น','สวนภูมิทัศน์เก่าแก่ที่เมืองคานาซาวะ ฤดูหนาวมีการผูกเชือกค้ำกิ่งสนป้องกันหิมะที่เรียกว่ายูกิสึริ ซึ่งกลายเป็นจุดถ่ายภาพขึ้นชื่อ','เทคนิคยูกิสึริผูกเชือกค้ำกิ่งไม้ป้องกันหิมะ','https://placehold.co/900x700/1a1a2e/ffffff?text=สวนเค็นโรคุเอ็น'),('14','ภูเขาไฟฟูจิ','富士山','chubu','nature','ฤดูร้อน','ภูเขาศักดิ์สิทธิ์และสัญลักษณ์ของญี่ปุ่น','ภูเขาไฟที่สูงที่สุดในญี่ปุ่นและเป็นสัญลักษณ์ประจำชาติ เปิดให้นักท่องเที่ยวปีนขึ้นยอดได้เฉพาะช่วงต้นเดือนกรกฎาคมถึงต้นเดือนกันยายน','ภูเขาที่สูงที่สุดในญี่ปุ่น 3,776 เมตร','https://placehold.co/900x700/1a1a2e/ffffff?text=ภูเขาไฟฟูจิ'),('15','เกาะมิยาจิมะ','宮島','chugoku','island','ตลอดปี','โทริอิลอยน้ำแห่งศาลเจ้าอิสึคุชิมะ','เกาะเล็กในทะเลเซโตะที่มีศาลเจ้าอิสึคุชิมะและเสาโทริอิสีแดงขนาดใหญ่ตั้งอยู่กลางน้ำ เมื่อน้ำขึ้นเสาโทริอิดูเหมือนลอยอยู่กลางทะเล','เสาโทริอิลอยน้ำหนึ่งในสามทิวทัศน์งดงามของญี่ปุ่น','https://placehold.co/900x700/1a1a2e/ffffff?text=เกาะมิยาจิมะ'),('16','สวนสันติภาพฮิโรชิม่า','平和記念公園','chugoku','garden','ตลอดปี','อนุสรณ์สถานสันติภาพและโดมเก็นบาคุ','สวนอนุสรณ์ที่สร้างขึ้นเพื่อรำลึกถึงเหตุการณ์ระเบิดปรมาณูปี 1945 ภายในมีอาคารโดมเก็นบาคุที่หลงเหลือจากเหตุการณ์และพิพิธภัณฑ์อนุสรณ์สันติภาพ','โดมเก็นบาคุ อาคารประวัติศาสตร์ที่ได้รับการอนุรักษ์ไว้','https://placehold.co/900x700/1a1a2e/ffffff?text=สวนสันติภาพฮิโรชิม่า'),('17','ปราสาทคุมาโมโตะ','熊本城','kyushu','castle','ฤดูใบไม้ผลิ','ปราสาทดำสง่างามหนึ่งในสามปราสาทเอกของญี่ปุ่น','หนึ่งในสามปราสาทที่ยิ่งใหญ่ที่สุดของญี่ปุ่น มีกำแพงหินโค้งสูงที่ออกแบบป้องกันการปีนป่ายของศัตรู','หนึ่งในสามปราสาทเอกของญี่ปุ่น','https://placehold.co/900x700/1a1a2e/ffffff?text=ปราสาทคุมาโมโตะ'),('18','เบ็ปปุ','別府','kyushu','onsen','ฤดูหนาว','เมืองบ่อน้ำพุร้อนที่มีจำนวนบ่อมากที่สุดในญี่ปุ่น','เมืองที่มีจำนวนแหล่งน้ำพุร้อนมากที่สุดในญี่ปุ่น ขึ้นชื่อเรื่องบ่อนรกทั้งแปดที่มีสีสันแตกต่างกันตามแร่ธาตุ','บ่อนรกทั้งแปด สีสันจากแร่ธาตุตามธรรมชาติ','https://placehold.co/900x700/1a1a2e/ffffff?text=เบ็ปปุ'),('19','ป่าเกาะยาคุชิมะ','屋久島','kyushu','nature','ฤดูใบไม้ร่วง','ป่าดึกดำบรรพ์อายุกว่าพันปีต้นแบบภาพยนตร์แอนิเมชัน','เกาะที่ปกคลุมด้วยป่าซีดาร์โบราณอายุกว่า 1,000 ปี ความชื้นสูงทำให้มอสสีเขียวปกคลุมทั่วป่า','ต้นซีดาร์โบราณอายุนับพันปี มรดกโลกทางธรรมชาติ','https://placehold.co/900x700/1a1a2e/ffffff?text=ป่าเกาะยาคุชิมะ'),('2','วัดคิโยมิสึ','清水寺','kansai','shrine','ฤดูใบไม้ร่วง','ระเบียงไม้ยื่นสูงมองเห็นเมืองเกียวโตทั้งเมือง','วัดเก่าแก่บนเนินเขาทางตะวันออกของเกียวโต ขึ้นชื่อจากระเบียงไม้ขนาดใหญ่ที่สร้างโดยไม่ใช้ตะปูเลยแม้แต่ตัวเดียว มองเห็นทิวทัศน์เมืองและป่าไม้โดยรอบ','ระเบียงไม้ไร้ตะปูสูงจากพื้น 13 เมตร','https://placehold.co/900x700/1a1a2e/ffffff?text=วัดคิโยมิสึ'),('20','พิพิธภัณฑ์สัตว์น้ำชูราอูมิ','美ら海水族館','okinawa','island','ฤดูร้อน','ตู้ปลายักษ์จำลองท้องทะเลโอกินาว่าพร้อมฉลามวาฬ','พิพิธภัณฑ์สัตว์น้ำขนาดใหญ่ทางตอนเหนือของเกาะโอกินาว่า จุดเด่นคือตู้ปลาขนาดยักษ์ชื่อคุโรชิโอะที่มีฉลามวาฬและกระเบนราหูว่ายวนภายใน','ตู้ปลายักษ์คุโรชิโอะพร้อมฉลามวาฬ','https://placehold.co/900x700/1a1a2e/ffffff?text=พิพิธภัณฑ์สัตว์น้ำชูราอูมิ'),('21','หมู่บ้านศิลปะเกาะนาโอชิมะ','直島','shikoku','island','ตลอดปี','เกาะศิลปะกลางทะเลเซโตะ บ้านฟักทองจุดสีเหลือง','เกาะเล็กในทะเลเซโตะที่แปรสภาพเป็นพิพิธภัณฑ์ศิลปะกลางแจ้ง มีประติมากรรมฟักทองสีเหลืองจุดดำริมทะเลอันเป็นสัญลักษณ์ของเกาะ','ประติมากรรมฟักทองจุดสีเหลืองอันเป็นสัญลักษณ์ของเกาะ','https://placehold.co/900x700/1a1a2e/ffffff?text=หมู่บ้านศิลปะเกาะนาโอชิมะ'),('22','ทุ่งดอกไม้บิเอะ-ฟูราโนะ','美瑛・富良野','hokkaido','nature','ฤดูร้อน','ทุ่งลาเวนเดอร์และดอกไม้หลากสีเป็นแนวยาว','พื้นที่เกษตรกรรมบนเนินเขาทางตอนกลางของฮอกไกโด ในฤดูร้อนทุ่งดอกไม้หลากสีทั้งลาเวนเดอร์ ทานตะวัน และป๊อปปี้จะบานสะพรั่งเป็นแนวยาว','ทุ่งลาเวนเดอร์สีม่วงที่มีชื่อเสียงที่สุดของฮอกไกโด','https://placehold.co/900x700/1a1a2e/ffffff?text=ทุ่งดอกไม้บิเอะ-ฟูราโนะ'),('23','คลองโอตารุ','小樽運河','hokkaido','city','ฤดูหนาว','คลองเก่าริมเมืองท่า โคมไฟแก๊สยามค่ำคืน','คลองประวัติศาสตร์ในเมืองท่าโอตารุ สองฝั่งคลองเรียงรายด้วยโกดังสินค้าเก่าที่ปรับเป็นร้านค้าและร้านกาแฟ ช่วงเดือนกุมภาพันธ์มีเทศกาลหิมะจุดเทียนริมคลอง','เทศกาลแสงเทียนหิมะโอตารุช่วงเดือนกุมภาพันธ์','https://placehold.co/900x700/1a1a2e/ffffff?text=คลองโอตารุ'),('24','อ่าวมัตสึชิมะ','松島','tohoku','nature','ฤดูใบไม้ร่วง','อ่าวเกาะเล็กเกาะน้อยกว่า 260 เกาะ','อ่าวที่ได้รับการยกย่องเป็นหนึ่งในสามทิวทัศน์งดงามที่สุดของญี่ปุ่น ประกอบด้วยเกาะเล็กเกาะน้อยกว่า 260 เกาะปกคลุมด้วยต้นสน','หนึ่งในสามทิวทัศน์งดงามที่สุดของญี่ปุ่น','https://placehold.co/900x700/1a1a2e/ffffff?text=อ่าวมัตสึชิมะ'),('3','ป่าไผ่อาราชิยามะ','嵐山竹林','kansai','nature','ตลอดปี','ทางเดินกลางป่าไผ่สูงเสียดฟ้า เสียงลมพลิ้วไผ่','เส้นทางเดินเท้าสั้นๆ กลางป่าไผ่ที่เกียวโต ต้นไผ่สูงเรียงตัวหนาแน่นสองข้างทาง เมื่อลมพัดจะเกิดเสียงกิ่งไผ่เสียดสีกันเป็นเอกลักษณ์','เส้นทางไผ่ที่ถูกถ่ายภาพมากที่สุดแห่งหนึ่งในญี่ปุ่น','https://placehold.co/900x700/1a1a2e/ffffff?text=ป่าไผ่อาราชิยามะ'),('4','ปราสาทฮิเมจิ','姫路城','kansai','castle','ฤดูใบไม้ผลิ','ปราสาทไม้สีขาวที่สมบูรณ์ที่สุดของญี่ปุ่น','ปราสาทที่ได้รับการขึ้นทะเบียนเป็นมรดกโลก มีผนังสีขาวคล้ายนกกระสากางปีก เป็นหนึ่งในปราสาทดั้งเดิมไม่กี่แห่งของญี่ปุ่นที่ไม่เคยถูกทำลายจากไฟไหม้หรือสงคราม','หนึ่งในปราสาทดั้งเดิม 12 แห่งที่ยังหลงเหลืออยู่','https://placehold.co/900x700/1a1a2e/ffffff?text=ปราสาทฮิเมจิ'),('5','สวนกวารานาระ','奈良公園','kansai','garden','ตลอดปี','สวนสาธารณะที่กวางป่าเดินเพ่นพ่านอย่างอิสระ','สวนขนาดใหญ่กลางเมืองนารา มีกวางป่ากว่าพันตัวอาศัยอยู่อย่างเป็นอิสระ ถือเป็นสัตว์ศักดิ์สิทธิ์ตามความเชื่อท้องถิ่น','กวางกว่า 1,000 ตัวเดินอิสระทั่วสวน','https://placehold.co/900x700/1a1a2e/ffffff?text=สวนกวารานาระ'),('6','โดทงโบริ โอซาก้า','道頓堀','kansai','city','ตลอดปี','ย่านคลองกลางเมืองแหล่งรวมป้ายไฟและสตรีทฟู้ด','ย่านบันเทิงริมคลองใจกลางโอซาก้า ขึ้นชื่อเรื่องป้ายไฟขนาดยักษ์ โดยเฉพาะป้ายกูลิโกะรันนิ่งแมนอันเป็นสัญลักษณ์ของเมือง','ป้ายไฟกูลิโกะรันนิ่งแมนอันโด่งดัง','https://placehold.co/900x700/1a1a2e/ffffff?text=โดทงโบริ+โอซาก้า'),('7','วัดเซนโซจิ อาซากุสะ','浅草寺','kanto','shrine','ตลอดปี','วัดพุทธเก่าแก่ที่สุดของโตเกียว หน้าประตูโคมแดงยักษ์','วัดที่เก่าแก่ที่สุดในโตเกียว ทางเข้ามีประตูคามินาริมงประดับโคมไฟกระดาษสีแดงขนาดใหญ่ ถนนนากามิเสะเรียงรายด้วยร้านขายของที่ระลึก','โคมไฟยักษ์ที่ประตูคามินาริมงสูงเกือบ 4 เมตร','https://placehold.co/900x700/1a1a2e/ffffff?text=วัดเซนโซจิ+อาซากุสะ'),('8','ศาลเจ้านิกโกโทโชกุ','日光東照宮','kanto','shrine','ฤดูใบไม้ร่วง','ศาลเจ้าแกะสลักวิจิตรกลางป่าสนโบราณ','ศาลเจ้าที่ประดิษฐานดวงวิญญาณโชกุนโทกุงาวะ อิเอยาสุ ขึ้นชื่อเรื่องงานแกะสลักไม้ที่วิจิตรบรรจง รวมถึงรูปแกะสลักลิงสามตัว','ต้นแบบของสำนวน ไม่ดู ไม่ฟัง ไม่พูด','https://placehold.co/900x700/1a1a2e/ffffff?text=ศาลเจ้านิกโกโทโชกุ'),('9','คามาคุระ ไดบุตสึ','鎌倉大仏','kanto','shrine','ตลอดปี','พระพุทธรูปสัมฤทธิ์กลางแจ้งริมทะเลคามาคุระ','พระพุทธรูปสัมฤทธิ์องค์ใหญ่ประดิษฐานกลางแจ้งที่วัดโคโตคุอิน เมืองคามาคุระ สร้างขึ้นตั้งแต่ศตวรรษที่ 13','พระพุทธรูปสัมฤทธิ์กลางแจ้งสูงกว่า 13 เมตร','https://placehold.co/900x700/1a1a2e/ffffff?text=คามาคุระ+ไดบุตสึ');
/*!40000 ALTER TABLE `spots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'testuser','test@example.com','$2a$12$YilTMesgJBwwVp1WyWLqXOwaoGGZWJCCrdAnjQKmpUY1P0w0RWyLG','2026-08-11 04:17:48'),(2,'Puttipong','puttokung001@gmail.com','$2a$12$RxQOGf9mvwDINBr5aBBdeugAKjPZlNANq31CA714l6MonEfiWn1KS','2026-08-11 04:24:38'),(3,'putto','puttokung009@gmail.com','$2a$12$m6.QMbrfchJVAqOU/yiOr.0oVFVyPEqACFTmXt7MuBOG227UkiUw6','2026-08-16 08:00:40');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'japan_travel'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-01  9:33:12
