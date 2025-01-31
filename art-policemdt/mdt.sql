CREATE TABLE IF NOT EXISTS `mdt_wanted` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50),
    `reason` TEXT,
    `added_by` VARCHAR(50),
    `added_date` DATETIME,
    `danger_level` VARCHAR(20),
    `img_url` TEXT,
    `is_profile_pic` BOOLEAN DEFAULT FALSE,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_profile_pic` (`is_profile_pic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Yeni sabıka kayıtları tablosu
CREATE TABLE IF NOT EXISTS `mdt_criminal_records` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50),
    `offense` TEXT,
    `date` VARCHAR(50),
    `officer` VARCHAR(100),
    `added_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Eğer tablo zaten varsa is_profile_pic kolonunu ekle
ALTER TABLE `mdt_wanted` 
ADD COLUMN IF NOT EXISTS `is_profile_pic` BOOLEAN DEFAULT FALSE,
ADD INDEX IF NOT EXISTS `idx_citizenid` (`citizenid`),
ADD INDEX IF NOT EXISTS `idx_profile_pic` (`is_profile_pic`); 