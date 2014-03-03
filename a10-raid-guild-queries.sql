-- 
-- MySQL Queries
-- Aaron Gutierrez
-- Israel Torres
-- Brandon Whitney
-- 
-- CECS 323
-- December 10, 2013
-- 
-- Assignment #10
-- 
-- Guild Raid Request Queries
-- 
-- 1. Selecting the name of the player with the highest level character from a guild. In this case guild 3, PaleMoon
SELECT p.fName as 'First Name', p.lName as 'Last Name', p.alias, c.name as 'Character', c.characterLevel as 'Level', g.guildName
	FROM players p
	INNER JOIN characters c ON c.player=p.playerId
	INNER JOIN guilds g ON c.guild=g.guildId
WHERE
	g.guildId = 3 AND c.characterLevel >= ALL (SELECT c1.characterLevel
													FROM characters c1
													INNER JOIN guilds g1 ON c1.guild=g1.guildId
													WHERE g1.guildId = 3);

-- 2. Selecting characters without a guild that have a specific statistic above a specific value. In this case Stat 5 Spirit above 50.
SELECT c.name, c.characterLevel, p.profession, s.attribute, cs.statValue
	FROM characters c
	NATURAL JOIN characterStatistics cs
	NATURAL JOIN statistics s
	INNER JOIN professions p ON c.profession=p.professionId
	LEFT OUTER JOIN guilds g ON c.guild=g.guildId
WHERE g.guildId IS NULL AND s.statisticId = 5 AND cs.statValue > 50;

-- 3. Check how many items every character has
SELECT c.name, COUNT(i.itemID) as 'Item Count'
	FROM characters c
	LEFT OUTER JOIN characterItems ci ON c.characterID = ci.characterID
    LEFT OUTER JOIN items i ON ci.itemID=i.itemID
GROUP BY c.name;

-- 4. Find the raids with more than a specific number of requests for a specific guild, in this case Guild 3, PaleMoon and 2 or more requests
SELECT ra.name, COUNT(re.guild) as 'Num of Requests'
	FROM requests re
    INNER JOIN raids ra ON re.raid = ra.raidID
    INNER JOIN guilds g ON re.guild = g.guildID
WHERE g.guildId = 3
GROUP BY ra.name
HAVING COUNT(re.guild) >= 2;

-- 5. Find the number of players with characters for each profession
SELECT pr.profession, COUNT(DISTINCT p.alias) as 'num of players'
	FROM players p
	INNER JOIN characters c ON p.playerId=c.player
	INNER JOIN professions pr ON c.profession=pr.professionId
GROUP BY c.profession;

-- 6. Find players that only have characters in a specific guild. In this case guild 3 PaleMoon
SELECT p.alias
	FROM players p
	INNER JOIN characters c ON p.playerId = c.player
	LEFT OUTER JOIN guilds g ON c.guild = g.guildId
WHERE g.guildId = 3 AND p.alias NOT IN(SELECT p.alias
										   		FROM players p
												INNER JOIN characters c ON p.playerId = c.player
												LEFT OUTER JOIN guilds g ON c.guild = g.guildId
											WHERE g.guildId != 3 OR g.guildId IS NULL);

-- 7. Players that have only submitted requests to a specfic guild. In this case Guild 4 OracleThinkTank
SELECT p.alias
	FROM players p
	INNER JOIN requests r ON p.playerID = r.player
	INNER JOIN guilds g ON r.guild = g.guildID
WHERE g.guildID = 4 AND p.alias NOT IN (SELECT p.alias
											FROM players p
											INNER JOIN requests r ON p.playerID = r.player
											INNER JOIN guilds g ON r.guild = g.guildID
										WHERE g.guildID != 4);
