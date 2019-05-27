DROP TABLE IF EXISTS `alignments`;


CREATE TABLE IF NOT EXISTS `alignments` (
                      id INT AUTO_INCREMENT PRIMARY KEY, 
                      badgeId INT NOT NULL REFERENCES `badges`(`id`), 
                      name TEXT NOT NULL, 
                      url TEXT NOT NULL, 
                      description TEXT );
                  
