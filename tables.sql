CREATE TABLE `tbl_user` (
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

CREATE TABLE `tbl_account` (
  `ID_Account` INT AUTO_INCREMENT, -- Primary key
  `Username` VARCHAR(255) not null ,
  `Email` VARCHAR(255) UNIQUE not null,
  `Password` VARCHAR(255) not null,
  `UserType` ENUM('Regular', 'Admin') DEFAULT 'Regular' not null, -- UserType enum
  `CreateTime` TIMESTAMP,
  `IsActive` BOOLEAN DEFAULT true,
  PRIMARY KEY (`ID_Account`)
);



CREATE TABLE `tbl_user_account` (
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

CREATE TABLE `tbl_post` (
  `ID_Post` INT AUTO_INCREMENT, -- Primary key
  `Title` VARCHAR(255),
  `Content` TEXT,
  `PhotoURL` VARCHAR(255),
  `PostDate` TIMESTAMP,
  `UpdateDate` TIMESTAMP,
  `ReadCount` INT,
  `ReactCount` INT,
  `CommentCount` INT,
  `IsActive` BOOLEAN,
  PRIMARY KEY (`ID_Post`)
);

CREATE TABLE `tbl_author` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Post` INT,
  `ID_UserAccount` INT,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_tag` (
  `ID_Tag` INT,
  `TagName` VARCHAR(255),
  PRIMARY KEY (`ID_Tag`)
);

CREATE TABLE `tbl_tag_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  `ID_Post` INT,
  `ID_Tag` INT,
  `TagDate` TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_author`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Tag`) REFERENCES `tbl_tag`(`ID_Tag`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_save_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  `ID_Post` INT,
  `SaveDate` TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_read_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  `ID_Post` INT,
  `ReadDate` TIMESTAMP,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_comment` (
  `ID_Comment` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  `ID_Post` INT,
  `Content` TEXT,
  `CommentDate` DATETIME,
  `UpdateDate` DATETIME,
  `ReactCount` INT,
  `IsActive` ENUM('Type1', 'Type2'), -- IsActive enum
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  PRIMARY KEY (`ID_Comment`)
);

CREATE TABLE `tbl_like` (
  `ID_Like` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  `LikeDate` TIMESTAMP,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`ID_Like`)
);

CREATE TABLE `tbl_like_post` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT,
  `ID_Post` INT,
  FOREIGN KEY (`ID_Post`) REFERENCES `tbl_post`(`ID_Post`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_like_comment` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Like` INT,
  `ID_Comment` INT,
  FOREIGN KEY (`ID_Comment`) REFERENCES `tbl_comment`(`ID_Comment`),
  FOREIGN KEY (`ID_Like`) REFERENCES `tbl_like`(`ID_Like`),
  PRIMARY KEY (`sequence_no`)
);

CREATE TABLE `tbl_admin_account` (
  `ID_Admin` INT AUTO_INCREMENT, -- Primary key
  `ID_UserAccount` INT,
  FOREIGN KEY (`ID_UserAccount`) REFERENCES `tbl_user_account`(`ID_UserAccount`),
  PRIMARY KEY (`ID_Admin`)
);

CREATE TABLE `tbl_user_statistics` (
  `ID_UserStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `UserAccCount` INT, -- Derived attribute (taken from the count of UserAccount)
  `AvePostPerUser` DECIMAL, -- Derived attribute (taken from the sum of TotalPosts divided by count of UserAccount)
  `AveLikesPerUser` DECIMAL, -- Derived attribute (taken from the sum of TotalLikes divided by count of UserAccount)
  PRIMARY KEY (`ID_UserStatistics`)
);

CREATE TABLE `tbl_post_statistics` (
  `ID_PostStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `PostCount` INT, -- Derived attribute (taken from the count of Post)
  `AveLikesPerPost` DECIMAL, -- Derived attribute (taken from the sum of ReactCount divided by count of Post)
  `AveComments` DECIMAL, -- Derived attribute (taken from the sum of CommentCount divided by count of Post)
  PRIMARY KEY (`ID_PostStatistics`)
);

CREATE TABLE `tbl_site_statistics` (
  `ID_SiteStatistics` INT AUTO_INCREMENT, -- Primary key
  `DateOfRecord` DATE,
  `ID_UserStatistics` INT,
  `ID_PostStatistics` INT,
  FOREIGN KEY (`ID_PostStatistics`) REFERENCES `tbl_post_statistics`(`ID_PostStatistics`),
  FOREIGN KEY (`ID_UserStatistics`) REFERENCES `tbl_user_statistics`(`ID_UserStatistics`),
  PRIMARY KEY (`ID_SiteStatistics`)
);

CREATE TABLE `tbl_read_site_statistics` (
  `sequence_no` INT AUTO_INCREMENT, -- Primary key
  `ID_Admin` INT,
  `ID_SiteStatistics` INT,
  `readDate` TIMESTAMP,
  FOREIGN KEY (`ID_Admin`) REFERENCES `tbl_admin_account`(`ID_Admin`),
  FOREIGN KEY (`ID_SiteStatistics`) REFERENCES `tbl_site_statistics`(`ID_SiteStatistics`),
  PRIMARY KEY (`sequence_no`)
);