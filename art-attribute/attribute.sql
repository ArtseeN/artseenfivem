CREATE TABLE IF NOT EXISTS character_attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    attributes TEXT NULL,
    UNIQUE KEY unique_citizen (citizenid),
    INDEX idx_citizenid (citizenid)
); 