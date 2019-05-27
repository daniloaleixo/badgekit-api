DROP TABLE IF EXISTS `milestoneBadges`;
DROP TABLE IF EXISTS `milestones`;
DROP TABLE IF EXISTS `reviewItems`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `evidence`;
DROP TABLE IF EXISTS `applications`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `criteria`;
DROP TABLE IF EXISTS `images`;
DROP TABLE IF EXISTS `badgeInstances`;
DROP TABLE IF EXISTS `claimCodes`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `badges`;
DROP TABLE IF EXISTS `programs`;
DROP TABLE IF EXISTS `issuers`;
DROP TABLE IF EXISTS `webhooks`;
DROP TABLE IF EXISTS `systems`;
DROP TABLE IF EXISTS `consumers`;


                  CREATE TABLE IF NOT EXISTS `consumers` (
                  `id` INT AUTO_INCREMENT PRIMARY KEY,
                  `apiKey` VARCHAR(255) NOT NULL UNIQUE,
                  `apiSecret` VARCHAR(255) NOT NULL,
                  `description` VARCHAR(255) NULL,
                  `systemId` INT NOT NULL REFERENCES `systems`(`id`) 
                  );


                  CREATE TABLE IF NOT EXISTS `systems` (
                  id INT AUTO_INCREMENT PRIMARY KEY,
                  slug VARCHAR(255) NOT NULL UNIQUE, 
                  name VARCHAR(255) NOT NULL, 
                  url VARCHAR(255) NOT NULL, 
                  description TEXT NULL, 
                  email VARCHAR(255) NULL, 
                  imageId INT NULL REFERENCES `images`(`id`) 
                  );


                  CREATE TABLE IF NOT EXISTS `webhooks` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  url VARCHAR(255) NOT NULL, 
                  secret VARCHAR(255) NOT NULL, 
                  systemId INT NOT NULL REFERENCES `systems`(`id`), 
                  UNIQUE KEY `url_and_system` (`url`, `systemId`));


                  CREATE TABLE IF NOT EXISTS `issuers` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  slug       VARCHAR(255) NOT NULL, 
                  name       VARCHAR(255) NOT NULL, 
                  url        VARCHAR(255) NOT NULL, 
                  description    TEXT NULL, 
                  UNIQUE KEY `slug_and_system` (`slug`, `systemId`),
                  email      VARCHAR(255) NULL, 
                  imageId      INT NULL REFERENCES `images`(`id`), 
                  systemId     INT NULL REFERENCES `systems`(`id`));


                  CREATE TABLE IF NOT EXISTS `programs` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  slug VARCHAR(255) NOT NULL, 
                  name VARCHAR(255) NOT NULL, 
                  url VARCHAR(255) NOT NULL, 
                  description TEXT NULL, 
                  email VARCHAR(255) NULL, 
                  imageId INT NULL REFERENCES `images`(`id`), 
                  issuerId INT NULL REFERENCES `issuers`(`id`), 
                  UNIQUE KEY `slug_and_issuer` (`slug`, `issuerId`));


                  CREATE TABLE IF NOT EXISTS `badges` (
                  `id`               INT AUTO_INCREMENT PRIMARY KEY,
                  `slug`       VARCHAR(255) NOT NULL, 
                  `name`       VARCHAR(255) NOT NULL, 
                  `strapline`    VARCHAR(140) NULL, 
                  `earnerDescription` TEXT NOT NULL, 
                  `consumerDescription` TEXT NOT NULL, 
                  `issuerUrl`    VARCHAR(255), 
                  `rubricUrl`    VARCHAR(255), 
                  `criteriaUrl`    VARCHAR(255) NOT NULL, 
                  `timeValue`    INT, 
                  `timeUnits`    ENUM('minutes', 'hours', 'days', 'weeks'), 
                  `limit`      INT, 
                  UNIQUE KEY `slug_and_system` (`slug`, `systemId`), 
                  UNIQUE KEY `slug_and_issuer` (`slug`, `issuerId`), 
                  UNIQUE KEY `slug_and_program` (`slug`, `programId`), 
                  `unique`       BOOLEAN NOT NULL DEFAULT FALSE, 
                  `archived`     BOOLEAN NOT NULL DEFAULT FALSE, 
                  `created`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
                  `imageId`      INT NOT NULL REFERENCES `images`(`id`), 
                  `programId`    INT NULL REFERENCES `programs`(`id`), 
                  `issuerId`     INT NULL REFERENCES `issuers`(`id`), 
                  `systemId`     INT NULL REFERENCES `systems`(`id`), 
                  `type`       VARCHAR(255) NOT NULL );


                  CREATE TABLE IF NOT EXISTS `categories` (
                  `id`               INT AUTO_INCREMENT PRIMARY KEY,
                  `badgeId`      INT NOT NULL REFERENCES `badges`(`id`), 
                  `value`      VARCHAR(255) NOT NULL );


                  CREATE TABLE IF NOT EXISTS `claimCodes` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  code       VARCHAR(255) NOT NULL, 
                  claimed      BOOLEAN NOT NULL DEFAULT FALSE, 
                  email      VARCHAR(255) NULL, 
                  multiuse     BOOLEAN NOT NULL DEFAULT FALSE, 
                  badgeId      INT NOT NULL REFERENCES `badges`(`id`), 
                  UNIQUE KEY     `code_and_badge` (`code`, `badgeId`) );


                  CREATE TABLE IF NOT EXISTS `badgeInstances` (
                  `id`               INT AUTO_INCREMENT PRIMARY KEY,
                  `slug`       VARCHAR(255) NOT NULL UNIQUE, 
                  `email`      VARCHAR(255) NOT NULL, 
                  `issuedOn`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
                  `expires`      TIMESTAMP NULL, 
                  `claimCode`    VARCHAR(255) NULL, 
                  `badgeId`     INT NOT NULL REFERENCES `badges`(`id`), 
                  UNIQUE KEY     `email_and_badge` (`email`, `badgeId`) );


                  CREATE TABLE IF NOT EXISTS `images` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  slug       VARCHAR(255) NOT NULL UNIQUE, 
                  url        VARCHAR(255), 
                  mimetype     VARCHAR(255), 
                  data       LONGBLOB );


                  CREATE TABLE IF NOT EXISTS `criteria` (
                  id               INT AUTO_INCREMENT PRIMARY KEY,
                  badgeId      INT NOT NULL REFERENCES `badges`(`id`), 
                  description    TEXT NOT NULL, 
                  note       TEXT NOT NULL, 
                  required     BOOL NOT NULL DEFAULT FALSE );





                  -- 
                  -- 

                CREATE TABLE IF NOT EXISTS `tags` (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                badgeId      INT NOT NULL, 
                value      VARCHAR(255) NOT NULL 
                );
            
                CREATE TABLE IF NOT EXISTS `applications` (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                slug VARCHAR(255) NOT NULL, 
                badgeId INT NOT NULL REFERENCES `badges`(`id`), 
                learner VARCHAR(255) NOT NULL, 
                created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
                assignedTo VARCHAR(255) NULL, 
                assignedExpiration TIMESTAMP NULL, 
                processed TIMESTAMP NULL, 
                programId INT NULL REFERENCES `programs`(`id`), 
                issuerId INT NULL REFERENCES `issuers`(`id`), 
                systemId INT NULL REFERENCES `systems`(`id`) 
                );
            
                CREATE TABLE IF NOT EXISTS `evidence` (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                applicationId  INT NOT NULL REFERENCES `applications`(`id`), 
                url        VARCHAR(255) NULL, 
                mediaType    ENUM('image', 'link') NULL, 
                reflection     TEXT NULL 
                );
            
                CREATE TABLE IF NOT EXISTS `reviews` (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                slug       VARCHAR(255) NOT NULL, 
                applicationId  INT NOT NULL REFERENCES applications(id), 
                author       VARCHAR(255) NOT NULL, 
                comment      TEXT NULL 
                );
            
                CREATE TABLE IF NOT EXISTS `milestones` (
                `id`               INT AUTO_INCREMENT,
                `systemId`     INT NOT NULL, 
                `primaryBadgeId`   INT NOT NULL, 
                `numberRequired`   INT NOT NULL, 
                `action`       ENUM('issue', 'queue-application') DEFAULT 'issue', 
                PRIMARY KEY (`id`), 
                FOREIGN KEY (`systemId`) 
                  REFERENCES `systems`(`id`) 
                  ON DELETE CASCADE 
                  ON UPDATE CASCADE, 
                FOREIGN KEY (`primaryBadgeId`) 
                  REFERENCES `badges`(`id`) 
                  ON DELETE CASCADE 
                  ON UPDATE CASCADE 
                );
            
                CREATE TABLE IF NOT EXISTS `reviewItems` (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                reviewId     INT NOT NULL REFERENCES `reviews`(`id`), 
                criterionId    INT NOT NULL REFERENCES `criteria`(`id`), 
                satisfied    BOOLEAN NOT NULL DEFAULT FALSE, 
                comment      TEXT NULL 
                );
           
                CREATE TABLE IF NOT EXISTS `milestoneBadges` (
                id               INT AUTO_INCREMENT,
                milestoneId INT NOT NULL, 
                badgeId INT NOT NULL, 
                PRIMARY KEY (`id`), 
                UNIQUE KEY `milestone_and_badge` (`milestoneId`, `badgeId`), 
                FOREIGN KEY (`milestoneId`) 
                REFERENCES `milestones`(`id`) 
                  ON DELETE CASCADE 
                  ON UPDATE CASCADE, 
                FOREIGN KEY (`badgeId`) 
                  REFERENCES `badges`(`id`) 
                  ON DELETE CASCADE 
                  ON UPDATE CASCADE 
                );