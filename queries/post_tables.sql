
--
-- Database: `dbcomandaof1`
--

-- --------------------------------------------------------

--
-- tbl_post
--
CREATE TABLE if not exists `tbl_post` (
  `ID_Post` INT AUTO_INCREMENT, -- Primary key
  `Title` VARCHAR(255) not null,
  `Content` TEXT not null,
  `PhotoURL` VARCHAR(255),
  `PostDate` DATETIME not null default CURRENT_TIMESTAMP,
  `UpdateDate` DATETIME not null default CURRENT_TIMESTAMP,
  `ReadCount` INT default 0 not null,
  `ReactCount` INT default 0 not null,
  `CommentCount` INT default 0 not null,
  `IsActive` BOOLEAN default true,
  PRIMARY KEY (`ID_Post`)
);

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
CREATE TABLE IF NOT EXISTS `tbl_author` (
  `sequence_no` INT AUTO_INCREMENT,
  `ID_Post` INT NOT NULL,
  `ID_UserAccount` INT NOT NULL,
  PRIMARY KEY (`sequence_no`, `ID_Post`, `ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`)
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
  `TagDate` TIMESTAMP not null default CURRENT_TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_author`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Tag`) REFERENCES `tbl_tag`(`ID_Tag`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_save_post
--
CREATE TABLE if not exists `tbl_save_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `SaveDate` TIMESTAMP not null default CURRENT_TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

-- --------------------------------------------------------

--
-- tbl_read_post
--
CREATE TABLE if not exists `tbl_read_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `ReadDate` TIMESTAMP not null default CURRENT_TIMESTAMP,
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
  `CommentDate` DATETIME not null default CURRENT_TIMESTAMP,
  `UpdateDate` DATETIME not null default CURRENT_TIMESTAMP,
  `ReactCount` INT default 0,
  `IsActive` BOOLEAN default true, -- IsActive enum
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`ID_Comment`)
);

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
  `LikeDate` TIMESTAMP not null default CURRENT_TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`ID_Like`)
);

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
