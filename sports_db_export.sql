-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: sports_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `certificates` (
  `cert_id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `tournament_id` int(11) NOT NULL,
  `position` tinyint(4) NOT NULL COMMENT '1=Gold 2=Silver 3=Bronze',
  `unique_code` varchar(64) NOT NULL COMMENT 'Encrypted code embedded in QR',
  `pdf_path` varchar(255) DEFAULT NULL COMMENT 'static/certificates/<file>.pdf',
  `qr_path` varchar(255) DEFAULT NULL COMMENT 'static/qr_codes/cert_<code>.png',
  `qr_url` varchar(500) DEFAULT NULL,
  `is_valid` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = revoked',
  `issued_at` datetime NOT NULL DEFAULT current_timestamp(),
  `downloaded_at` datetime DEFAULT NULL,
  `notified` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Email sent flag',
  PRIMARY KEY (`cert_id`),
  UNIQUE KEY `uq_cert_unique_code` (`unique_code`),
  UNIQUE KEY `uq_cert_player_tournament` (`player_id`,`tournament_id`),
  KEY `idx_cert_tournament` (`tournament_id`),
  KEY `idx_cert_position` (`position`),
  KEY `idx_cert_valid` (`is_valid`),
  CONSTRAINT `fk_cert_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`player_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cert_tournament` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`tournament_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_cert_position` CHECK (`position` between 1 and 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Achievement certificates with QR';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `sport_id` int(11) DEFAULT NULL,
  `total_qty` int(11) NOT NULL DEFAULT 0,
  `available_qty` int(11) NOT NULL DEFAULT 0,
  `unit` varchar(20) NOT NULL DEFAULT 'pcs',
  `condition_status` enum('good','fair','damaged','under_maintenance') NOT NULL DEFAULT 'good',
  `notes` text DEFAULT NULL,
  `added_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`item_id`),
  KEY `idx_inv_sport` (`sport_id`),
  KEY `idx_inv_condition` (`condition_status`),
  KEY `fk_inv_added_by` (`added_by`),
  CONSTRAINT `fk_inv_added_by` FOREIGN KEY (`added_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_inv_sport` FOREIGN KEY (`sport_id`) REFERENCES `sports` (`sport_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_inv_qty` CHECK (`available_qty` >= 0 and `available_qty` <= `total_qty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sports equipment inventory';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_requests`
--

DROP TABLE IF EXISTS `inventory_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_requests` (
  `req_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `qty_requested` int(11) NOT NULL DEFAULT 1,
  `qty_issued` int(11) DEFAULT NULL,
  `status` enum('pending','approved','denied','returned') NOT NULL DEFAULT 'pending',
  `issued_at` datetime DEFAULT NULL,
  `returned_at` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`req_id`),
  KEY `idx_invreq_item` (`item_id`),
  KEY `idx_invreq_team` (`team_id`),
  KEY `idx_invreq_status` (`status`),
  KEY `idx_invreq_requested_by` (`requested_by`),
  CONSTRAINT `fk_invreq_item` FOREIGN KEY (`item_id`) REFERENCES `inventory` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_invreq_req_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_invreq_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Equipment borrow requests by coaches';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_requests`
--

LOCK TABLES `inventory_requests` WRITE;
/*!40000 ALTER TABLE `inventory_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_requests` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_inv_qty_on_issue
AFTER UPDATE ON inventory_requests
FOR EACH ROW
BEGIN
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
        UPDATE inventory
        SET available_qty = available_qty - NEW.qty_requested
        WHERE item_id = NEW.item_id
        AND   available_qty >= NEW.qty_requested;
    END IF;

    IF NEW.status = 'returned' AND OLD.status = 'approved' THEN
        UPDATE inventory
        SET available_qty = available_qty + COALESCE(NEW.qty_issued, NEW.qty_requested)
        WHERE item_id = NEW.item_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `leaderboard`
--

DROP TABLE IF EXISTS `leaderboard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leaderboard` (
  `lb_id` int(11) NOT NULL AUTO_INCREMENT,
  `tournament_id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `wins` int(11) NOT NULL DEFAULT 0,
  `losses` int(11) NOT NULL DEFAULT 0,
  `draws` int(11) NOT NULL DEFAULT 0,
  `points` int(11) NOT NULL DEFAULT 0 COMMENT '3 per win, 1 per draw',
  `goals_for` int(11) NOT NULL DEFAULT 0,
  `goals_against` int(11) NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`lb_id`),
  UNIQUE KEY `uq_lb_tournament_team` (`tournament_id`,`team_id`),
  KEY `idx_lb_tournament_points` (`tournament_id`,`points`),
  KEY `fk_lb_team` (`team_id`),
  CONSTRAINT `fk_lb_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lb_tournament` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`tournament_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Live leaderboard standings';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaderboard`
--

LOCK TABLES `leaderboard` WRITE;
/*!40000 ALTER TABLE `leaderboard` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaderboard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `matches`
--

DROP TABLE IF EXISTS `matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `matches` (
  `match_id` int(11) NOT NULL AUTO_INCREMENT,
  `tournament_id` int(11) NOT NULL,
  `team1_id` int(11) NOT NULL,
  `team2_id` int(11) NOT NULL,
  `venue` varchar(150) NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `round_label` varchar(50) DEFAULT NULL COMMENT 'e.g. Quarter Final, SF, Final',
  `qr_code` varchar(255) DEFAULT NULL COMMENT 'Entry ticket QR',
  `qr_url` varchar(500) DEFAULT NULL,
  `status` enum('scheduled','live','completed','postponed','cancelled') NOT NULL DEFAULT 'scheduled',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`match_id`),
  KEY `idx_match_tournament` (`tournament_id`),
  KEY `idx_match_team1` (`team1_id`),
  KEY `idx_match_team2` (`team2_id`),
  KEY `idx_match_scheduled` (`scheduled_at`),
  KEY `idx_match_venue_time` (`venue`,`scheduled_at`) COMMENT 'Conflict detection index',
  KEY `idx_match_status` (`status`),
  CONSTRAINT `fk_match_team1` FOREIGN KEY (`team1_id`) REFERENCES `teams` (`team_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_match_team2` FOREIGN KEY (`team2_id`) REFERENCES `teams` (`team_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_match_tournament` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`tournament_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_match_teams` CHECK (`team1_id` <> `team2_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Match schedule';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `matches`
--

LOCK TABLES `matches` WRITE;
/*!40000 ALTER TABLE `matches` DISABLE KEYS */;
/*!40000 ALTER TABLE `matches` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_match_status_live
BEFORE UPDATE ON matches
FOR EACH ROW
BEGIN
    IF NEW.status = 'live' AND OLD.status = 'scheduled' THEN
        SET NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `notif_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `type` enum('match_schedule','match_result','certificate_ready','team_join_request','inventory_update','broadcast') NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `email_sent` tinyint(1) NOT NULL DEFAULT 0,
  `ref_type` varchar(50) DEFAULT NULL COMMENT 'match / tournament / certificate ÔÇª',
  `ref_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`notif_id`),
  KEY `idx_notif_user` (`user_id`),
  KEY `idx_notif_type` (`type`),
  KEY `idx_notif_is_read` (`is_read`),
  KEY `idx_notif_created` (`created_at`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='In-app and email notifications';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_resets` (
  `reset_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL COMMENT 'Secure random token',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`reset_id`),
  UNIQUE KEY `uq_reset_token` (`token`),
  KEY `idx_reset_user` (`user_id`),
  CONSTRAINT `fk_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Password reset OTP tokens';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance`
--

DROP TABLE IF EXISTS `performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `performance` (
  `perf_id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `match_id` int(11) NOT NULL,
  `stat_type` varchar(50) NOT NULL COMMENT 'runs / goals / assists / rebounds ÔÇª',
  `value` decimal(8,2) NOT NULL DEFAULT 0.00,
  `notes` varchar(255) DEFAULT NULL,
  `recorded_by` int(11) NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`perf_id`),
  KEY `idx_perf_player` (`player_id`),
  KEY `idx_perf_match` (`match_id`),
  KEY `idx_perf_type` (`stat_type`),
  KEY `fk_perf_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_perf_match` FOREIGN KEY (`match_id`) REFERENCES `matches` (`match_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_perf_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`player_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_perf_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Player-level performance stats per match';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance`
--

LOCK TABLES `performance` WRITE;
/*!40000 ALTER TABLE `performance` DISABLE KEYS */;
/*!40000 ALTER TABLE `performance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `players` (
  `player_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `sport_id` int(11) NOT NULL,
  `reg_number` varchar(20) NOT NULL COMMENT 'College registration number',
  `department` varchar(100) NOT NULL,
  `year` tinyint(4) NOT NULL COMMENT '1ÔÇô4',
  `photo` varchar(255) DEFAULT NULL COMMENT 'Relative path: static/images/players/',
  `qr_code` varchar(255) DEFAULT NULL COMMENT 'Relative path: static/qr_codes/',
  `qr_url` varchar(500) DEFAULT NULL COMMENT 'Full verify URL encoded in QR',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`player_id`),
  UNIQUE KEY `uq_player_user` (`user_id`),
  UNIQUE KEY `uq_player_reg_number` (`reg_number`),
  KEY `idx_player_sport` (`sport_id`),
  KEY `idx_player_dept_year` (`department`,`year`),
  CONSTRAINT `fk_player_sport` FOREIGN KEY (`sport_id`) REFERENCES `sports` (`sport_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_player_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_player_year` CHECK (`year` between 1 and 4)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Student athlete profiles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES (1,9,1,'2022CSE001','CSE',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(2,10,2,'2022ECE023','ECE',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(3,11,3,'2023MECH007','MECH',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(4,12,1,'2022CSE018','CSE',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(5,13,2,'2023ECE041','ECE',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(6,14,1,'2021MECH003','MECH',3,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(7,15,3,'2023IT010','IT',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(8,16,2,'2022IT029','IT',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(9,17,1,'2021AIDS005','AIDS',3,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(10,18,3,'2023CSE055','CSE',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(11,19,2,'2022MECH012','MECH',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(12,20,1,'2021ECE008','ECE',3,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(13,21,3,'2023ECE066','ECE',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(14,22,2,'2023AIDS019','AIDS',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(15,23,1,'2022AIDS031','AIDS',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(16,24,3,'2021CSE042','CSE',3,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(17,25,2,'2021IT055','IT',3,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(18,26,1,'2023IT071','IT',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(19,27,1,'2023MECH088','MECH',1,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31'),(20,28,2,'2022CSE099','CSE',2,NULL,NULL,NULL,'2026-06-03 20:41:31','2026-06-03 20:41:31');
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qr_logs`
--

DROP TABLE IF EXISTS `qr_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qr_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `qr_type` enum('player','team','tournament','match','certificate','score') NOT NULL,
  `ref_id` int(11) NOT NULL COMMENT 'FK value depends on qr_type',
  `scanned_by` int(11) DEFAULT NULL COMMENT 'NULL = anonymous public scan',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `scanned_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `idx_qr_type` (`qr_type`),
  KEY `idx_qr_ref` (`ref_id`),
  KEY `idx_qr_scanned_by` (`scanned_by`),
  KEY `idx_qr_time` (`scanned_at`),
  CONSTRAINT `fk_qr_scanned_by` FOREIGN KEY (`scanned_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='QR scan activity log ÔÇö all modules';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qr_logs`
--

LOCK TABLES `qr_logs` WRITE;
/*!40000 ALTER TABLE `qr_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `qr_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scores` (
  `score_id` int(11) NOT NULL AUTO_INCREMENT,
  `match_id` int(11) NOT NULL,
  `team1_score` int(11) NOT NULL DEFAULT 0,
  `team2_score` int(11) NOT NULL DEFAULT 0,
  `winner_team_id` int(11) DEFAULT NULL COMMENT 'NULL = draw',
  `notes` text DEFAULT NULL,
  `entered_by` int(11) NOT NULL COMMENT 'FK ÔåÆ users (coach/admin)',
  `entered_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`score_id`),
  UNIQUE KEY `uq_score_match` (`match_id`),
  KEY `idx_score_winner` (`winner_team_id`),
  KEY `idx_score_entered_by` (`entered_by`),
  CONSTRAINT `fk_score_entered_by` FOREIGN KEY (`entered_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_score_match` FOREIGN KEY (`match_id`) REFERENCES `matches` (`match_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_score_winner` FOREIGN KEY (`winner_team_id`) REFERENCES `teams` (`team_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_scores_non_negative` CHECK (`team1_score` >= 0 and `team2_score` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Match results; triggers leaderboard update';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scores`
--

LOCK TABLES `scores` WRITE;
/*!40000 ALTER TABLE `scores` DISABLE KEYS */;
/*!40000 ALTER TABLE `scores` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_update_leaderboard
AFTER INSERT ON scores
FOR EACH ROW
BEGIN
    DECLARE t1_id INT;
    DECLARE t2_id INT;
    DECLARE tid   INT;

    
    SELECT team1_id, team2_id, tournament_id
    INTO   t1_id, t2_id, tid
    FROM   matches
    WHERE  match_id = NEW.match_id;

    
    INSERT IGNORE INTO leaderboard (tournament_id, team_id)
    VALUES (tid, t1_id), (tid, t2_id);

    
    IF NEW.winner_team_id = t1_id THEN
        UPDATE leaderboard
        SET wins   = wins   + 1,
            points = points + 3,
            goals_for     = goals_for     + NEW.team1_score,
            goals_against = goals_against + NEW.team2_score
        WHERE tournament_id = tid AND team_id = t1_id;

        UPDATE leaderboard
        SET losses        = losses        + 1,
            goals_for     = goals_for     + NEW.team2_score,
            goals_against = goals_against + NEW.team1_score
        WHERE tournament_id = tid AND team_id = t2_id;

    
    ELSEIF NEW.winner_team_id = t2_id THEN
        UPDATE leaderboard
        SET wins   = wins   + 1,
            points = points + 3,
            goals_for     = goals_for     + NEW.team2_score,
            goals_against = goals_against + NEW.team1_score
        WHERE tournament_id = tid AND team_id = t2_id;

        UPDATE leaderboard
        SET losses        = losses        + 1,
            goals_for     = goals_for     + NEW.team1_score,
            goals_against = goals_against + NEW.team2_score
        WHERE tournament_id = tid AND team_id = t1_id;

    
    ELSE
        UPDATE leaderboard
        SET draws         = draws         + 1,
            points        = points        + 1,
            goals_for     = goals_for     + NEW.team1_score,
            goals_against = goals_against + NEW.team2_score
        WHERE tournament_id = tid AND team_id = t1_id;

        UPDATE leaderboard
        SET draws         = draws         + 1,
            points        = points        + 1,
            goals_for     = goals_for     + NEW.team2_score,
            goals_against = goals_against + NEW.team1_score
        WHERE tournament_id = tid AND team_id = t2_id;
    END IF;

    
    UPDATE matches SET status = 'completed' WHERE match_id = NEW.match_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sports`
--

DROP TABLE IF EXISTS `sports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sports` (
  `sport_id` int(11) NOT NULL AUTO_INCREMENT,
  `sport_name` varchar(80) NOT NULL,
  `description` text DEFAULT NULL,
  `max_team_size` int(11) NOT NULL DEFAULT 11,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`sport_id`),
  UNIQUE KEY `uq_sport_name` (`sport_name`),
  KEY `idx_sport_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sports category registry';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sports`
--

LOCK TABLES `sports` WRITE;
/*!40000 ALTER TABLE `sports` DISABLE KEYS */;
INSERT INTO `sports` VALUES (1,'Cricket','Outdoor bat-and-ball sport',11,1,'2026-06-03 20:41:29'),(2,'Football','Association football / soccer',11,1,'2026-06-03 20:41:29'),(3,'Basketball','Indoor court sport ÔÇö 5 per team',5,1,'2026-06-03 20:41:29'),(4,'Volleyball','Indoor net sport ÔÇö 6 per team',6,1,'2026-06-03 20:41:29'),(5,'Badminton','Racquet sport ÔÇö singles and doubles',2,1,'2026-06-03 20:41:29'),(6,'Kabaddi','Contact sport ÔÇö 7 per team',7,1,'2026-06-03 20:41:29');
/*!40000 ALTER TABLE `sports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_players`
--

DROP TABLE IF EXISTS `team_players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_players` (
  `tp_id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `position` varchar(50) DEFAULT NULL COMMENT 'e.g. Batsman, Goalkeeper',
  `joined_at` date NOT NULL DEFAULT curdate(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`tp_id`),
  UNIQUE KEY `uq_team_player` (`team_id`,`player_id`),
  KEY `idx_tp_player` (`player_id`),
  KEY `idx_tp_team` (`team_id`),
  CONSTRAINT `fk_tp_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`player_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tp_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Many-to-Many: team members';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_players`
--

LOCK TABLES `team_players` WRITE;
/*!40000 ALTER TABLE `team_players` DISABLE KEYS */;
INSERT INTO `team_players` VALUES (1,1,1,'Batsman','2026-06-03',1),(2,1,4,'Bowler','2026-06-03',1),(3,1,6,'All-rounder','2026-06-03',1),(4,1,9,'Wicketkeeper','2026-06-03',1),(5,1,12,'Batsman','2026-06-03',1),(6,2,2,'Forward','2026-06-03',1),(7,2,5,'Midfielder','2026-06-03',1),(8,2,8,'Defender','2026-06-03',1),(9,2,11,'Goalkeeper','2026-06-03',1),(10,2,18,'Forward','2026-06-03',1),(11,3,3,'Center','2026-06-03',1),(12,3,7,'Guard','2026-06-03',1),(13,3,10,'Forward','2026-06-03',1),(14,3,13,'Guard','2026-06-03',1),(15,3,16,'Center','2026-06-03',1),(16,4,15,'Batsman','2026-06-03',1),(17,4,17,'Bowler','2026-06-03',1),(18,4,19,'All-rounder','2026-06-03',1),(19,4,20,'Wicketkeeper','2026-06-03',1),(20,5,14,'Forward','2026-06-03',1),(21,5,22,'Midfielder','2026-06-03',1);
/*!40000 ALTER TABLE `team_players` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_prevent_duplicate_sport_team
BEFORE INSERT ON team_players
FOR EACH ROW
BEGIN
    DECLARE sport_count INT DEFAULT 0;

    SELECT COUNT(*) INTO sport_count
    FROM   team_players  tp
    JOIN   teams          t  ON tp.team_id = t.team_id
    JOIN   players        p  ON tp.player_id = p.player_id
    WHERE  tp.player_id = NEW.player_id
    AND    t.sport_id   = (SELECT sport_id FROM teams WHERE team_id = NEW.team_id)
    AND    tp.is_active = 1;

    IF sport_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Player is already assigned to a team for this sport.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `team_id` int(11) NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) NOT NULL,
  `sport_id` int(11) NOT NULL,
  `coach_id` int(11) NOT NULL COMMENT 'FK ÔåÆ users where role=coach',
  `qr_code` varchar(255) DEFAULT NULL,
  `qr_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `uq_team_name_sport` (`team_name`,`sport_id`),
  KEY `idx_team_sport` (`sport_id`),
  KEY `idx_team_coach` (`coach_id`),
  CONSTRAINT `fk_team_coach` FOREIGN KEY (`coach_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_team_sport` FOREIGN KEY (`sport_id`) REFERENCES `sports` (`sport_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sports teams';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
INSERT INTO `teams` VALUES (1,'CSE Warriors',1,2,NULL,NULL,1,'2026-06-03 20:41:32','2026-06-03 20:41:32'),(2,'ECE Eagles',2,3,NULL,NULL,1,'2026-06-03 20:41:32','2026-06-03 20:41:32'),(3,'MECH Titans',3,4,NULL,NULL,1,'2026-06-03 20:41:32','2026-06-03 20:41:32'),(4,'IT Spartans',1,5,NULL,NULL,1,'2026-06-03 20:41:32','2026-06-03 20:41:32'),(5,'AIDS Stars',2,6,NULL,NULL,1,'2026-06-03 20:41:32','2026-06-03 20:41:32');
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tournaments`
--

DROP TABLE IF EXISTS `tournaments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tournaments` (
  `tournament_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `sport_id` int(11) NOT NULL,
  `format` enum('round_robin','knockout','group_knockout') NOT NULL DEFAULT 'knockout',
  `venue` varchar(150) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `qr_code` varchar(255) DEFAULT NULL COMMENT 'Tournament schedule QR',
  `qr_url` varchar(500) DEFAULT NULL,
  `status` enum('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_by` int(11) NOT NULL COMMENT 'FK ÔåÆ users (admin)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`tournament_id`),
  KEY `idx_tournament_sport` (`sport_id`),
  KEY `idx_tournament_status` (`status`),
  KEY `idx_tournament_dates` (`start_date`,`end_date`),
  KEY `fk_tournament_created_by` (`created_by`),
  CONSTRAINT `fk_tournament_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tournament_sport` FOREIGN KEY (`sport_id`) REFERENCES `sports` (`sport_id`) ON UPDATE CASCADE,
  CONSTRAINT `chk_tournament_dates` CHECK (`end_date` >= `start_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tournament / event records';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tournaments`
--

LOCK TABLES `tournaments` WRITE;
/*!40000 ALTER TABLE `tournaments` DISABLE KEYS */;
INSERT INTO `tournaments` VALUES (1,'Inter-Dept Cricket Championship 2025',1,'knockout','Ground 1','2026-04-10','2026-04-20',NULL,NULL,'ongoing',1,'2026-06-03 20:41:35','2026-06-03 20:41:35'),(2,'Inter-Dept Football League 2025',2,'round_robin','Ground 2','2026-04-12','2026-04-22',NULL,NULL,'ongoing',1,'2026-06-03 20:41:35','2026-06-03 20:41:35'),(3,'Basketball Clash 2025',3,'knockout','Court A','2026-04-15','2026-04-18',NULL,NULL,'upcoming',1,'2026-06-03 20:41:35','2026-06-03 20:41:35');
/*!40000 ALTER TABLE `tournaments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL COMMENT 'bcrypt hashed via Flask-Bcrypt',
  `role` enum('admin','coach','player','viewer') NOT NULL DEFAULT 'player',
  `phone` varchar(15) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 = deactivated by admin',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role` (`role`),
  KEY `idx_users_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Master user accounts table ÔÇö all roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'S. Rahul','rahul@college.edu','$2b$12$adminHashPlaceholder01','admin','9876543210',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(2,'K. Balaji','balaji@college.edu','$2b$12$coachHashPlaceholder01','coach','9876543211',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(3,'R. Sunitha','sunitha@college.edu','$2b$12$coachHashPlaceholder02','coach','9876543212',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(4,'M. Tamilselvan','tamilselvan@college.edu','$2b$12$coachHashPlaceholder03','coach','9876543213',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(5,'M. Sathiya','sathiya@college.edu','$2b$12$coachHashPlaceholder04','coach','9876543214',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(6,'A. Sathish','sathish@college.edu','$2b$12$coachHashPlaceholder05','coach','9876543215',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(7,'P. Nikkitha','nikkitha@college.edu','$2b$12$coachHashPlaceholder06','coach','9876543216',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(8,'R. Yuga','yuga@college.edu','$2b$12$coachHashPlaceholder07','coach','9876543217',1,'2026-06-03 20:41:29','2026-06-03 20:41:29'),(9,'Arjun Kumar','arjun@college.edu','$2b$12$playerHash01','player','9001000001',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(10,'Ravi Shankar','ravi.s@college.edu','$2b$12$playerHash02','player','9001000002',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(11,'Priya Subramani','priya.s@college.edu','$2b$12$playerHash03','player','9001000003',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(12,'Karthik Raj','karthik.r@college.edu','$2b$12$playerHash04','player','9001000004',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(13,'Deepa Mohan','deepa.m@college.edu','$2b$12$playerHash05','player','9001000005',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(14,'Vijay Anand','vijay.a@college.edu','$2b$12$playerHash06','player','9001000006',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(15,'Meena Kumari','meena.k@college.edu','$2b$12$playerHash07','player','9001000007',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(16,'Suresh Patel','suresh.p@college.edu','$2b$12$playerHash08','player','9001000008',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(17,'Lakshmi Narayan','lakshmi.n@college.edu','$2b$12$playerHash09','player','9001000009',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(18,'Arun Prasad','arun.p@college.edu','$2b$12$playerHash10','player','9001000010',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(19,'Siva Kumar','siva.k@college.edu','$2b$12$playerHash11','player','9001000011',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(20,'Preethi Devi','preethi.d@college.edu','$2b$12$playerHash12','player','9001000012',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(21,'Manoj Selvan','manoj.s@college.edu','$2b$12$playerHash13','player','9001000013',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(22,'Kaviya Rajan','kaviya.r@college.edu','$2b$12$playerHash14','player','9001000014',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(23,'Dinesh Babu','dinesh.b@college.edu','$2b$12$playerHash15','player','9001000015',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(24,'Nithya Sri','nithya.s@college.edu','$2b$12$playerHash16','player','9001000016',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(25,'Ramesh Yadav','ramesh.y@college.edu','$2b$12$playerHash17','player','9001000017',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(26,'Suganya Pillai','suganya.p@college.edu','$2b$12$playerHash18','player','9001000018',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(27,'Bala Murugan','bala.m@college.edu','$2b$12$playerHash19','player','9001000019',1,'2026-06-03 20:41:30','2026-06-03 20:41:30'),(28,'Tharani Vel','tharani.v@college.edu','$2b$12$playerHash20','player','9001000020',1,'2026-06-03 20:41:30','2026-06-03 20:41:30');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `vw_leaderboard_standings`
--

DROP TABLE IF EXISTS `vw_leaderboard_standings`;
/*!50001 DROP VIEW IF EXISTS `vw_leaderboard_standings`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_leaderboard_standings` AS SELECT
 1 AS `tournament_id`,
  1 AS `tournament_name`,
  1 AS `team_id`,
  1 AS `team_name`,
  1 AS `sport_name`,
  1 AS `wins`,
  1 AS `losses`,
  1 AS `draws`,
  1 AS `points`,
  1 AS `goals_for`,
  1 AS `goals_against`,
  1 AS `goal_difference`,
  1 AS `rank` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_match_detail`
--

DROP TABLE IF EXISTS `vw_match_detail`;
/*!50001 DROP VIEW IF EXISTS `vw_match_detail`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_match_detail` AS SELECT
 1 AS `match_id`,
  1 AS `tournament_id`,
  1 AS `tournament_name`,
  1 AS `sport_name`,
  1 AS `team1_id`,
  1 AS `team1_name`,
  1 AS `team2_id`,
  1 AS `team2_name`,
  1 AS `venue`,
  1 AS `scheduled_at`,
  1 AS `round_label`,
  1 AS `status`,
  1 AS `team1_score`,
  1 AS `team2_score`,
  1 AS `winner_team_id`,
  1 AS `winner_name` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_player_summary`
--

DROP TABLE IF EXISTS `vw_player_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_player_summary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_player_summary` AS SELECT
 1 AS `player_id`,
  1 AS `player_name`,
  1 AS `email`,
  1 AS `reg_number`,
  1 AS `department`,
  1 AS `year`,
  1 AS `sport_name`,
  1 AS `qr_code`,
  1 AS `team_id`,
  1 AS `team_name`,
  1 AS `coach_name`,
  1 AS `matches_played`,
  1 AS `total_stat_value` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_leaderboard_standings`
--

/*!50001 DROP VIEW IF EXISTS `vw_leaderboard_standings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_leaderboard_standings` AS select `l`.`tournament_id` AS `tournament_id`,`t`.`name` AS `tournament_name`,`l`.`team_id` AS `team_id`,`tm`.`team_name` AS `team_name`,`s`.`sport_name` AS `sport_name`,`l`.`wins` AS `wins`,`l`.`losses` AS `losses`,`l`.`draws` AS `draws`,`l`.`points` AS `points`,`l`.`goals_for` AS `goals_for`,`l`.`goals_against` AS `goals_against`,`l`.`goals_for` - `l`.`goals_against` AS `goal_difference`,rank() over ( partition by `l`.`tournament_id` order by `l`.`points` desc,`l`.`goals_for` - `l`.`goals_against` desc,`l`.`goals_for` desc) AS `rank` from (((`leaderboard` `l` join `tournaments` `t` on(`l`.`tournament_id` = `t`.`tournament_id`)) join `teams` `tm` on(`l`.`team_id` = `tm`.`team_id`)) join `sports` `s` on(`tm`.`sport_id` = `s`.`sport_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_match_detail`
--

/*!50001 DROP VIEW IF EXISTS `vw_match_detail`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_match_detail` AS select `m`.`match_id` AS `match_id`,`m`.`tournament_id` AS `tournament_id`,`tr`.`name` AS `tournament_name`,`s`.`sport_name` AS `sport_name`,`m`.`team1_id` AS `team1_id`,`t1`.`team_name` AS `team1_name`,`m`.`team2_id` AS `team2_id`,`t2`.`team_name` AS `team2_name`,`m`.`venue` AS `venue`,`m`.`scheduled_at` AS `scheduled_at`,`m`.`round_label` AS `round_label`,`m`.`status` AS `status`,`sc`.`team1_score` AS `team1_score`,`sc`.`team2_score` AS `team2_score`,`sc`.`winner_team_id` AS `winner_team_id`,`wt`.`team_name` AS `winner_name` from ((((((`matches` `m` join `tournaments` `tr` on(`m`.`tournament_id` = `tr`.`tournament_id`)) join `sports` `s` on(`tr`.`sport_id` = `s`.`sport_id`)) join `teams` `t1` on(`m`.`team1_id` = `t1`.`team_id`)) join `teams` `t2` on(`m`.`team2_id` = `t2`.`team_id`)) left join `scores` `sc` on(`m`.`match_id` = `sc`.`match_id`)) left join `teams` `wt` on(`sc`.`winner_team_id` = `wt`.`team_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_player_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_player_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_player_summary` AS select `p`.`player_id` AS `player_id`,`u`.`name` AS `player_name`,`u`.`email` AS `email`,`p`.`reg_number` AS `reg_number`,`p`.`department` AS `department`,`p`.`year` AS `year`,`s`.`sport_name` AS `sport_name`,`p`.`qr_code` AS `qr_code`,`tm`.`team_id` AS `team_id`,`tm`.`team_name` AS `team_name`,`coach`.`name` AS `coach_name`,count(distinct `perf`.`match_id`) AS `matches_played`,coalesce(sum(`perf`.`value`),0) AS `total_stat_value` from ((((((`players` `p` join `users` `u` on(`p`.`user_id` = `u`.`user_id`)) join `sports` `s` on(`p`.`sport_id` = `s`.`sport_id`)) left join `team_players` `tp` on(`p`.`player_id` = `tp`.`player_id` and `tp`.`is_active` = 1)) left join `teams` `tm` on(`tp`.`team_id` = `tm`.`team_id`)) left join `users` `coach` on(`tm`.`coach_id` = `coach`.`user_id`)) left join `performance` `perf` on(`p`.`player_id` = `perf`.`player_id`)) group by `p`.`player_id`,`u`.`name`,`u`.`email`,`p`.`reg_number`,`p`.`department`,`p`.`year`,`s`.`sport_name`,`p`.`qr_code`,`tm`.`team_id`,`tm`.`team_name`,`coach`.`name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-08 13:56:55
