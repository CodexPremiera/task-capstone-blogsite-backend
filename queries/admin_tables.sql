
--
-- Database: `dbcomandaof1`
--

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
