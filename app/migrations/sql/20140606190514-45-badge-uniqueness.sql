
ALTER TABLE `badges` ADD UNIQUE KEY `slug` (`slug`);


    ALTER TABLE `badges` 
                  DROP KEY `slug_and_system`,
                  DROP KEY `slug_and_issuer`,
                  DROP KEY `slug_and_program`;



ALTER TABLE `badges` 
                    DROP KEY slug;


ALTER TABLE `issuers` 
                    ADD UNIQUE KEY `slug_and_system` (`slug`, `systemId`);



ALTER TABLE `badges` 
                    ADD UNIQUE KEY `slug_and_system` (`slug`, `systemId`), 
                    ADD UNIQUE KEY `slug_and_issuer` (`slug`, `issuerId`), 
                    ADD UNIQUE KEY `slug_and_program` (`slug`, `programId`) ;
