
--
-- Database: `dbcomandaof1`
--

-- --------------------------------------------------------

--
-- tbl_user
--
CREATE TABLE if not exists `tbl_user` (
  `ID_User` INT AUTO_INCREMENT, -- Primary key
  `Firstname` VARCHAR(255) not null ,
  `Lastname` VARCHAR(255) not null ,
  `Gender` ENUM('Male', 'Female', 'Other') not null , -- Gender enum
  `Birthdate` DATE,
  `Age` INT, -- Derived attribute (not stored directly)
  PRIMARY KEY (`ID_User`)
);

DELIMITER //
CREATE TRIGGER calculate_age_before_insert
    BEFORE INSERT ON tbl_user
    FOR EACH ROW
BEGIN
    SET NEW.Age = TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE());
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER calculate_age_before_update
    BEFORE UPDATE ON tbl_user
    FOR EACH ROW
BEGIN
    SET NEW.Age = TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE());
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_account
--
CREATE TABLE if not exists `tbl_account` (
  `ID_Account` INT AUTO_INCREMENT, -- Primary key
  `Username` VARCHAR(255) not null ,
  `Email` VARCHAR(255) UNIQUE not null,
  `Password` VARCHAR(255) not null,
  `UserType` ENUM('Regular', 'Admin') DEFAULT 'Regular' not null, -- UserType enum
  `CreateTime` TIMESTAMP,
  `IsActive` BOOLEAN DEFAULT true,
  PRIMARY KEY (`ID_Account`)
);

-- --------------------------------------------------------

--
-- tbl_user_account
--
CREATE TABLE if not exists `tbl_user_account` (
  `ID_UserAccount` INT AUTO_INCREMENT, -- Primary key
  `ID_User` INT,
  `ID_Account` INT,
  `TotalPosts` INT DEFAULT 0,
  `TotalLikes` INT DEFAULT 0,
  `TotalReads` INT DEFAULT 0,
  `Bio` TINYTEXT DEFAULT '',
  FOREIGN KEY (`ID_User`) REFERENCES `tbl_user`(`ID_User`),
  FOREIGN KEY (`ID_Account`) REFERENCES `tbl_account`(`ID_Account`),
  PRIMARY KEY (`ID_UserAccount`)
);

-- --------------------------------------------------------

--
-- tbl_post
--
CREATE TABLE if not exists `tbl_post` (
  `ID_Post` INT AUTO_INCREMENT, -- Primary key
  `Title` VARCHAR(255) not null,
  `Content` TEXT not null,
  `PhotoURL` VARCHAR(255),
  `PostDate` DATETIME not null,
  `UpdateDate` DATETIME not null,
  `ReadCount` INT default 0,
  `ReactCount` INT default 0,
  `CommentCount` INT default 0,
  `IsActive` BOOLEAN default true,
  PRIMARY KEY (`ID_Post`)
);

DELIMITER //
CREATE TRIGGER log_time_before_insert_post
    BEFORE INSERT ON tbl_post
    FOR EACH ROW
BEGIN
    SET NEW.PostDate = CURRENT_TIMESTAMP,
        NEW.UpdateDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER log_time_before_update_post
    BEFORE UPDATE ON tbl_post
    FOR EACH ROW
BEGIN
    SET NEW.UpdateDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_author
--
CREATE TABLE if not exists `tbl_author` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Post` INT not null,
  `ID_UserAccount` INT not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_tag
--
CREATE TABLE if not exists `tbl_tag` (
  `ID_Tag` INT auto_increment,
  `TagName` VARCHAR(255) not null,
  PRIMARY KEY (`ID_Tag`)
);

-- --------------------------------------------------------

--
-- tbl_tag_post
--
CREATE TABLE if not exists `tbl_tag_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `ID_Tag` INT not null,
  `TagDate` TIMESTAMP not null,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_author`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Tag`) REFERENCES `tbl_tag`(`ID_Tag`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

DELIMITER //
CREATE TRIGGER log_time_before_tag_post
    BEFORE INSERT ON tbl_tag_post
    FOR EACH ROW
BEGIN
    SET NEW.TagDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_save_post
--
CREATE TABLE if not exists `tbl_save_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `SaveDate` TIMESTAMP not null,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

DELIMITER //
CREATE TRIGGER log_time_before_save_post
    BEFORE INSERT ON tbl_save_post
    FOR EACH ROW
BEGIN
    SET NEW.SaveDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_read_post
--
CREATE TABLE if not exists `tbl_read_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `ReadDate` TIMESTAMP not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_comment
--
CREATE TABLE if not exists `tbl_comment` (
  `ID_Comment` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `Content` TEXT not null,
  `CommentDate` DATETIME not null,
  `UpdateDate` DATETIME not null,
  `ReactCount` INT default 0,
  `IsActive` BOOLEAN default true, -- IsActive enum
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`ID_Comment`)
);

DELIMITER //
CREATE TRIGGER log_time_before_insert_comment
    BEFORE INSERT ON tbl_comment
    FOR EACH ROW
BEGIN
    SET NEW.CommentDate = CURRENT_TIMESTAMP,
        NEW.UpdateDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER log_time_before_update_comment
    BEFORE UPDATE ON tbl_comment
    FOR EACH ROW
BEGIN
    SET NEW.UpdateDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_like
--
CREATE TABLE if not exists `tbl_like` (
  `ID_Like` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `LikeDate` TIMESTAMP not null,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`ID_Like`)
);

DELIMITER //
CREATE TRIGGER log_time_before_send_like
    BEFORE INSERT ON tbl_like
    FOR EACH ROW
BEGIN
    SET NEW.LikeDate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

-- --------------------------------------------------------

--
-- tbl_like_post
--
CREATE TABLE if not exists `tbl_like_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT not null,
  `ID_Post` INT not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_like_comment
--

CREATE TABLE if not exists `tbl_like_comment` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT not null,
  `ID_Comment` INT not null,
  FOREIGN KEY (`ID_Comment`) REFERENCES `tbl_comment`(`ID_Comment`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_admin_account
--
CREATE TABLE if not exists `tbl_admin_account` (
  `ID_Admin` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`ID_Admin`)
);

-- --------------------------------------------------------

--
-- tbl_user_statistics
--
CREATE TABLE if not exists `tbl_user_statistics` (
  `ID_UserStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `UserAccCount` INT, -- Derived attribute (taken from the count of UserAccount)
  `AvePostPerUser` DECIMAL, -- Derived attribute (taken from the sum of TotalPosts divided by count of UserAccount)
  `AveLikesPerUser` DECIMAL, -- Derived attribute (taken from the sum of TotalLikes divided by count of UserAccount)
  PRIMARY KEY (`ID_UserStatistics`)
);

-- --------------------------------------------------------

--
-- tbl_post_statistics
--
CREATE TABLE if not exists `tbl_post_statistics` (
  `ID_PostStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `PostCount` INT, -- Derived attribute (taken from the count of Post)
  `AveLikesPerPost` DECIMAL, -- Derived attribute (taken from the sum of ReactCount divided by count of Post)
  `AveComments` DECIMAL, -- Derived attribute (taken from the sum of CommentCount divided by count of Post)
  PRIMARY KEY (`ID_PostStatistics`)
);

-- --------------------------------------------------------

--
-- tbl_site_statistics
--
CREATE TABLE if not exists `tbl_site_statistics` (
  `ID_SiteStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `ID_UserStatistics` INT,
  `ID_PostStatistics` INT,
  FOREIGN KEY (`ID_PostStatistics`) REFERENCES `tbl_post_statistics`(`ID_PostStatistics`),
  FOREIGN KEY (`ID_UserStatistics`) REFERENCES `tbl_user_statistics`(`ID_UserStatistics`),
  PRIMARY KEY (`ID_SiteStatistics`)
);

-- --------------------------------------------------------

--
-- tbl_read_site_statistics
--
CREATE TABLE if not exists `tbl_read_site_statistics` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Admin` INT,
  `ID_SiteStatistics` INT,
  `readDate` TIMESTAMP,
  FOREIGN KEY (`ID_Admin`) REFERENCES `tbl_admin_account`(`ID_Admin`),
  FOREIGN KEY (`ID_SiteStatistics`) REFERENCES `tbl_site_statistics`(`ID_SiteStatistics`),
  PRIMARY KEY (`sequence_no`)
);
