-- MMO Games Database
-- Elaheh Toulabi Nejad
-- Queries : Functions and Views


use master


-- Run below command and execute creating each function or table separetely (one by one)
USE MMOdb
GO



--------------------------------FUNCTIONS-----------------------------------

-- a function which gets an alliance ID and returns usernames of its members in a table (table-valued function)

CREATE FUNCTION getMembers (@allianceID int )
RETURNS @namesList TABLE
(
	memberName varchar(128) NOT NULL
)
AS
BEGIN
	WITH list AS ( SELECT p.user_name
				   FROM alliance_member as a LEFT JOIN player as p ON a.player_id = p.id
	               WHERE a.alliance_id=@allianceID and a.date_to is NULL )
	INSERT INTO @namesList
	SELECT *
	FROM list
	RETURN
END;

-- function call
SELECT * FROM getMembers(1)	-- 3  members
SELECT * FROM getMembers(2) -- no members




-- a function which gets an location ID and returns its coordinates (scalar-valued function)

CREATE FUNCTION [dbo].[getCoordinates] (@locID INT)
RETURNS VARCHAR(255)
AS
BEGIN
    RETURN (SELECT coordinates FROM [location] as l WHERE l.id=@locID )
END 

-- function call
SELECT dbo.getCoordinates(2) as Coordinates




-- a function which gets a player ID and a unit ID and returns 1 if player can purchase the unit and 0 otherwise (scalar-valued function)

CREATE FUNCTION [dbo].[canPurchase] (@playerID INT , @unitID INT )
RETURNS BIT
AS
BEGIN
    DECLARE @res BIT

    DECLARE @playerLevel INT
    SET @playerLevel  = (SELECT [level] FROM player WHERE player.id=@playerID)
  
    DECLARE @playerCredit INT
    SET @playerCredit = (SELECT [credit] FROM player WHERE player.id=@playerID)
   
    DECLARE @reqLevel INT
    SET @reqLevel = (SELECT [req_level] FROM unit WHERE unit.id=@unitID)
   
    DECLARE @cost INT
    SET @cost = (SELECT [cost] FROM unit WHERE unit.id=@unitID)


    IF(@playerLevel >= @reqLevel) and (@playerCredit >= @cost)
        SET @res = 1
    ELSE
        SET @res = 0

    RETURN @res
  
END 

-- function call
SELECT dbo.canPurchase(2,4) as 'can?'
SELECT dbo.canPurchase(2,3) as 'can?'




-- a function which orders alliances based on sum of its members' credits

CREATE FUNCTION orderAlliances ()
RETURNS @alliancesList TABLE
(
    allianceID int,
	allianceName varchar(128) NOT NULL,
    allianceCredit int
)
AS
BEGIN
	WITH list AS ( SELECT a.id as AllianceID,a.alliance_name as AllianceName,p.id as Member,p.credit as MemberCredit
                   FROM alliance as a LEFT JOIN alliance_member as am ON a.id=am.alliance_id LEFT JOIN player as p ON p.id=am.player_id
                   WHERE am.date_to is NULL )
	INSERT INTO @alliancesList
	SELECT list.AllianceID,list.AllianceName,SUM(list.MemberCredit) as TotalCredit
	FROM list
    GROUP BY list.AllianceID,list.AllianceName
    ORDER BY TotalCredit
	RETURN
END;

-- function call
SELECT * FROM orderAlliances()









--------------------------------VIEWS-----------------------------------


--  a view containing id,name and number of members for each alliance

CREATE VIEW dbo.AllianceNoOfMembers
AS
   SELECT a.id as AllianceID ,a.alliance_name as AllianceName,COUNT(am.player_id) as NumberOfPlayers
   FROM alliance as a LEFT JOIN alliance_member as am ON a.id=am.alliance_id
   GROUP BY a.id,a.alliance_name

-- view usage
SELECT * FROM AllianceNoOfMembers




-- a view containing a list of all locations and name and number of units located in each location

CREATE VIEW dbo.UnitsOnLocations
AS  
    SELECT ISNULL(l.location_name,'AllLocations') as LocationName,ISNULL(u.unit_name,'AllExistingUnits') as UnitName,
    SUM(ul.number) as NoOfUnit
    FROM [location] as l LEFT  JOIN units_on_location as ul ON l.id=ul.location_id INNER JOIN unit as u ON ul.unit_id=u.id
	GROUP BY ROLLUP(location_name,unit_name)

-- view usage
SELECT * FROM UnitsOnLocations 




--a view containing  ids  and usernames of all players  and number of each two type of movements they have started

CREATE VIEW PlayerMovements 
AS
    SELECT PlayerUsername,[1st movement type] as '1stMovementType',[2nd movement type] as '2ndMovementType'
    FROM (SELECT p.id as PlayerID,p.[user_name] as PlayerUsername,gm.id as MovementTD,mt.type_name as TypeName
        FROM player as p LEFT JOIN group_movement as gm ON p.id = gm.player_id LEFT JOIN movement_type as mt ON  gm.movement_type_id=mt.id) as tt
    PIVOT
    (
    COUNT(tt.MovementTD)
    FOR TypeName
    IN 
    ([1st movement type],[2nd movement type])
    ) as pvt

-- view usage
SELECT * FROM PlayerMovements


 

 -- a view containing a list of all locations and name and number of structures located in each location

CREATE VIEW dbo.StructuresOnLocations
AS  
    SELECT ISNULL(l.location_name,'AllLocations') as LocationName,ISNULL(s.structure_name,'AllExistingStructures') as StructureName,
    COUNT(sb.id) as NoOfStructures
    FROM [location] as l LEFT  JOIN structure_built as sb ON l.id=sb.location_id INNER JOIN structure as s ON sb.structure_id=s.id
	GROUP BY GROUPING SETS(location_name, s.structure_name,(location_name, s.structure_name))
	
-- view usage
SELECT * FROM StructuresOnLocations as sol ORDER BY sol.LocationName,sol.StructureName



