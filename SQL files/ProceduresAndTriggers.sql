-- MMO Games Database
-- Elaheh Toulabi Nejad
-- Queries : Procedures and triggers




USE MMOdb
GO



--------------------------------STORED PROCEDURES-----------------------------------

-- a procedure to add a player to an alliance

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) already a member of this alliance

CREATE PROCEDURE dbo.joinAlliance
    @playerID INT ,
    @allianceID INT
AS

    if EXISTS(SELECT * FROM player WHERE id=@playerID ) AND EXISTS (SELECT * FROM alliance WHERE id=@allianceID)
    BEGIN

      if NOT EXISTS (SELECT * FROM alliance_member WHERE player_id = @playerID AND alliance_id=@allianceID)
      BEGIN
        INSERT INTO alliance_member
        (
         [player_id], [alliance_id] ,[date_from],[date_to]
        )
        VALUES
        ( 
         @playerID, @allianceID, GETDATE() , NULL
        )

        RETURN (1)
      END
      ELSE
        RETURN (3)
        
    END
    ELSE
        RETURN (2)
GO

-- -- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.joinAlliance 4,1
select @state as Statue
SELECT * from alliance_member






-- a procedure to remove a player from an alliance

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) not  a member of this alliance


CREATE PROCEDURE dbo.leaveAlliance
    @playerID INT ,
    @allianceID INT
AS

    if EXISTS(SELECT * FROM player WHERE id=@playerID ) AND EXISTS (SELECT * FROM alliance WHERE id=@allianceID)
    BEGIN

      if  EXISTS (SELECT * FROM alliance_member WHERE player_id = @playerID AND alliance_id=@allianceID)
      BEGIN

        UPDATE alliance_member
        SET
            [date_to] = GETDATE()
        WHERE player_id=@playerID AND alliance_id=@allianceID


        RETURN (1)
      END
      ELSE
        RETURN (3)
        
    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.leaveAlliance 2,1
select @state as Statue
SELECT * from alliance_member






-- a procedure to add structures to a location

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) player is not allowed to create structures in this location
-- (4) player's resources (level or crrdit) doesn't satisfy  requirements


CREATE PROCEDURE dbo.buildStructure
    @structureID INT ,
    @locationID INT ,
    @playerID INT
AS

    if EXISTS(SELECT * FROM structure WHERE id=@structureID )AND EXISTS(SELECT * FROM player WHERE id = @playerID) AND EXISTS (SELECT * FROM [location] WHERE id=@locationID)
    BEGIN 

        if ((SELECT player_id FROM [location] WHERE id=@locationID) = @playerID) OR ((SELECT player_id FROM [location] WHERE id=@locationID) = NULL)
        BEGIN

            DECLARE @credit INT
            DECLARE @level INT
            SET @credit = (SELECT credit FROM player WHERE id=@playerID)
            SET @level = (SELECT [level] FROM player WHERE id=@playerID)

            if ((SELECT cost FROM structure WHERE id=@structureID) <= @credit)  AND ((SELECT req_level FROM structure WHERE id=@structureID) <=@level)
            BEGIN  
                BEGIN TRANSACTION 
                    INSERT INTO structure_built
                    (
                    [structure_id], [location_id] 
                    )
                    VALUES
                    ( 
                    @structureID, @locationID
                    )

                    UPDATE player
                    SET
                        [credit] = credit - (SELECT cost FROM structure WHERE id=@structureID)
                    WHERE id = @playerID
                COMMIT TRANSACTION
                RETURN (1)
                
            END
            ELSE
             RETURN (4)

        END  
        ELSE
            RETURN (3)  

    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.buildStructure 6,1,1
select @state as Statue
SELECT * from structure_built
SELECT * FROM player







-- a procedure to destroy structures to a location

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) player is not allowed to destroy structures in this location


CREATE PROCEDURE dbo.destroyStructure
    @structureID INT ,
    @locationID INT ,
    @playerID INT
AS

    if EXISTS(SELECT * FROM structure WHERE id=@structureID )AND EXISTS(SELECT * FROM player WHERE id = @playerID) AND EXISTS (SELECT * FROM [location] WHERE id=@locationID)
    BEGIN 

        if ((SELECT player_id FROM [location] WHERE id=@locationID) = @playerID) OR ((SELECT player_id FROM [location] WHERE id=@locationID) = NULL)
        BEGIN


                BEGIN TRANSACTION 

                    DELETE FROM structure_built
                    WHERE 	structure_id = @structureID AND location_id=@locationID


                    UPDATE player
                    SET
                        [credit] = credit + (SELECT cost FROM structure WHERE id=@structureID)
                    WHERE id = @playerID

                COMMIT TRANSACTION
                RETURN (1)
                

        END  
        ELSE
            RETURN (3)  

    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.destroyStructure 6,1,1
SELECT @state as Statue
SELECT * from structure_built
SELECT * FROM player







-- a procedure to buy units and locate them on a location

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) player is not allowed to locate units in this location
-- (4) player's resources (level or crrdit) doesn't satisfy  requirements


CREATE PROCEDURE dbo.buyUnit
    @unitID INT ,
    @locationID INT ,
    @playerID INT,
    @amount INT
AS

    if EXISTS(SELECT * FROM unit WHERE id=@unitID )AND EXISTS(SELECT * FROM player WHERE id = @playerID) AND EXISTS (SELECT * FROM [location] WHERE id=@locationID)
    BEGIN 

        if ((SELECT player_id FROM [location] WHERE id=@locationID) = @playerID) 
        BEGIN

            DECLARE @credit INT
            DECLARE @level INT
            SET @credit = (SELECT credit FROM player WHERE id=@playerID)
            SET @level = (SELECT [level] FROM player WHERE id=@playerID)

            if ((SELECT cost FROM unit WHERE id=@unitID)*@amount <= @credit)  AND ((SELECT req_level FROM structure WHERE id=@unitID) <=@level)
            BEGIN  
                if NOT EXISTS( SELECT * FROM units_on_location WHERE unit_id=@unitID AND location_id=@locationID)
                BEGIN
                    BEGIN TRANSACTION 
                        INSERT INTO units_on_location
                        (
                        [unit_id], [location_id] ,[number]
                        )
                        VALUES
                        ( 
                        @unitID, @locationID ,@amount
                        )

                        UPDATE player
                        SET
                            [credit] = credit - (SELECT cost FROM structure WHERE id=@unitID)*@amount
                        WHERE id = @playerID
                    COMMIT     
                   
                END
                ELSE
                BEGIN
                    BEGIN TRANSACTION 
                        UPDATE units_on_location
                        SET
                            [number] = [number]+@amount
                        WHERE unit_id=@unitID AND location_id=@locationID
                 

                        UPDATE player
                        SET
                            [credit] = credit - (SELECT cost FROM structure WHERE id=@unitID)*@amount
                        WHERE id = @playerID
                    COMMIT     
                END
                RETURN (1)
                
            END
            ELSE
             RETURN (4)

        END  
        ELSE
            RETURN (3)  

    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.buyUnit 3,1,1,2
select @state as Statue
SELECT * from units_on_location
SELECT * FROM player
SELECT * FROM unit






-- a procedure to sell units of a locate 

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) player is not allowed to sell units in this location
-- (4) no such unit exists on this location

CREATE PROCEDURE dbo.sellUnit
    @unitID INT ,
    @locationID INT ,
    @playerID INT,
    @amount INT
AS

    if EXISTS(SELECT * FROM unit WHERE id=@unitID )AND EXISTS(SELECT * FROM player WHERE id = @playerID) AND EXISTS (SELECT * FROM [location] WHERE id=@locationID)
    BEGIN 

        if ((SELECT player_id FROM [location] WHERE id=@locationID) = @playerID) 
        BEGIN


            if NOT EXISTS( SELECT * FROM units_on_location WHERE unit_id=@unitID AND location_id=@locationID)
                RETURN(4)
            ELSE
            BEGIN
                if (SELECT [number] FROM units_on_location WHERE unit_id=@unitID AND location_id=@locationID) >@amount
                BEGIN
                    BEGIN TRANSACTION

                        UPDATE units_on_location
                        SET
                            [number] = [number]-@amount
                        WHERE unit_id=@unitID AND location_id=@locationID

                        UPDATE player
                        SET
                        [credit] = credit + (SELECT cost FROM structure WHERE id=@unitID)*@amount
                    WHERE id = @playerID
                    
                    COMMIT TRANSACTION
                END
                ELSE
                BEGIN
                    BEGIN TRANSACTION
                        UPDATE player
                        SET
                        [credit] = credit + (SELECT cost FROM structure WHERE id=@unitID)*(SELECT [number] FROM units_on_location WHERE  unit_id=@unitID AND location_id=@locationID )
                        WHERE id = @playerID

                        DELETE FROM units_on_location
                        WHERE unit_id=@unitID AND location_id=@locationID


                    COMMIT TRANSACTION
                END

                   
            END
            RETURN (1)


        END  
        ELSE
            RETURN (3)  

    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.sellUnit 3,1,1,3
select @state as Statue
SELECT * from units_on_location
SELECT * FROM player
SELECT * FROM unit






-- a procedure to sell units of a locate 

-- error guide :
-- (1) successful execution
-- (2) parameters are not specified correctly
-- (3) location is not vacant


CREATE PROCEDURE dbo.locatePlayer
    @locationID INT ,
    @playerID INT

AS

    if  EXISTS(SELECT * FROM player WHERE id = @playerID) AND EXISTS (SELECT * FROM [location] WHERE id=@locationID)
    BEGIN 

        if ((SELECT player_id FROM [location] WHERE id=@locationID) = NULL) 
        BEGIN
            UPDATE [location]
            SET
                [player_id] = @playerID

            WHERE 	id = @locationID

            RETURN (1)
        END  
        ELSE
            RETURN (3)  

    END
    ELSE
        RETURN (2)
GO

-- example to execute the stored procedure and check the result
DECLARE @state int
EXECUTE @state = dbo.locatePlayer 3,1
select @state as Statue
SELECT * from location



--------------------------------TRIGGERS-----------------------------------



-- a trigger to record activities of alliances members

CREATE TRIGGER allianceLogs
ON alliance_member
AFTER INSERT,UPDATE
AS
BEGIN
    if NOT EXISTS(SELECT * FROM deleted)AND EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO allianceLogsTable(player_id,alliance_id,date,action) (
            SELECT i.player_id,i.alliance_id,GETDATE(),'join'
            FROM inserted as i
        )
    END 

    if  EXISTS(SELECT * FROM deleted)AND EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO allianceLogsTable(player_id,alliance_id,date,action) (
            SELECT i.player_id,i.alliance_id,GETDATE(),'left'
            FROM inserted as i
        )
    END
END

-- --example
INSERT INTO alliance_member
( 
 [player_id], [alliance_id]
)
VALUES
( 
 '2', '5'
)

UPDATE alliance_member
SET
    [date_to] = GETDATE()
WHERE 	player_id='2' and alliance_id='5'

SELECT * FROM allianceLogsTable
SELECT * FROM alliance_member






-- a trigger to record creation and deletion of alliances


CREATE TRIGGER allianceExistanceLogs
ON alliance
AFTER INSERT,UPDATE
AS
BEGIN
    if NOT EXISTS(SELECT * FROM deleted)AND EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO allianceExistanceLogsTable(alliance_id,alliance_name,date,action)(
            SELECT i.id,i.alliance_name,GETDATE(),'created'
            FROM inserted as i
        )
    END 

    if  EXISTS(SELECT * FROM deleted)AND EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO allianceExistanceLogsTable(alliance_id,alliance_name,date,action) (
            SELECT i.id,i.alliance_name,GETDATE(),'deleted'
            FROM inserted as i
        )
    END
END

-- --example
INSERT INTO alliance
( 
 [alliance_name]
)
VALUES
( 
 '6th alliance'
)

UPDATE alliance
SET
    [date_disbanded] = GETDATE()
WHERE 	id='6'

SELECT * FROM allianceExistanceLogsTable
SELECT * FROM alliance





--a trigger to record trades on units


CREATE TRIGGER unitsTradesLogs
ON units_on_location
AFTER INSERT,UPDATE,DELETE
AS
BEGIN

    if NOT EXISTS(SELECT * FROM deleted)AND EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO unitsTradesLogsTable(unit_id,location_id,date,action)(
            SELECT i.unit_id,i.location_id,GETDATE(),'added'
            FROM inserted as i
        )
    END 

    if  EXISTS(SELECT * FROM deleted)AND NOT EXISTS(SELECT * FROM inserted)
    BEGIN
         INSERT INTO unitsTradesLogsTable(unit_id,location_id,date,action)(
            SELECT i.unit_id,i.location_id,GETDATE(),'removed'
            FROM deleted as i
        )
    END

END

--example

INSERT INTO units_on_location
( 
 [unit_id],[location_id],[number]
)
VALUES
( 
 '3','2','1'
)

select * from unitsTradesLogsTable