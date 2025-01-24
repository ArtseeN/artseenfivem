CREATE TABLE IF NOT EXISTS `jail_data` (
  `citizenid` VARCHAR(255) NOT NULL,
  `license` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `jail_time` INT NOT NULL,
  `reason` VARCHAR(255),
  PRIMARY KEY (`citizenid`)
);
