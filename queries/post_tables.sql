-- tbl_post
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


-- tbl_author
CREATE TABLE if not exists `tbl_author` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Post` INT not null,
  `ID_UserAccount` INT not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);


-- tbl_tag
CREATE TABLE if not exists `tbl_tag` (
  `ID_Tag` INT auto_increment,
  `TagName` VARCHAR(255) not null,
  PRIMARY KEY (`ID_Tag`)
);


-- tbl_tag_post
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


-- tbl_save_post
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


-- tbl_read_post
CREATE TABLE if not exists `tbl_read_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT not null,
  `ID_Post` INT not null,
  `ReadDate` TIMESTAMP not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);

-- tbl_comment
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


-- tbl_like
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

CREATE TABLE if not exists `tbl_like_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT not null,
  `ID_Post` INT not null,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE if not exists `tbl_like_comment` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT not null,
  `ID_Comment` INT not null,
  FOREIGN KEY (`ID_Comment`) REFERENCES `tbl_comment`(`ID_Comment`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);
