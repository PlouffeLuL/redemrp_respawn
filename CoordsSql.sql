CREATE TABLE `coords` (
	`staticid` varchar(22) NOT NULL,
	`identifier` varchar(22) NOT NULL,
	`characterid` TINYINT(11) NOT NULL,
	`coords` longtext NOT NULL,

	PRIMARY KEY (`staticid`)
);

