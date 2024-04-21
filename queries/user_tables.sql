
-- tbl_user
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

-- tbl_account
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

-- tbl_user_account
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
