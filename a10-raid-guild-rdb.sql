-- 
-- MySQL CREATE TABLE SCRIPT
-- Aaron Gutierrez
-- Israel Torres
-- Brandon Whitney
-- 
-- CECS 323
-- December 10, 2013
-- 
-- Assignment #10
-- 
-- Guild Raid Request Database
-- 
DROP TABLE equipmentStatistics;
DROP TABLE equipments;
DROP TABLE consumables;
DROP TABLE characterStatistics;
DROP TABLE statistics;
DROP TABLE equipmentSlots;
DROP TABLE equipmentTypes;
DROP TABLE characterItems;
DROP TABLE raidItems;
DROP TABLE items;
DROP TABLE requests;
DROP TABLE raids;
DROP TABLE characters;
DROP TABLE characterLevels;
DROP TABLE guilds;
DROP TABLE players;
DROP TABLE professions;
DROP TABLE factions;
DROP TABLE timeZones;

-- level: integer making sure that players can only level up to 100
-- PK: This is an enumerated list requiring only levelId, to reduce repetition of data
CREATE TABLE characterLevels
(
	level integer NOT NULL,
	CONSTRAINT characterLevel_PK PRIMARY KEY (level)
);

-- timeZone: varchar as it stores characters and numbers with a max of 3, i.e. +12
-- PK: This is an enumerated list requiring only timeZoneId, to reduce repetition of data
CREATE TABLE timeZones
(
	timeZoneId integer NOT NULL AUTO_INCREMENT,
	timeZone varchar(3) NOT NULL,
	CONSTRAINT timeZones_PK PRIMARY KEY (timeZoneID)
);

-- factionName: Factions are predetermined with a name up to 8 characters
-- PK: This is an enumerated list requiring only factionId, to reduce repetition of data
CREATE TABLE factions
(
	factionId integer NOT NULL AUTO_INCREMENT,
	factionName varchar(8) NOT NULL,
	CONSTRAINT factions_PK PRIMARY KEY (factionID)
);


-- professions: Professions are predetermined with a name up to 12 characters
-- PK: This is an enumerated list requiring only professionId, to reduce repetition of data
CREATE TABLE professions
(
	professionId integer NOT NULL AUTO_INCREMENT,
	profession varchar(12) NOT NULL,
	CONSTRAINT profession_PK PRIMARY KEY (professionId)
);

-- equipmentTypeName: Equipment Types are predetermined with a name up to 20 characters
-- PK: This is an enumerated list requiring only equipmentTypeId, to reduce repetition of data
CREATE TABLE equipmentTypes
(
	equipmentTypeId integer NOT NULL AUTO_INCREMENT,
	equipmentTypeName varchar(20) NOT NULL,
	CONSTRAINT equipmentTypes_PK PRIMARY KEY (equipmentTypeId)
);

-- equipmentSlots: Equipment slots are predetermined with a name up to 15 characters
-- PK: This is an enumerated list requiring only equipmentSlotId
CREATE TABLE equipmentSlots
(
	equipmentSlotId integer NOT NULL AUTO_INCREMENT,
	equipmentSlotName varchar(15) NOT NULL,
	CONSTRAINT equipmentSlots_PK PRIMARY KEY (equipmentSlotId)
);

-- guildName: varchar allows any characters to create a guild name i.e. H4ck3rs3liteUni73
-- faction: integer pointing to a PK, allows NULL if the PK is deleted from the enumerated table
-- PK: A surrogate key to reduce repetition of long guild names in referenced tables
-- CK: Guilds are uniquely identified by their guild names
-- FK: References a faction from an enumerated list, ON DELETE SET NULL beacuse we want to still have a guild even
--     if the faction is removed, and ON UPDATE CASCADE to keep the reference to a faction intact
CREATE TABLE guilds
(
	guildId integer NOT NULL AUTO_INCREMENT,
	guildName varchar(50) NOT NULL,
	faction integer,
	CONSTRAINT guilds_PK PRIMARY KEY (guildID),
	CONSTRAINT guild_CK UNIQUE (guildName),
	CONSTRAINT faction_FK FOREIGN KEY (faction) REFERENCES factions(factionId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- fName: varchar to store names up to 30 characters, attempting to allow longer names
-- lName: varchar to store names up to 30 characters, attempting to allow longer names
-- alias: varchar allowing a long alias, including numbers
-- timezone: integer pointing to a PK, allows NULL if the PK is deleted from the enumerated table
-- PK: A surrogate key to reduce repetition of aliases in referenced tables
-- CK: Players are uniquely identified by their aliases, which are determined by their fellow guild members
-- FK: References a timeZone from an enumerated list, ON DELETE SET NULL beacuse we want to still have a player even
--     if the timeZone is removed, and ON UPDATE CASCADE to keep the reference to a timeZone intact 
CREATE TABLE players
(
	playerId integer NOT NULL AUTO_INCREMENT,
	fName varchar(30) NOT NULL,
	lName varchar(30) NOT NULL,
	alias varchar(30) NOT NULL,
	timeZone integer,
	CONSTRAINT players_PK PRIMARY KEY (playerID),
	CONSTRAINT players_CK1 UNIQUE (alias),
	CONSTRAINT timeZone_FK FOREIGN KEY (timeZone) REFERENCES timeZones(timeZoneId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- player: integer pointing to a PK to match the player's id
-- guild: integer pointing to a PK that is also an integer, allows NULL if the PK is deleted from guilds
-- name: varchar allowing various characters as the name of a character
-- characterLevel: integer pointing to a PK that is also an integer, allows NULL if the PK is deleted from levels, also allows for more levels to be added
-- profession: integer pointing to a PK that is also an integer, allows NULL if the PK is deleted from enumerated table
-- money: integer as the in-game money does not deal with frations of the in-game currency
-- PK: A surrogate key to reduce repetition of long character names in referenced tables
-- CK: Character's are uniquely identified by their names
-- FK1: References a player, ON DELETE CASCADE because a character belongs to a player so when the player deletes his/her account
--      all his/her characters should be deleted, and ON UPDATE CASCADE to keep the reference to a player intact 
-- FK2: References a guild, ON DELETE SET NULL beacuse we want to still have a player even
--      if the guild is removed, and ON UPDATE CASCADE to keep the reference to a guild intact 
-- FK3: References a profession from an enumerated list, ON DELETE SET NULL beacuse we want to still have a character even
--     if the profession is removed, and ON UPDATE CASCADE to keep the reference to a profession intact 
CREATE TABLE characters
(
	characterId integer NOT NULL AUTO_INCREMENT,
	player integer NOT NULL,
	guild integer,
	name varchar(30) NOT NULL,
	characterLevel integer,
	profession integer,
	money integer NOT NULL,
	CONSTRAINT characters_PK PRIMARY KEY (characterId),
	CONSTRAINT characters_CK UNIQUE (name),
	CONSTRAINT charactersPlayer_FK FOREIGN KEY (player) REFERENCES players(playerID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT charactersGuild_FK FOREIGN KEY (guild) REFERENCES guilds(guildId) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT charactersLevel_FK FOREIGN KEY (characterLevel) REFERENCES characterLevels(level) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT charactersProfession_FK FOREIGN KEY (profession) REFERENCES professions(professionId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- name: varchar to accept various characters and numerations of raids i.e. Battle of the Toads 2
-- minimumLevelRequired: integer that restricts the participation of low leveled characters
-- maxPlayers: integer denoting the amount of players that can participate in the raid
-- money: integer as the in-game money does not deal with frations of the in-game currency
-- PK: A surrogate key to reduce repetition of long raid names in referenced tables
-- CK: Raids are uniquely identified by names
CREATE TABLE raids
(
	raidId integer NOT NULL AUTO_INCREMENT,
	name varchar(50) NOT NULL,
	minimumLevelRequired integer NOT NULL,
	maxPlayers integer NOT NULL,
	money integer NOT NULL,
	CONSTRAINT raids_PK PRIMARY KEY (raidID),
	CONSTRAINT raids_CK UNIQUE (name)
);

-- dateRequested: date storing the day that the request will take place
-- guild: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from guilds
-- raid: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from raids
-- player: integer pointing to a PK that is also an integer, belongs to a player
-- notes: Anything that the player needs to specify about wanting to do a paritcular raid
-- PK: All four of the attributes included uniquely identify the requests, as the same raid may appear multiple times
-- FK1: References a guild, ON DELETE SET CASCADE beacuse a guild must exist for the request to be associated with a guild,
--      and ON UPDATE CASCADE to keep the reference to a guild intact
-- FK2: References a raid, ON DELETE CASCADE because a requests is associated with a raid so when a raids are deleted
--      requests should be deleted, and ON UPDATE CASCADE to keep the reference to a raid intact 
-- FK3: References a player, ON DELETE CASCADE because a request belongs to a player so when the player deletes his/her account
--      all his/her requests should be deleted, and ON UPDATE CASCADE to keep the reference to a player intact 
CREATE TABLE requests
(
	dateRequested date NOT NULL,
	guild integer NOT NULL,
	raid integer NOT NULL,
	player integer NOT NULL,
	notes text,
	CONSTRAINT requests_PK PRIMARY KEY (guild, raid, player, dateRequested),
	CONSTRAINT requestGuild_FK FOREIGN KEY (guild) REFERENCES guilds(guildId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT requestRaid_FK FOREIGN KEY (raid) REFERENCES raids(raidId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT requestPlayer_FK FOREIGN KEY (player) REFERENCES players(playerId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- attribute: Statistics are predetermined with a name up to 25 characters
-- PK: This is an enumerated list requiring only statisticId, not reduce repetition of data 
CREATE TABLE statistics
(
	statisticId integer NOT NULL AUTO_INCREMENT,
	attribute varchar(25) NOT NULL,
	CONSTRAINT statistics_PK PRIMARY KEY (statisticId)
);

-- characterId: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from characters
-- statisticId: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from statistics
-- statValue: integer storing a value that is associated to the character i.e. Stamina = 50
-- PK: The primary key has to be both foreign keys, as we are joining a many to many association
-- FK1: References a character, ON DELETE SET CASCADE beacuse a character must exist for the characterStatistic to be associated with a character,
--      and ON UPDATE CASCADE to keep the reference to a character intact
-- FK2: References a statistic, ON DELETE SET CASCADE beacuse a statistic must exist for the characterStatistic to be associated with a statistic,
--      and ON UPDATE CASCADE to keep the reference to a statistic intact
CREATE TABLE characterStatistics
(
	characterId integer NOT NULL,
	statisticId integer NOT NULL,
	statValue integer NOT NULL,
	CONSTRAINT characterStatistics_PK PRIMARY KEY (characterId, statisticId),
	CONSTRAINT characterStatisticsCharacter_FK FOREIGN KEY (characterId) REFERENCES characters(characterId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT characterStatisticsStatistic_FK FOREIGN KEY (statisticId) REFERENCES statistics(statisticId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- name: varchar allowing for a fairly long item name
-- description: text to allow a long description
-- PK: A surrogate key to reduce repetition of long item names in referenced tables
-- CK: Items are uniquely identified by their names
CREATE TABLE items
(
	itemId integer NOT NULL AUTO_INCREMENT,
	name varchar(30) NOT NULL,
	description text NOT NULL,
	CONSTRAINT item_PK PRIMARY KEY (itemId),
	CONSTRAINT item_CK UNIQUE (name)
);

-- characterId: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from characters
-- itemId: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from items
-- quantity: integer storing how many of that particular item
-- PK: The primary key has to be both foreign keys, as we are joining a many to many association
-- FK1: References a character, ON DELETE SET CASCADE beacuse a character must exist for the characterItems to be associated with a character,
--      and ON UPDATE CASCADE to keep the reference to a character intact
-- FK2: References a item, ON DELETE SET CASCADE beacuse an item must exist for the characterItems to be associated with an item,
--      and ON UPDATE CASCADE to keep the reference to an item intact
CREATE TABLE characterItems
(
	characterId integer NOT NULL,
	itemId integer NOT NULL,
	quantity integer NOT NULL,
	CONSTRAINT characterItems_PK PRIMARY KEY (characterId, itemId),
	CONSTRAINT characterItemsCharacter_FK FOREIGN KEY (characterId) REFERENCES characters(characterId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT characterItemsItem_FK FOREIGN KEY (itemId) REFERENCES items(itemId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- raid: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from raids
-- itemId: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from items
-- quantity: integer storing how many of that particular object that belongs to a raid
-- PK: The primary key has to be both foreign keys, as we are joining a many to many association
-- FK1: References an item, ON DELETE SET CASCADE beacuse an item must exist for the raidItems to be associated with an item,
--      and ON UPDATE CASCADE to keep the reference to a item intact
-- FK2: References a raid, ON DELETE SET CASCADE beacuse a raid must exist for the raidItems to be associated with a raid,
--      and ON UPDATE CASCADE to keep the reference to a raid intact
CREATE TABLE raidItems
(
	raid integer NOT NULL,
	itemId integer NOT NULL,
	quantity integer NOT NULL,
	CONSTRAINT raidItems_PK PRIMARY KEY (itemId, raid),
	CONSTRAINT raidItemsItem_FK FOREIGN KEY (itemId) REFERENCES items(itemId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT raidItemsRaid_FK FOREIGN KEY (raid) REFERENCES raids(raidId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- item: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from items
-- coolDown: integer that represents time in seconds
-- PK: Since consumables are a subclass of item, we use the same item id as it's PK
-- FK: References an item, ON DELETE SET CASCADE beacuse an item must exist for the consumables to be associated with an item,
--      and ON UPDATE CASCADE to keep the reference to a item intact
CREATE TABLE consumables
(
	item integer NOT NULL,
	coolDown integer NOT NULL,
	CONSTRAINT consumables_PK PRIMARY KEY (item),
	CONSTRAINT consumables_FK FOREIGN KEY (item) REFERENCES items(itemId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- item: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from items
-- minimumLevelRequired: integer that restricts the use of the item to low leveled characters
-- type: integer pointing to a PK, allows NULL if the PK is deleted from the enumerated table
-- slot: integer pointing to a PK, allows NULL if the PK is deleted from the enumerated table
-- PK: Since consumables are a subclass of item, we use the same item id as it's PK
-- FK1: References an item, ON DELETE SET CASCADE beacuse an item must exist for the equipments to be associated with an item,
--      and ON UPDATE CASCADE to keep the reference to a item intact
-- FK2: References an equipmentType from an enumerated list, ON DELETE SET NULL beacuse we want to still have an equipment even
--     if the equipmentType is removed, and ON UPDATE CASCADE to keep the reference to am equipmentType intact
-- FK3: References an equipmentSlot from an enumerated list, ON DELETE SET NULL beacuse we want to still have a equipment even
--     if the equipmentSlot is removed, and ON UPDATE CASCADE to keep the reference to a equipmentSlot intact
CREATE TABLE equipments
(
	item integer NOT NULL,
	minimumLevelRequired integer NOT NULL,
	type integer,
	slot integer,
	CONSTRAINT equipments_PK PRIMARY KEY (item),
	CONSTRAINT equipments_FK FOREIGN KEY (item) REFERENCES items(itemId) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT equipmentsType_FK FOREIGN KEY (type) REFERENCES equipmentTypes(equipmentTypeId) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT equipmentsSlot_FK FOREIGN KEY (slot) REFERENCES equipmentSlots(equipmentSlotId) ON DELETE SET NULL ON UPDATE CASCADE
);

-- equipment: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from equipments
-- statistic: integer pointing to a PK that is also an integer, NOT NULL if the PK is deleted from statistics
-- statValue: integer storing a value that is associated to the character i.e. Stamina = 50
-- PK: The primary key has to be both foreign keys, as we are joining a many to many association
-- FK1: References an equipment, ON DELETE SET CASCADE beacuse an equipment must exist for the equipmentStatistics to be associated with an equipment,
--      and ON UPDATE CASCADE to keep the reference to a equipment intact
-- FK2: References a statistic, ON DELETE SET CASCADE beacuse a statistic must exist for the equipmentStatistic to be associated with a statistic,
--      and ON UPDATE CASCADE to keep the reference to a statistic intact
CREATE TABLE equipmentStatistics
(
	equipment integer NOT NULL,
	statistic integer NOT NULL,
	statValue integer NOT NULL,
	CONSTRAINT equipmentStatistics_PK PRIMARY KEY (equipment, statistic),
	CONSTRAINT equipmentStatisticsEquipment_FK FOREIGN KEY (equipment) REFERENCES equipments(item) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT equipmentStatisticsStatistic_FK FOREIGN KEY (statistic) REFERENCES statistics(statisticId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Factions borrowed from http://www.wowwiki.com/Faction
INSERT INTO factions (factionName)
	VALUES ('Neutral'),('Alliance'),('Horde'),('Elves'),('Humans');

-- Professions/Classes borrowed from http://us.battle.net/wow/en/game/class/
INSERT INTO professions (profession)
	VALUES ('Warrior'),('Paladin'),('Hunter'),('Rogue'),('Priest'),
		  ('Death Knight'),('Shaman'),('Mage'),('Warlock'),
		  ('Monk'),('Druid');

-- Character/Equipment attributes borrowed from http://www.wowwiki.com/Weapon_type and http://www.wowwiki.com/Armor
INSERT INTO statistics (attribute)
	VALUES ('Strength'),('Agility'),('Stamina'),('Intellect'),('Spirit'),
		  ('Mastery'),('Weapon Damage'),('Weapon Speed'),('Attack Power'),('Ranged Attack Power'),
		  ('Critical Strike'),('Hit'),('Haste'),('Expertise'),('Spell Hit'),
		  ('Spell Critical Chance'),('Spell Penetration'),('Casting Speed'),('Dodge'),('Parry'),
		  ('Block'), ('Armor'),('Resistance'),('Resilience');

-- Equipment Types borrowed from http://www.wowwiki.com/Attributes
INSERT INTO equipmentTypes (equipmentTypeName)
	VALUES ('One-Handed Axe'),('Two-Handed Axe'),('Bow'),('Crossbow'),('Dagger'),
	       ('Fishing Pole'),('Fist Weapon'),('Gun'),('One-Handed Mace'),('Two-Handed Mace'),
		  ('Polearm'),('Stave'),('One-Handed Sword'),('Two-Handed Sword'),('Thrown Weapon'),
		  ('Wand'),('Cloth'),('Leather'),('Mail'),('Plate'),
		  ('Shield');

-- Equipment Slots borrowed from http://www.wowwiki.com/Equipment_slot
INSERT INTO equipmentSlots (equipmentSlotName)
	VALUES ('Ammo'),('Head'),('Neck'),('Shoulder'),('Shirt'),
	       ('Chest'),('Belt'),('Legs'),('Feet'),('Wrist'),
	       ('Gloves'),('Finger 1'),('Finger 2'),('Trinket 1'), ('Trinket 2'),
	       ('Back'),('Main Hand'),('Off Hand'),('Ranged/Relic'),('Tabard');

-- Timezones borrowed from http://php.net/manual/en/timezones.php
INSERT INTO timeZones (timeZone)
	VALUES ('+0'),('+1'),('+2'),('+3'),
	('+4'),('+5'),('+6'),('+7'),('+8'),
	('+9'),('+10'),('+11'),('+12'),('-1'),
	('-2'),('-3'),('-4'),('-5'),('-6'),
	('-7'),('-8'),('-9'),('-10'),('-11');

INSERT INTO guilds (guildName, faction)
	VALUES ('AerialAce',1),('BloodLust',3),('PaleMoon',3),('OracleThinkTank',2),('NovaGraplers',1),('PrincessGuard',2),
	       ('DarkWraiths',3),('ChaosServant',3),('BraveBird',1),('SilverFlame',2),('ToscheSt',1),('FallenCrusade',3),
	       ('DarkWindDemons',3),('EternalHope',5),('Forsaken',3),('ServersShadows',1),('BloodLoreWarriors',4),
	       ('RivendellArchers',4),('KnightsOfTheAgeless',5),('HighKnights',1);

INSERT INTO players (fName, lName, alias, timezone)
	VALUES ('Brandon','Whitney','Brad',21),('Aaron','Gutierrez','Ajax',21),('Israel','Torres','Zues',20),
	('Oscar','Chung','FreezingMoron',18),('Pepe','LePew','Skunky',14),('Evan','Cessna','Ceaser',7),('Matt','Bonnema','Troll',19),
	('Kevin','Estrada','Sparky',8),('Scotty','Crane','DoomOfTheLiving',1),('David','Christmas','Lichdom',4),
	('Shane','Costa','DuncanYoYo',5),('Katherine','Mullholand','KittyKat',19),('Steven','Merchant','SilasPayne',15),
	('Eric','Essen','MooseAttack',10),('Alex','Fuong','Fuong',16),('Axl','Cisneros','Tonatiu',8),('Gavin','Free','Gavino',18),
	('Michael','Jones','Mogar',16),('Ryan','Haywood','TheMadKing',7),('Geoff','Ramsey','ToneGeoff',5), ('Miley', 'Cyrus', 'xXxWreckingBallxXx', 12);

INSERT INTO characterLevels(level)
	VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
		  (21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
		  (41),(42),(43),(44),(45),(46),(47),(48),(49),(50),(51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
		  (61),(62),(63),(64),(65),(66),(67),(68),(69),(70),(71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
		  (81),(82),(83),(84),(85),(86),(87),(88),(89),(90),(91),(92),(93),(94),(95),(96),(97),(98),(99),(100);

INSERT INTO characters (player,guild,name,characterLevel,profession,money)
	VALUES (1,3,'BxRad',100,3,1200),(1,NULL,'Trunks',30,1,1000),(2,NULL,'SomeAznDude',70,8,800),(2,NULL,'GravelordNito',100,9,2500),
	(3,6,'LOLHero',55,5,1300),(3,19,'AppleJ4ck',30,5,500),(4,20,'healz',99,5,600),(4,1,'wagvanderack',34,1,456),
	(5,1,'thenasubust',55,4,293),(6,2,'ralcoven',73,2,879),(7,2,'kierlowland',4,10,789),(8,3,'ariathroen',90,6,1000),
	(9,3,'venharend',63,8,567),(10,4,'naomilockheart',22,4,430),(11,4,'rockmactoe',24,3,140),(11,5,'vexhalscion',41,9,100),
	(13,5,'jevensarkin',88,11,567),(14,5,'dalenfixzits',16,1,420),(15,4,'tiriaskife',45,4,340),(15,6,'ginhidless',54,8,7689),
	(16,7,'valnagi',34,1,456),(6,8,'rainhalos',73,2,879),(17,9,'ethiashiota',4,10,789),(18,10,'rosalinvain',90,6,1000),
	(9,11,'zanakatairn',63,8,567),(10,12,'mirafel',22,4,430),(20,13,'yanastiur',24,3,140),(12,14,'airasesongwriter',41,9,100),
	(13,15,'kailanekas',88,11,567),(19,16,'brenzatak',16,1,420),(20,17,'taiwoshesh',45,4,340),(15,18,'saviorcowlway',54,8,7689);

INSERT INTO raids (name,minimumLevelRequired,maxPlayers,money)
	VALUES ('Naxxramas',40,4,200),('Akulakhan',20,5,250),('FourKings',30,2,100),('Cerberus',55,3,225),('TimeLord',80,6,400),
	('The Northern Crater',60,3,85000),('Mandalia Plains',65,6,7500),('Seige Woods',70,2,3000),('Zeclaus Desert',75,3,5000),
	('Bervenia Volcano',80,4,500),('Lenalia Plateau',85,2,150),('Zerikiel Falls',90,5,1000000),('Germinas Peak',95,6,7887),
	('Poeskas Lake',100,2,7337),('Deep Dungeon',95,3,7734),('Thieves Fort',90,4,800),('Lionel Castle',85,6,500),
	('Morand Holy Place',1,2,456),('Grog Hill',5,4,365),('Orbonne Monestary',10,3,500000);

INSERT INTO requests
	VALUES ('2013-07-10',3,4,1,'need help with obtaining raritanium'),('2013-07-11',3,3,1,'dethrone the four kings for an achievement'),
	('2013-08-10',3,1,3,'Find out what the heck a Naxxrama is'),('2013-07-10',7,2,2,'Celebrate the magicians version of hanukkah'),
	('2013-11-21',6,4,5,'Need help defeating the evil professor x'),('2013-07-13',3,3,1,'I need this to level up'),
	('2013-11-01',1,12,11,'A medusa is constructing a garden of statues using townsfolk.'),
	('2013-11-02',1,19,13,'The party was once the elite task force for the King only to find out from a Duke they were sent to kill that the King is working for dark forces, gathering the shards of a crystal which his dark master is trapped in. They must now run as outlaws and try to stop this evil being from rising again.'),
	('2013-11-03',2,14,3,'Part of an exploration team.'),('2013-11-04',2,8,2,'A nations enemies have a secret base that must be found.'),
	('2013-11-05',4,1,16,'While crossing a sea, the boat is sunk by a monster of some variety. The charcters are saved by merfolk but trapped on a deserted island miles from the mainland.'),
	('2013-11-06',4,20,18,'A medusa is constructing a garden of statues using townsfolk.'),('2013-11-01',5,3,5,'A medusa is constructing a garden of statues using townsfolk.'),
	('2013-11-10',5,6,2,'The party was once the elite task force for the King only to find out from a Duke they were sent to kill that the King is working for dark forces, gathering the shards of a crystal which his dark master is trapped in. They must now run as outlaws and try to stop this evil being from rising again.'),
	('2013-11-15',8,13,19,'The characters are imprisoned and must escape.'),('2013-11-13',8,11,7,'The characters are imprisoned and must escape.'),
	('2013-11-07',9,20,2,'While crossing a sea, the boat is sunk by a monster of some variety. The charcters are saved by merfolk but trapped on a deserted island miles from the mainland.'),('2013-11-06',9,20,17,'A powerful Demon offers each of the party members their greatest wish. This is too good to be true.'),
	('2013-11-18',10,18,6,'The characters are imprisoned and must escape.'),('2013-11-01',10,20,14,'The characters are imprisoned and must escape.'),
	('2013-11-05',11,7,1,'The party was once the elite task force for the King only to find out from a Duke they were sent to kill that the King is working for dark forces, gathering the shards of a crystal which his dark master is trapped in. They must now run as outlaws and try to stop this evil being from rising again.'),
	('2013-11-09',11,14,12,'Part of an exploration team.'),('2013-11-08',12,15,3,'A medusa is constructing a garden of statues using townsfolk.'),('2013-11-04',12,8,8,'The characters are imprisoned and must escape.'),
	('2013-11-15',13,3,20,'While crossing a sea, the boat is sunk by a monster of some variety. The charcters are saved by merfolk but trapped on a deserted island miles from the mainland.'),
	('2013-11-03',13,20,5,'While crossing a sea, the boat is sunk by a monster of some variety. The charcters are saved by merfolk but trapped on a deserted island miles from the mainland.'),
	('2013-11-02',14,19,11,'A powerful Demon offers each of the party members their greatest wish. This is too good to be true.'),('2013-10-01',14,1,2,'A nations enemies have a secret base that must be found.'),
	('2013-10-02',15,15,2,'An illusion of peace and tranquility is projected over a town. The characters must escape and discover what is really happening.'),
	('2013-10-06',15,7,20,'The characters are imprisoned and must escape.'),('2013-10-07',16,11,20,'A nations enemies have a secret base that must be found.'),
	('2013-10-08',16,15,10,'A powerful Demon offers each of the party members their greatest wish. This is too good to be true.'),
	('2013-10-09',17,11,19,'The characters are imprisoned and must escape.'),('2013-10-04',17,13,9,'An illusion of peace and tranquility is projected over a town. The characters must escape and discover what is really happening.'),
	('2013-10-09',18,7,15,'An illusion of peace and tranquility is projected over a town. The characters must escape and discover what is really happening.'),
	('2013-10-05',18,16,11,'The characters are imprisoned and must escape.'),('2013-10-02',19,14,4,'An illusion of peace and tranquility is projected over a town. The characters must escape and discover what is really happening.'),
	('2013-10-01',19,3,12,'The party was once the elite task force for the King only to find out from a Duke they were sent to kill that the King is working for dark forces, gathering the shards of a crystal which his dark master is trapped in. They must now run as outlaws and try to stop this evil being from rising again.'),
	('2013-10-02',20,15,10,'Soldiers in an army marching into unholy land.'),('2013-10-10',20,14,5,'A powerful Demon offers each of the party members their greatest wish. This is too good to be true.');

INSERT INTO characterStatistics
	VALUES (1,1,50),(1,2,20),(2,3,60),(2,4,70),(3,5,99),(3,3,60),(4,5,86),(5,1,10),(6,4,49),(7,6,89),(8,2,49),(9,2,30),
	(10,5,44),(11,5,74),(12,6,96),(13,6,12),(14,6,20),(15,5,88),(16,2,66),(17,5,31),(18,6,92),(19,2,92),(20,1,7),(21,5,81),
	(22,3,94),(23,5,5),(24,1,24),(25,5,23),(26,6,70),(27,3,27),(28,5,30),(29,1,56),(30,6,99),(31,2,23),(32,1,24);

INSERT INTO items (name,description)
	VALUES ('Wooden Sword','Starting Sword'),('Ivory Chestplate','A fine chestplate forged from ivory'),
	('Healing Potion','Restores 100 Health on use'),('Boar Tooth','Completes a Quest'),('Blue Eyes White Dragon','Trinquet that shows you completed Naxxramas'),
	('Mana Potion','Restores 100 Mana on use'),('Rage Potion','Induces haste for 2 minutes'),('Luck of the Irish','Chance of gold finding increased for 30 seconds'),
	('Invisible Potion','Turn invisible for 3 minutes'),('Sword of Rabbits','Duct taped rabbits shaped into a sword'),('Dagger of Wealth','Increases chances of finding gold'),
	('Shield of Doom','Instantly kills enemies'),('Bag of Holding','It appears to be a cloth sack and opens into non-dimensional space, can carry 250 lbs of material.'),
	('Bastard Sword','Large hand and a half sword.'),('Guisarme','Exotic pole arm with curved blade.'),('Cugel','A club with a weighted metal end.'),
	('Spiked Chain','Chain with a spiked ball at the end to ensnare opponents.'),('Rapier','Thin blade made for piercing.'),('Potion of Cure Light Wounds','Cures light wounds.'),
	('Potion of Water Breathing','Allows character to breath under water.'),('Bless Weapon Oil','Deals extra damage to evil creatures.'),
	('Potion of Dark Vision','Allows character character to see in dimly lit areas.'),('Potion of Spider Climb','Allows characters to walk up walls.'),('Antidote','Neutralizes poison.');

INSERT INTO characterItems
	VALUES (1,1,1),(1,3,5),(1,2,2),(2,5,20),(2,3,100),(3,17,1),(3,12,2),(4,21,1),(4,4,5),(5,7,4),(5,3,12),(6,17,3),(6,15,5),(8,16,32),
	(8,12,3),(9,7,4),(9,10,5),(11,20,4),(11,2,5),(12,6,2),(12,11,4),(13,9,6),(1,22,8),(14,3,5),(14,15,4),(15,24,5),(15,3,5),(16,9,6),
	(16,23,4),(3,16,4),(18,9,2),(18,13,5),(19,17,4),(5,1,3),(20,4,2),(20,18,3),(22,19,5),(7,22,6),(23,17,5),(23,4,4),(24,23,2),(9,2,2),
	(25,17,3),(25,4,3),(26,19,5),(26,1,6),(11,23,4),(27,1,5),(27,20,34),(28,3,5),(28,15,6),(13,2,7),(29,6,6),(30,21,7),(30,16,5),
	(31,23,5),(31,15,3),(32,8,8),(32,16,4);

INSERT INTO raidItems
	VALUES (1,4,20),(1,1,5),(1,5,1),(4,3,25),(5,4,50),(2,9,4),(2,20,39),(3,9,55),(3,21,97),(6,16,78),(6,11,87),(7,1,45),(7,12,35),
	(8,19,19),(8,9,73),(9,12,91),(9,6,83),(10,19,43),(10,2,47),(11,19,8),(11,20,55),(12,13,6),(12,20,41),(13,9,9),(13,2,18),(14,11,24),
	(14,23,58),(15,2,70),(15,17,34),(16,22,83),(16,11,70),(17,15,39),(17,19,68),(18,18,11),(18,15,79),(19,12,63),(19,22,96),(20,17,73),(20,4,75);

INSERT INTO consumables
	VALUES (3,60),(6,60),(7,120),(8,30),(9,180),(19,30),(20,180),(21,300),(22,60),(23,180),(24,30);

INSERT INTO equipments
	VALUES (1,0,13,17),(2,30,20,6),(10,0,14,17),(11,25,5,18),(12,99,21,16),(14,5,13,17),(15,15,11,17),(16,2,9,18),(17,28,15,17),(18,42,13,17);

INSERT INTO equipmentStatistics
	VALUES (1,1,5),(2,22,30),(10,11,56),(11,12,75),(12,22,99),(12,21,89),(14,7,20),(14,8,25),(15,10,79),(15,11,100),(16,9,50),(16,7,75),(17,10,56),(17,12,89),(18,11,99),(18,7,76);