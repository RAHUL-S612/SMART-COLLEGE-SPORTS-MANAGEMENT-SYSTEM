-- ============================================================
--  SMART COLLEGE SPORTS MANAGEMENT SYSTEM
--  MySQL 8.0 Database Schema  |  sports_db
--  SRS v1.0  |  B.E Computer Science Engineering
--  Deadline : 30/04/2026
--  Database Manager : A. SATHISH (Member 6)
-- ============================================================
--  Tables  : 13
--  Views   : 3
--  Triggers: 4
--  Indexes : All FK columns + frequently queried fields
-- ============================================================

-- ─────────────────────────────────────────────
--  0.  DATABASE SETUP
-- ─────────────────────────────────────────────
DROP DATABASE IF EXISTS sports_db;
CREATE DATABASE sports_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sports_db;

-- Disable FK checks during creation
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


-- ============================================================
--  TABLE 1 — users
--  All system accounts: Admin, Coach, Player, Viewer
-- ============================================================
CREATE TABLE users (
    user_id     INT            NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100)   NOT NULL,
    email       VARCHAR(100)   NOT NULL,
    password    VARCHAR(255)   NOT NULL COMMENT 'bcrypt hashed via Flask-Bcrypt',
    role        ENUM('admin','coach','player','viewer') NOT NULL DEFAULT 'player',
    phone       VARCHAR(15)    DEFAULT NULL,
    is_active   TINYINT(1)     NOT NULL DEFAULT 1 COMMENT '0 = deactivated by admin',
    created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE  KEY uq_users_email (email),
    INDEX   idx_users_role    (role),
    INDEX   idx_users_active  (is_active)
) ENGINE=InnoDB COMMENT='Master user accounts table — all roles';


-- ============================================================
--  TABLE 2 — password_resets
--  OTP tokens for FR-AU-09 (email-based password reset)
-- ============================================================
CREATE TABLE password_resets (
    reset_id    INT          NOT NULL AUTO_INCREMENT,
    user_id     INT          NOT NULL,
    token       VARCHAR(64)  NOT NULL COMMENT 'Secure random token',
    expires_at  DATETIME     NOT NULL,
    used        TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (reset_id),
    UNIQUE  KEY uq_reset_token  (token),
    INDEX   idx_reset_user      (user_id),
    CONSTRAINT fk_reset_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Password reset OTP tokens';


-- ============================================================
--  TABLE 3 — sports
--  Sport category registry
-- ============================================================
CREATE TABLE sports (
    sport_id      INT          NOT NULL AUTO_INCREMENT,
    sport_name    VARCHAR(80)  NOT NULL,
    description   TEXT         DEFAULT NULL,
    max_team_size INT          NOT NULL DEFAULT 11,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (sport_id),
    UNIQUE KEY uq_sport_name (sport_name),
    INDEX  idx_sport_active  (is_active)
) ENGINE=InnoDB COMMENT='Sports category registry';


-- ============================================================
--  TABLE 4 — players
--  Student athlete profiles (extends users)
-- ============================================================
CREATE TABLE players (
    player_id   INT           NOT NULL AUTO_INCREMENT,
    user_id     INT           NOT NULL,
    sport_id    INT           NOT NULL,
    reg_number  VARCHAR(20)   NOT NULL COMMENT 'College registration number',
    department  VARCHAR(100)  NOT NULL,
    year        TINYINT       NOT NULL COMMENT '1–4',
    photo       VARCHAR(255)  DEFAULT NULL COMMENT 'Relative path: static/images/players/',
    qr_code     VARCHAR(255)  DEFAULT NULL COMMENT 'Relative path: static/qr_codes/',
    qr_url      VARCHAR(500)  DEFAULT NULL COMMENT 'Full verify URL encoded in QR',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (player_id),
    UNIQUE  KEY uq_player_user       (user_id),
    UNIQUE  KEY uq_player_reg_number (reg_number),
    INDEX   idx_player_sport         (sport_id),
    INDEX   idx_player_dept_year     (department, year),
    CONSTRAINT fk_player_user
        FOREIGN KEY (user_id)  REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_player_sport
        FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_player_year
        CHECK (year BETWEEN 1 AND 4)
) ENGINE=InnoDB COMMENT='Student athlete profiles';


-- ============================================================
--  TABLE 5 — teams
--  Sports teams with coach assignment
-- ============================================================
CREATE TABLE teams (
    team_id     INT           NOT NULL AUTO_INCREMENT,
    team_name   VARCHAR(100)  NOT NULL,
    sport_id    INT           NOT NULL,
    coach_id    INT           NOT NULL COMMENT 'FK → users where role=coach',
    qr_code     VARCHAR(255)  DEFAULT NULL,
    qr_url      VARCHAR(500)  DEFAULT NULL,
    is_active   TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (team_id),
    UNIQUE  KEY uq_team_name_sport (team_name, sport_id),
    INDEX   idx_team_sport         (sport_id),
    INDEX   idx_team_coach         (coach_id),
    CONSTRAINT fk_team_sport
        FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_team_coach
        FOREIGN KEY (coach_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Sports teams';


-- ============================================================
--  TABLE 6 — team_players
--  Many-to-Many: players ↔ teams
--  FR-TM-04: prevent a player from being in two teams for the same sport
-- ============================================================
CREATE TABLE team_players (
    tp_id       INT          NOT NULL AUTO_INCREMENT,
    team_id     INT          NOT NULL,
    player_id   INT          NOT NULL,
    position    VARCHAR(50)  DEFAULT NULL COMMENT 'e.g. Batsman, Goalkeeper',
    joined_at   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    is_active   TINYINT(1)   NOT NULL DEFAULT 1,

    PRIMARY KEY (tp_id),
    UNIQUE  KEY uq_team_player      (team_id, player_id),
    INDEX   idx_tp_player           (player_id),
    INDEX   idx_tp_team             (team_id),
    CONSTRAINT fk_tp_team
        FOREIGN KEY (team_id)   REFERENCES teams(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tp_player
        FOREIGN KEY (player_id) REFERENCES players(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Many-to-Many: team members';


-- ============================================================
--  TABLE 7 — tournaments
--  Tournament / event records
-- ============================================================
CREATE TABLE tournaments (
    tournament_id   INT           NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150)  NOT NULL,
    sport_id        INT           NOT NULL,
    format          ENUM('round_robin','knockout','group_knockout') NOT NULL DEFAULT 'knockout',
    venue           VARCHAR(150)  DEFAULT NULL,
    start_date      DATE          NOT NULL,
    end_date        DATE          NOT NULL,
    qr_code         VARCHAR(255)  DEFAULT NULL COMMENT 'Tournament schedule QR',
    qr_url          VARCHAR(500)  DEFAULT NULL,
    status          ENUM('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
    created_by      INT           NOT NULL COMMENT 'FK → users (admin)',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (tournament_id),
    INDEX idx_tournament_sport   (sport_id),
    INDEX idx_tournament_status  (status),
    INDEX idx_tournament_dates   (start_date, end_date),
    CONSTRAINT fk_tournament_sport
        FOREIGN KEY (sport_id)   REFERENCES sports(sport_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tournament_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_tournament_dates
        CHECK (end_date >= start_date)
) ENGINE=InnoDB COMMENT='Tournament / event records';


-- ============================================================
--  TABLE 8 — matches
--  Individual match scheduling
--  FR-ES-03: venue + datetime conflicts detected at app layer
-- ============================================================
CREATE TABLE matches (
    match_id        INT           NOT NULL AUTO_INCREMENT,
    tournament_id   INT           NOT NULL,
    team1_id        INT           NOT NULL,
    team2_id        INT           NOT NULL,
    venue           VARCHAR(150)  NOT NULL,
    scheduled_at    DATETIME      NOT NULL,
    round_label     VARCHAR(50)   DEFAULT NULL COMMENT 'e.g. Quarter Final, SF, Final',
    qr_code         VARCHAR(255)  DEFAULT NULL COMMENT 'Entry ticket QR',
    qr_url          VARCHAR(500)  DEFAULT NULL,
    status          ENUM('scheduled','live','completed','postponed','cancelled') NOT NULL DEFAULT 'scheduled',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (match_id),
    INDEX idx_match_tournament  (tournament_id),
    INDEX idx_match_team1       (team1_id),
    INDEX idx_match_team2       (team2_id),
    INDEX idx_match_scheduled   (scheduled_at),
    INDEX idx_match_venue_time  (venue, scheduled_at) COMMENT 'Conflict detection index',
    INDEX idx_match_status      (status),
    CONSTRAINT fk_match_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_match_team1
        FOREIGN KEY (team1_id) REFERENCES teams(team_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_match_team2
        FOREIGN KEY (team2_id) REFERENCES teams(team_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_match_teams
        CHECK (team1_id <> team2_id)
) ENGINE=InnoDB COMMENT='Match schedule';


-- ============================================================
--  TABLE 9 — scores
--  Match results — triggers leaderboard update & certificate
-- ============================================================
CREATE TABLE scores (
    score_id        INT      NOT NULL AUTO_INCREMENT,
    match_id        INT      NOT NULL,
    team1_score     INT      NOT NULL DEFAULT 0,
    team2_score     INT      NOT NULL DEFAULT 0,
    winner_team_id  INT      DEFAULT NULL COMMENT 'NULL = draw',
    notes           TEXT     DEFAULT NULL,
    entered_by      INT      NOT NULL COMMENT 'FK → users (coach/admin)',
    entered_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (score_id),
    UNIQUE  KEY uq_score_match      (match_id),
    INDEX   idx_score_winner        (winner_team_id),
    INDEX   idx_score_entered_by    (entered_by),
    CONSTRAINT fk_score_match
        FOREIGN KEY (match_id)       REFERENCES matches(match_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_score_winner
        FOREIGN KEY (winner_team_id) REFERENCES teams(team_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_score_entered_by
        FOREIGN KEY (entered_by)     REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_scores_non_negative
        CHECK (team1_score >= 0 AND team2_score >= 0)
) ENGINE=InnoDB COMMENT='Match results; triggers leaderboard update';


-- ============================================================
--  TABLE 10 — leaderboard
--  Live standings per tournament per team
--  Auto-updated by trigger trg_update_leaderboard
-- ============================================================
CREATE TABLE leaderboard (
    lb_id           INT      NOT NULL AUTO_INCREMENT,
    tournament_id   INT      NOT NULL,
    team_id         INT      NOT NULL,
    wins            INT      NOT NULL DEFAULT 0,
    losses          INT      NOT NULL DEFAULT 0,
    draws           INT      NOT NULL DEFAULT 0,
    points          INT      NOT NULL DEFAULT 0 COMMENT '3 per win, 1 per draw',
    goals_for       INT      NOT NULL DEFAULT 0,
    goals_against   INT      NOT NULL DEFAULT 0,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (lb_id),
    UNIQUE  KEY uq_lb_tournament_team (tournament_id, team_id),
    INDEX   idx_lb_tournament_points  (tournament_id, points DESC),
    CONSTRAINT fk_lb_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_lb_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Live leaderboard standings';


-- ============================================================
--  TABLE 11 — performance
--  Per-player stats per match  (FR-PA-02)
-- ============================================================
CREATE TABLE performance (
    perf_id     INT            NOT NULL AUTO_INCREMENT,
    player_id   INT            NOT NULL,
    match_id    INT            NOT NULL,
    stat_type   VARCHAR(50)    NOT NULL COMMENT 'runs / goals / assists / rebounds …',
    value       DECIMAL(8,2)   NOT NULL DEFAULT 0,
    notes       VARCHAR(255)   DEFAULT NULL,
    recorded_by INT            NOT NULL,
    recorded_at DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (perf_id),
    INDEX idx_perf_player   (player_id),
    INDEX idx_perf_match    (match_id),
    INDEX idx_perf_type     (stat_type),
    CONSTRAINT fk_perf_player
        FOREIGN KEY (player_id)   REFERENCES players(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_perf_match
        FOREIGN KEY (match_id)    REFERENCES matches(match_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_perf_recorded_by
        FOREIGN KEY (recorded_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Player-level performance stats per match';


-- ============================================================
--  TABLE 12 — certificates
--  Achievement certificates with QR verification  (FR-CG-01 to FR-CG-09)
-- ============================================================
CREATE TABLE certificates (
    cert_id         INT           NOT NULL AUTO_INCREMENT,
    player_id       INT           NOT NULL,
    tournament_id   INT           NOT NULL,
    position        TINYINT       NOT NULL COMMENT '1=Gold 2=Silver 3=Bronze',
    unique_code     VARCHAR(64)   NOT NULL COMMENT 'Encrypted code embedded in QR',
    pdf_path        VARCHAR(255)  DEFAULT NULL COMMENT 'static/certificates/<file>.pdf',
    qr_path         VARCHAR(255)  DEFAULT NULL COMMENT 'static/qr_codes/cert_<code>.png',
    qr_url          VARCHAR(500)  DEFAULT NULL,
    is_valid        TINYINT(1)    NOT NULL DEFAULT 1 COMMENT '0 = revoked',
    issued_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    downloaded_at   DATETIME      DEFAULT NULL,
    notified        TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'Email sent flag',

    PRIMARY KEY (cert_id),
    UNIQUE  KEY uq_cert_unique_code       (unique_code),
    UNIQUE  KEY uq_cert_player_tournament (player_id, tournament_id),
    INDEX   idx_cert_tournament           (tournament_id),
    INDEX   idx_cert_position             (position),
    INDEX   idx_cert_valid                (is_valid),
    CONSTRAINT fk_cert_player
        FOREIGN KEY (player_id)     REFERENCES players(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cert_tournament
        FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_cert_position
        CHECK (position BETWEEN 1 AND 3)
) ENGINE=InnoDB COMMENT='Achievement certificates with QR';


-- ============================================================
--  TABLE 13 — inventory
--  Sports equipment tracking  (FR-IN-01 to FR-IN-05)
-- ============================================================
CREATE TABLE inventory (
    item_id         INT           NOT NULL AUTO_INCREMENT,
    item_name       VARCHAR(100)  NOT NULL,
    sport_id        INT           DEFAULT NULL,
    total_qty       INT           NOT NULL DEFAULT 0,
    available_qty   INT           NOT NULL DEFAULT 0,
    unit            VARCHAR(20)   NOT NULL DEFAULT 'pcs',
    condition_status ENUM('good','fair','damaged','under_maintenance') NOT NULL DEFAULT 'good',
    notes           TEXT          DEFAULT NULL,
    added_by        INT           NOT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (item_id),
    INDEX idx_inv_sport      (sport_id),
    INDEX idx_inv_condition  (condition_status),
    CONSTRAINT fk_inv_sport
        FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_inv_added_by
        FOREIGN KEY (added_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_inv_qty
        CHECK (available_qty >= 0 AND available_qty <= total_qty)
) ENGINE=InnoDB COMMENT='Sports equipment inventory';


-- ============================================================
--  TABLE 14 — inventory_requests
--  Coach equipment requests  (FR-IN-02)
-- ============================================================
CREATE TABLE inventory_requests (
    req_id       INT      NOT NULL AUTO_INCREMENT,
    item_id      INT      NOT NULL,
    team_id      INT      NOT NULL,
    requested_by INT      NOT NULL,
    qty_requested INT     NOT NULL DEFAULT 1,
    qty_issued   INT      DEFAULT NULL,
    status       ENUM('pending','approved','denied','returned') NOT NULL DEFAULT 'pending',
    issued_at    DATETIME DEFAULT NULL,
    returned_at  DATETIME DEFAULT NULL,
    notes        TEXT     DEFAULT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (req_id),
    INDEX idx_invreq_item        (item_id),
    INDEX idx_invreq_team        (team_id),
    INDEX idx_invreq_status      (status),
    INDEX idx_invreq_requested_by (requested_by),
    CONSTRAINT fk_invreq_item
        FOREIGN KEY (item_id)       REFERENCES inventory(item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_invreq_team
        FOREIGN KEY (team_id)       REFERENCES teams(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_invreq_req_by
        FOREIGN KEY (requested_by)  REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Equipment borrow requests by coaches';


-- ============================================================
--  TABLE 15 — qr_logs
--  All QR scan activity  (FR-QR-06)
-- ============================================================
CREATE TABLE qr_logs (
    log_id      INT          NOT NULL AUTO_INCREMENT,
    qr_type     ENUM('player','team','tournament','match','certificate','score') NOT NULL,
    ref_id      INT          NOT NULL COMMENT 'FK value depends on qr_type',
    scanned_by  INT          DEFAULT NULL COMMENT 'NULL = anonymous public scan',
    ip_address  VARCHAR(45)  DEFAULT NULL,
    user_agent  VARCHAR(255) DEFAULT NULL,
    scanned_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (log_id),
    INDEX idx_qr_type       (qr_type),
    INDEX idx_qr_ref        (ref_id),
    INDEX idx_qr_scanned_by (scanned_by),
    INDEX idx_qr_time       (scanned_at),
    CONSTRAINT fk_qr_scanned_by
        FOREIGN KEY (scanned_by) REFERENCES users(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='QR scan activity log — all modules';


-- ============================================================
--  TABLE 16 — notifications
--  In-app and email notifications  (FR-NO-01 to FR-NO-06)
-- ============================================================
CREATE TABLE notifications (
    notif_id    INT           NOT NULL AUTO_INCREMENT,
    user_id     INT           NOT NULL,
    title       VARCHAR(150)  NOT NULL,
    message     TEXT          NOT NULL,
    type        ENUM('match_schedule','match_result','certificate_ready',
                     'team_join_request','inventory_update','broadcast') NOT NULL,
    is_read     TINYINT(1)    NOT NULL DEFAULT 0,
    email_sent  TINYINT(1)    NOT NULL DEFAULT 0,
    ref_type    VARCHAR(50)   DEFAULT NULL COMMENT 'match / tournament / certificate …',
    ref_id      INT           DEFAULT NULL,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (notif_id),
    INDEX idx_notif_user     (user_id),
    INDEX idx_notif_type     (type),
    INDEX idx_notif_is_read  (is_read),
    INDEX idx_notif_created  (created_at),
    CONSTRAINT fk_notif_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='In-app and email notifications';


-- ============================================================
--  TRIGGERS
-- ============================================================

-- TRIGGER 1: After a score is inserted → update leaderboard
DELIMITER $$
CREATE TRIGGER trg_update_leaderboard
AFTER INSERT ON scores
FOR EACH ROW
BEGIN
    DECLARE t1_id INT;
    DECLARE t2_id INT;
    DECLARE tid   INT;

    -- Fetch team IDs and tournament from the match
    SELECT team1_id, team2_id, tournament_id
    INTO   t1_id, t2_id, tid
    FROM   matches
    WHERE  match_id = NEW.match_id;

    -- Ensure both teams have a leaderboard row
    INSERT IGNORE INTO leaderboard (tournament_id, team_id)
    VALUES (tid, t1_id), (tid, t2_id);

    -- Team 1 won
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

    -- Team 2 won
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

    -- Draw (winner_team_id IS NULL)
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

    -- Mark match as completed
    UPDATE matches SET status = 'completed' WHERE match_id = NEW.match_id;
END$$
DELIMITER ;


-- TRIGGER 2: After score insert → update match status to 'live' before result (on UPDATE status)
DELIMITER $$
CREATE TRIGGER trg_match_status_live
BEFORE UPDATE ON matches
FOR EACH ROW
BEGIN
    IF NEW.status = 'live' AND OLD.status = 'scheduled' THEN
        SET NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
END$$
DELIMITER ;


-- TRIGGER 3: Prevent duplicate team-sport for a player  (FR-TM-04)
DELIMITER $$
CREATE TRIGGER trg_prevent_duplicate_sport_team
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
END$$
DELIMITER ;


-- TRIGGER 4: After inventory_request approved → reduce available_qty
DELIMITER $$
CREATE TRIGGER trg_inv_qty_on_issue
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
END$$
DELIMITER ;


-- ============================================================
--  VIEWS
-- ============================================================

-- VIEW 1: leaderboard_standings — ranked standings per tournament
CREATE OR REPLACE VIEW vw_leaderboard_standings AS
SELECT
    l.tournament_id,
    t.name                                           AS tournament_name,
    l.team_id,
    tm.team_name,
    s.sport_name,
    l.wins,
    l.losses,
    l.draws,
    l.points,
    l.goals_for,
    l.goals_against,
    (l.goals_for - l.goals_against)                  AS goal_difference,
    RANK() OVER (
        PARTITION BY l.tournament_id
        ORDER BY l.points DESC,
                 (l.goals_for - l.goals_against) DESC,
                 l.goals_for DESC
    )                                                AS `rank`
FROM leaderboard  l
JOIN tournaments  t  ON l.tournament_id = t.tournament_id
JOIN teams        tm ON l.team_id       = tm.team_id
JOIN sports       s  ON tm.sport_id     = s.sport_id;


-- VIEW 2: vw_player_summary — player profile with team and stats
CREATE OR REPLACE VIEW vw_player_summary AS
SELECT
    p.player_id,
    u.name                              AS player_name,
    u.email,
    p.reg_number,
    p.department,
    p.year,
    s.sport_name,
    p.qr_code,
    tm.team_id,
    tm.team_name,
    coach.name                          AS coach_name,
    COUNT(DISTINCT perf.match_id)       AS matches_played,
    COALESCE(SUM(perf.value), 0)        AS total_stat_value
FROM players       p
JOIN users         u     ON p.user_id    = u.user_id
JOIN sports        s     ON p.sport_id   = s.sport_id
LEFT JOIN team_players tp ON p.player_id = tp.player_id AND tp.is_active = 1
LEFT JOIN teams    tm    ON tp.team_id   = tm.team_id
LEFT JOIN users    coach ON tm.coach_id  = coach.user_id
LEFT JOIN performance perf ON p.player_id = perf.player_id
GROUP BY
    p.player_id, u.name, u.email, p.reg_number,
    p.department, p.year, s.sport_name, p.qr_code,
    tm.team_id, tm.team_name, coach.name;


-- VIEW 3: vw_match_detail — full match info for schedules and score pages
CREATE OR REPLACE VIEW vw_match_detail AS
SELECT
    m.match_id,
    m.tournament_id,
    tr.name                  AS tournament_name,
    s.sport_name,
    m.team1_id,
    t1.team_name             AS team1_name,
    m.team2_id,
    t2.team_name             AS team2_name,
    m.venue,
    m.scheduled_at,
    m.round_label,
    m.status,
    sc.team1_score,
    sc.team2_score,
    sc.winner_team_id,
    wt.team_name             AS winner_name
FROM matches        m
JOIN tournaments    tr ON m.tournament_id   = tr.tournament_id
JOIN sports         s  ON tr.sport_id       = s.sport_id
JOIN teams          t1 ON m.team1_id        = t1.team_id
JOIN teams          t2 ON m.team2_id        = t2.team_id
LEFT JOIN scores    sc ON m.match_id        = sc.match_id
LEFT JOIN teams     wt ON sc.winner_team_id = wt.team_id;


-- ============================================================
--  SEED DATA — Realistic test data for development & UAT
--  20 players · 5 teams · 3 tournaments · 15 matches
--  sample scores · certificates · inventory
-- ============================================================

-- ── Sports ──────────────────────────────────────
INSERT INTO sports (sport_name, description, max_team_size) VALUES
  ('Cricket',    'Outdoor bat-and-ball sport',          11),
  ('Football',   'Association football / soccer',       11),
  ('Basketball', 'Indoor court sport — 5 per team',      5),
  ('Volleyball', 'Indoor net sport — 6 per team',        6),
  ('Badminton',  'Racquet sport — singles and doubles',  2),
  ('Kabaddi',    'Contact sport — 7 per team',           7);


-- ── Users (Admin + Coaches) ────────────────────
-- Passwords all set to "password123" — bcrypt hash placeholder
INSERT INTO users (name, email, password, role, phone) VALUES
  ('S. Rahul',       'rahul@college.edu',      '$2b$12$adminHashPlaceholder01',  'admin',  '9876543210'),
  ('K. Balaji',      'balaji@college.edu',     '$2b$12$coachHashPlaceholder01',  'coach',  '9876543211'),
  ('R. Sunitha',     'sunitha@college.edu',    '$2b$12$coachHashPlaceholder02',  'coach',  '9876543212'),
  ('M. Tamilselvan', 'tamilselvan@college.edu','$2b$12$coachHashPlaceholder03',  'coach',  '9876543213'),
  ('M. Sathiya',     'sathiya@college.edu',    '$2b$12$coachHashPlaceholder04',  'coach',  '9876543214'),
  ('A. Sathish',     'sathish@college.edu',    '$2b$12$coachHashPlaceholder05',  'coach',  '9876543215'),
  ('P. Nikkitha',    'nikkitha@college.edu',   '$2b$12$coachHashPlaceholder06',  'coach',  '9876543216'),
  ('R. Yuga',        'yuga@college.edu',       '$2b$12$coachHashPlaceholder07',  'coach',  '9876543217');

-- Player users (user_id 9–28)
INSERT INTO users (name, email, password, role, phone) VALUES
  ('Arjun Kumar',      'arjun@college.edu',      '$2b$12$playerHash01', 'player', '9001000001'),
  ('Ravi Shankar',     'ravi.s@college.edu',     '$2b$12$playerHash02', 'player', '9001000002'),
  ('Priya Subramani',  'priya.s@college.edu',    '$2b$12$playerHash03', 'player', '9001000003'),
  ('Karthik Raj',      'karthik.r@college.edu',  '$2b$12$playerHash04', 'player', '9001000004'),
  ('Deepa Mohan',      'deepa.m@college.edu',    '$2b$12$playerHash05', 'player', '9001000005'),
  ('Vijay Anand',      'vijay.a@college.edu',    '$2b$12$playerHash06', 'player', '9001000006'),
  ('Meena Kumari',     'meena.k@college.edu',    '$2b$12$playerHash07', 'player', '9001000007'),
  ('Suresh Patel',     'suresh.p@college.edu',   '$2b$12$playerHash08', 'player', '9001000008'),
  ('Lakshmi Narayan',  'lakshmi.n@college.edu',  '$2b$12$playerHash09', 'player', '9001000009'),
  ('Arun Prasad',      'arun.p@college.edu',     '$2b$12$playerHash10', 'player', '9001000010'),
  ('Siva Kumar',       'siva.k@college.edu',     '$2b$12$playerHash11', 'player', '9001000011'),
  ('Preethi Devi',     'preethi.d@college.edu',  '$2b$12$playerHash12', 'player', '9001000012'),
  ('Manoj Selvan',     'manoj.s@college.edu',    '$2b$12$playerHash13', 'player', '9001000013'),
  ('Kaviya Rajan',     'kaviya.r@college.edu',   '$2b$12$playerHash14', 'player', '9001000014'),
  ('Dinesh Babu',      'dinesh.b@college.edu',   '$2b$12$playerHash15', 'player', '9001000015'),
  ('Nithya Sri',       'nithya.s@college.edu',   '$2b$12$playerHash16', 'player', '9001000016'),
  ('Ramesh Yadav',     'ramesh.y@college.edu',   '$2b$12$playerHash17', 'player', '9001000017'),
  ('Suganya Pillai',   'suganya.p@college.edu',  '$2b$12$playerHash18', 'player', '9001000018'),
  ('Bala Murugan',     'bala.m@college.edu',     '$2b$12$playerHash19', 'player', '9001000019'),
  ('Tharani Vel',      'tharani.v@college.edu',  '$2b$12$playerHash20', 'player', '9001000020');


-- ── Players ─────────────────────────────────────
-- dept: CSE/ECE/MECH/IT/AIDS, year: 1-4, sport_id: 1=Cricket 2=Football 3=Basketball
INSERT INTO players (user_id, sport_id, reg_number, department, year) VALUES
  (9,  1, '2022CSE001', 'CSE',  2),  -- Arjun       Cricket
  (10, 2, '2022ECE023', 'ECE',  2),  -- Ravi        Football
  (11, 3, '2023MECH007','MECH', 1),  -- Priya       Basketball
  (12, 1, '2022CSE018', 'CSE',  2),  -- Karthik     Cricket
  (13, 2, '2023ECE041', 'ECE',  1),  -- Deepa       Football
  (14, 1, '2021MECH003','MECH', 3),  -- Vijay       Cricket
  (15, 3, '2023IT010',  'IT',   1),  -- Meena       Basketball
  (16, 2, '2022IT029',  'IT',   2),  -- Suresh      Football
  (17, 1, '2021AIDS005','AIDS', 3),  -- Lakshmi     Cricket
  (18, 3, '2023CSE055', 'CSE',  1),  -- Arun        Basketball
  (19, 2, '2022MECH012','MECH', 2),  -- Siva        Football
  (20, 1, '2021ECE008', 'ECE',  3),  -- Preethi     Cricket
  (21, 3, '2023ECE066', 'ECE',  1),  -- Manoj       Basketball
  (22, 2, '2023AIDS019','AIDS', 1),  -- Kaviya      Football
  (23, 1, '2022AIDS031','AIDS', 2),  -- Dinesh      Cricket
  (24, 3, '2021CSE042', 'CSE',  3),  -- Nithya      Basketball
  (25, 2, '2021IT055',  'IT',   3),  -- Ramesh      Football
  (26, 1, '2023IT071',  'IT',   1),  -- Suganya     Cricket
  (27, 1, '2023MECH088','MECH', 1),  -- Bala        Cricket
  (28, 2, '2022CSE099', 'CSE',  2);  -- Tharani     Football


-- ── Teams ───────────────────────────────────────
INSERT INTO teams (team_name, sport_id, coach_id) VALUES
  ('CSE Warriors',  1, 2),   -- Cricket, coach Balaji
  ('ECE Eagles',    2, 3),   -- Football, coach Sunitha
  ('MECH Titans',   3, 4),   -- Basketball, coach Tamilselvan
  ('IT Spartans',   1, 5),   -- Cricket, coach Sathiya
  ('AIDS Stars',    2, 6);   -- Football, coach Sathish


-- ── Team Players ────────────────────────────────
-- CSE Warriors (Cricket) → players 1,4,6,10,12
INSERT INTO team_players (team_id, player_id, position) VALUES
  (1, 1, 'Batsman'),
  (1, 4, 'Bowler'),
  (1, 6, 'All-rounder'),
  (1, 9, 'Wicketkeeper'),
  (1,12, 'Batsman');
-- ECE Eagles (Football) → players 2,5,8,11,18
INSERT INTO team_players (team_id, player_id, position) VALUES
  (2, 2, 'Forward'),
  (2, 5, 'Midfielder'),
  (2, 8, 'Defender'),
  (2,11, 'Goalkeeper'),
  (2,18, 'Forward');
-- MECH Titans (Basketball) → players 3,7,10,13,16
INSERT INTO team_players (team_id, player_id, position) VALUES
  (3, 3,  'Center'),
  (3, 7,  'Guard'),
  (3,10,  'Forward'),
  (3,13,  'Guard'),
  (3,16,  'Center');
-- IT Spartans (Cricket) → players 17,15,19,20
INSERT INTO team_players (team_id, player_id, position) VALUES
  (4,15, 'Batsman'),
  (4,17, 'Bowler'),
  (4,19, 'All-rounder'),
  (4,20, 'Wicketkeeper');
-- AIDS Stars (Football) → players 14,22
INSERT INTO team_players (team_id, player_id, position) VALUES
  (5,14, 'Forward'),
  (5,22, 'Midfielder');


-- ── Tournaments ─────────────────────────────────
INSERT INTO tournaments (name, sport_id, format, venue, start_date, end_date, status, created_by) VALUES
  ('Inter-Dept Cricket Championship 2025',  1, 'knockout',     'Ground 1',  '2026-04-10', '2026-04-20', 'ongoing',   1),
  ('Inter-Dept Football League 2025',       2, 'round_robin',  'Ground 2',  '2026-04-12', '2026-04-22', 'ongoing',   1),
  ('Basketball Clash 2025',                 3, 'knockout',     'Court A',   '2026-04-15', '2026-04-18', 'upcoming',  1);


-- ── Matches ─────────────────────────────────────
INSERT INTO matches (tournament_id, team1_id, team2_id, venue, scheduled_at, round_label, status) VALUES
  (1, 1, 4, 'Ground 1',  '2026-04-12 10:00:00', 'Quarter Final', 'completed'),
  (1, 1, 4, 'Ground 1',  '2026-04-15 10:00:00', 'Semi Final',    'live'),
  (1, 4, 1, 'Ground 1',  '2026-04-20 14:00:00', 'Final',         'scheduled'),
  (2, 2, 5, 'Ground 2',  '2026-04-13 09:00:00', 'Round 1',       'completed'),
  (2, 2, 5, 'Ground 2',  '2026-04-15 11:00:00', 'Round 2',       'scheduled'),
  (2, 5, 2, 'Ground 2',  '2026-04-17 14:00:00', 'Round 3',       'scheduled'),
  (3, 3, 3, 'Court A',   '2026-04-16 10:00:00', 'Semi Final',    'scheduled'),
  (1, 1, 4, 'Ground 1',  '2026-04-11 09:00:00', 'Round 1',       'completed'),
  (1, 4, 1, 'Ground 1',  '2026-04-12 14:00:00', 'Round 2',       'completed'),
  (2, 2, 5, 'Ground 2',  '2026-04-14 10:00:00', 'Round 1',       'completed'),
  (2, 5, 2, 'Ground 2',  '2026-04-14 14:00:00', 'Round 2',       'completed'),
  (2, 2, 5, 'Ground 2',  '2026-04-16 09:00:00', 'Round 3',       'scheduled'),
  (3, 3, 3, 'Court A',   '2026-04-17 14:00:00', 'Final',         'scheduled'),
  (1, 1, 4, 'Ground 1',  '2026-04-13 11:00:00', 'Round 3',       'completed'),
  (2, 2, 5, 'Ground 2',  '2026-04-13 16:00:00', 'Round 1',       'completed');


-- ── Scores (completed matches) ───────────────────
INSERT INTO scores (match_id, team1_score, team2_score, winner_team_id, entered_by) VALUES
  (1,  142, 98,  1, 2),  -- CSE Warriors won
  (4,  3,   1,   2, 3),  -- ECE Eagles won
  (8,  167, 110, 1, 2),  -- CSE Warriors won
  (9,  88,  125, 4, 2),  -- IT Spartans won (team2 is actually team1 in match 9, but winner_team_id resolves)
  (10, 2,   0,   2, 3),  -- ECE Eagles won
  (11, 1,   3,   2, 3),  -- ECE Eagles won (AIDS Stars team2)
  (14, 156, 132, 1, 2),  -- CSE Warriors won
  (15, 4,   2,   2, 3);  -- ECE Eagles won


-- ── Leaderboard (auto-populated by trigger, but seed manually) ──
INSERT INTO leaderboard (tournament_id, team_id, wins, losses, draws, points, goals_for, goals_against) VALUES
  (1, 1, 3, 0, 0, 9,  465, 340),
  (1, 4, 0, 3, 0, 0,  340, 465),
  (2, 2, 5, 0, 0, 15, 12,  4),
  (2, 5, 0, 5, 0, 0,  4,   12);


-- ── Performance stats ────────────────────────────
INSERT INTO performance (player_id, match_id, stat_type, value, recorded_by) VALUES
  (1, 1, 'runs',   56, 2),
  (1, 8, 'runs',   89, 2),
  (1, 14,'runs',   67, 2),
  (4, 1, 'runs',   42, 2),
  (2, 4, 'goals',  2,  3),
  (2, 10,'goals',  1,  3),
  (2, 15,'goals',  1,  3),
  (3, 4, 'points', 18, 4);


-- ── Certificates ────────────────────────────────
INSERT INTO certificates (player_id, tournament_id, position, unique_code, is_valid) VALUES
  (1, 1, 1, 'SCSS-2025-CERT-001-GOLD',   1),
  (4, 1, 2, 'SCSS-2025-CERT-002-SILVER', 1),
  (2, 2, 1, 'SCSS-2025-CERT-003-GOLD',   1);


-- ── Inventory ────────────────────────────────────
INSERT INTO inventory (item_name, sport_id, total_qty, available_qty, condition_status, added_by) VALUES
  ('Cricket Ball',    1, 24, 18, 'good',    1),
  ('Cricket Bat',     1, 14, 10, 'fair',    1),
  ('Cricket Wicket',  1,  6,  6, 'good',    1),
  ('Football',        2, 12,  6, 'good',    1),
  ('Football Goal',   2,  4,  4, 'good',    1),
  ('Basketball',      3,  8,  2, 'damaged', 1),
  ('Basketball Hoop', 3,  2,  2, 'good',    1),
  ('Volleyball',      4,  6,  6, 'good',    1),
  ('Badminton Racket',5, 10,  8, 'fair',    1),
  ('Shuttlecock Pack',5, 20, 15, 'good',    1),
  ('Kabaddi Mat',     6,  2,  2, 'good',    1),
  ('First Aid Kit',NULL,  4,  3, 'good',    1);


-- ── Sample Notifications ─────────────────────────
INSERT INTO notifications (user_id, title, message, type, is_read, email_sent) VALUES
  (9,  'Match Scheduled',          'Your match vs IT Spartans is on Apr 15 at 10:00 AM, Ground 1.', 'match_schedule', 0, 1),
  (9,  'Certificate Ready',        'Your Gold certificate for Cricket Championship 2025 is ready for download.', 'certificate_ready', 0, 1),
  (10, 'Match Result Published',   'ECE Eagles won 3–1 vs AIDS Stars. Leaderboard updated.',          'match_result', 1, 1),
  (1,  'Inventory Alert',          'Basketball stock critically low — only 2 units available.',        'inventory_update', 0, 0),
  (9,  'Match Result Published',   'CSE Warriors won 142–98 vs IT Spartans.',                          'match_result', 1, 1);


-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
--  USEFUL ADMIN QUERIES  (reference for backend developers)
-- ============================================================

-- 1. Leaderboard for tournament 1
-- SELECT * FROM vw_leaderboard_standings WHERE tournament_id = 1 ORDER BY `rank`;

-- 2. Full match schedule with scores
-- SELECT * FROM vw_match_detail WHERE tournament_id = 1;

-- 3. Player summary — all players in CSE
-- SELECT * FROM vw_player_summary WHERE department = 'CSE';

-- 4. Unread notifications for user 9
-- SELECT * FROM notifications WHERE user_id = 9 AND is_read = 0 ORDER BY created_at DESC;

-- 5. Pending inventory requests
-- SELECT ir.*, i.item_name, t.team_name FROM inventory_requests ir
-- JOIN inventory i ON ir.item_id = i.item_id
-- JOIN teams t ON ir.team_id = t.team_id
-- WHERE ir.status = 'pending';

-- 6. Verify certificate by unique_code
-- SELECT c.*, p.reg_number, u.name, t.name AS tournament FROM certificates c
-- JOIN players p ON c.player_id = p.player_id
-- JOIN users u ON p.user_id = u.user_id
-- JOIN tournaments t ON c.tournament_id = t.tournament_id
-- WHERE c.unique_code = 'SCSS-2025-CERT-001-GOLD' AND c.is_valid = 1;

-- 7. QR scan log last 24 hours
-- SELECT * FROM qr_logs WHERE scanned_at >= NOW() - INTERVAL 1 DAY ORDER BY scanned_at DESC;

-- ============================================================
--  END OF SCHEMA  —  sports_db  |  SRS v1.0
-- ============================================================
