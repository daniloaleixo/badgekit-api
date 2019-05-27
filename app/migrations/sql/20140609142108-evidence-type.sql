


  ALTER TABLE `badges` ADD `evidenceType` ENUM('URL', 'Text', 'Photo', 'Video', 'Sound');

  ALTER TABLE `badges`  DROP COLUMN `evidenceType`;
