-- MMO Games Database
-- Elaheh Toulabi Nejad
-- Table Creation and Data Insertion 




--Database Creation

USE master
GO

IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'MMOdb'
)
CREATE DATABASE MMOdb
GO

USE MMOdb
GO


--Tables Creation
--11 tables


--player table

IF OBJECT_ID('dbo.player', 'U') IS NOT NULL
DROP TABLE dbo.player
GO

CREATE TABLE dbo.player
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY ,
    user_name varchar(64) NOT NULL UNIQUE, 
    password varchar(64) NOT NULL ,  
    nickname varchar(64) NOT NULL,
    email varchar(254) NOT NULL,
    credit int DEFAULT 1000,
    level  int DEFAULT 1,
    confirmation_code varchar(128) NOT NULL,
    confirmation_date datetime DEFAULT GETDATE()

);
GO



--alliance table

IF OBJECT_ID('dbo.alliance', 'U') IS NOT NULL
DROP TABLE dbo.alliance
GO

CREATE TABLE dbo.alliance
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    alliance_name varchar(128) NOT NULL,---VERSION2
    date_founded datetime DEFAULT GETDATE(),
    date_disbanded datetime  DEFAULT NULL
    
);
GO

select * from alliance

--alliance_member table

IF OBJECT_ID('dbo.alliance_member', 'U') IS NOT NULL
DROP TABLE dbo.alliance_member
GO

CREATE TABLE dbo.alliance_member
(
    id int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    player_id int NOT NULL,
    alliance_id int NOT NULL,
    date_from datetime  NOT NULL DEFAULT GETDATE(),
    date_to datetime  DEFAULT NULL,
    FOREIGN KEY (player_id) REFERENCES player,
    FOREIGN KEY (alliance_id) REFERENCES alliance

);
GO



--movement_type table

IF OBJECT_ID('dbo.movement_type', 'U') IS NOT NULL
DROP TABLE dbo.movement_type
GO

CREATE TABLE dbo.movement_type
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    type_name varchar(64) NOT NULL,
    allows_wait bit NOT NULL    
);
GO



--location table

IF OBJECT_ID('dbo.location', 'U') IS NOT NULL
DROP TABLE dbo.location
GO

CREATE TABLE dbo.location
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    location_name varchar(64) NOT NULL,
    coordinates varchar(255) NOT NULL UNIQUE,
    dimension varchar(255) NOT NULL,
    player_id int , --VERSION2
    FOREIGN KEY (player_id) REFERENCES player
);
GO


--structure table

IF OBJECT_ID('dbo.structure', 'U') IS NOT NULL
DROP TABLE dbo.structure
GO

CREATE TABLE dbo.structure
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    structure_name varchar(64) NOT NULL,
    cost int NOT NULL,
    req_level int NOT NULL
);
GO



--structure_built table

IF OBJECT_ID('dbo.structure_built', 'U') IS NOT NULL
DROP TABLE dbo.structure_built
GO

CREATE TABLE dbo.structure_built
(
     id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    location_id int NOT NULL,
    structure_id int NOT NULL,
    FOREIGN KEY (location_id) REFERENCES location,
    FOREIGN KEY (structure_id) REFERENCES structure
);
GO



--unit table

IF OBJECT_ID('dbo.unit', 'U') IS NOT NULL
DROP TABLE dbo.unit
GO

CREATE TABLE dbo.unit
(
    id int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    unit_name varchar(64) NOT NULL,
    cost int NOT NULL,
    req_level int NOT NULL
);
GO



--units_on_location table

IF OBJECT_ID('dbo.units_on_location', 'U') IS NOT NULL
DROP TABLE dbo.units_on_location
GO

CREATE TABLE dbo.units_on_location
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    unit_id int NOT NULL,
    location_id int NOT NULL,
    number int NOT NULL,
    FOREIGN KEY (unit_id) REFERENCES unit,
    FOREIGN KEY (location_id) REFERENCES location
);
GO


--group_movement table

IF OBJECT_ID('dbo.group_movement', 'U') IS NOT NULL
DROP TABLE dbo.group_movement
GO

CREATE TABLE dbo.group_movement
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    player_id int NOT NULL,
    movement_type_id int NOT NULL,
    location_from int NOT NULL,
    location_to int NOT NULL,
    arrival_time datetime DEFAULT GETDATE() ,
    return_time datetime,        -- 'can be NULL if this is one way move from -> to',
    wait_time int DEFAULT NULL , -- 'time to wait on destination: in minutes',
    FOREIGN KEY (player_id) REFERENCES player,
    FOREIGN KEY (movement_type_id) REFERENCES movement_type,
    FOREIGN KEY (location_from) REFERENCES location,
    FOREIGN KEY (location_to) REFERENCES location

);
GO



--units_in_group table

IF OBJECT_ID('dbo.units_in_group', 'U') IS NOT NULL
DROP TABLE dbo.units_in_group
GO

CREATE TABLE dbo.units_in_group
(
    id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    unit_id int NOT NULL,
    group_moving_id int NOT NULL,
    number int NOT NULL,
    FOREIGN KEY (unit_id) REFERENCES unit,
    FOREIGN KEY (group_moving_id) REFERENCES group_movement
);
GO



--Logs Tables
CREATE TABLE allianceLogsTable
(
    id INT NOT NULL IDENTITY(1,1),
    player_id INT ,
    alliance_id INT,
    date DATETIME,
    action VARCHAR(4) CHECK( action in ('left','join')),
	FOREIGN KEY (player_id) REFERENCES player,
	FOREIGN KEY (alliance_id) REFERENCES alliance


);

CREATE TABLE allianceExistanceLogsTable
(
    id INT NOT NULL IDENTITY(1,1),
    alliance_id INT,
    alliance_name VARCHAR(128),
    date DATETIME,
    action VARCHAR(8) CHECK( action in ('created','deleted')),
	FOREIGN KEY (alliance_id) REFERENCES alliance

);


CREATE TABLE unitsTradesLogsTable
(
    id INT NOT NULL IDENTITY(1,1),
    unit_id INT,
    location_id INT,
    date DATETIME,
    action VARCHAR(8) CHECK( action in ('added','removed')),
	FOREIGN KEY (unit_id) REFERENCES unit,
	FOREIGN KEY (location_id) REFERENCES location



);



-- Date insertion



--player table

INSERT INTO player
( 
 [user_name], [password], [nickname],[email],[confirmation_code]
)
VALUES
( 
 '1st player', '1', '1st' , '1stplayer@gmail.com' , '1111'
),
(
 '2nd player', '12', '2nd' , '2ndplayer@gmail.com' , '2222'
),
( 
 '3rd player', '123', '3rd' , '3rdplayer@gmail.com' , '3333'
),
(
 '4th player', '1234', '4th' , '4thplayer@gmail.com' , '4444'
),
(
 '5th player', '12345', '5th' , '5thplayer@gmail.com' , '5555'
)
GO



--alliance table

INSERT INTO alliance
( 
 [alliance_name],[date_disbanded]
)
VALUES
( 
 '1st alliance',NULL
),
(
 '2nd alliance', DATEADD(day, 10, GETDATE())
),
( 
 '3rd alliance',NULL
),
(
 '4th alliance',NULL
),
(
 '5th alliance',NULL
)
GO



--alliance_member table

INSERT INTO alliance_member
( 
 [player_id],[alliance_id],[date_to]
)
VALUES
( 
 '1','1',NULL
),
(
 '2','1',NULL
),
( 
 '3','1',NULL
),
(
 '3','2', DATEADD(day, 15, GETDATE())
),
(
 '4','2', DATEADD(day, 2, GETDATE())
)
GO



--movement_type table

INSERT INTO movement_type
( 
 [type_name],[allows_wait]
)
VALUES
( 
 '1st movement type','1'
),
(
 '2nd movement type','0'
)
GO



--location table

INSERT INTO [location]
( 
 [location_name], [coordinates], [dimension],[player_id]
)
VALUES
( 
 '1st woods', '(10,10)', '2D' , '1'
),
(
 '2nd sea', '(20,20)', '2D' , '1'
),
( 
 '3rd mountain', '(30,30)', '2D' , '5'
),
(
 '4th desert', '(40,40)', '2D' , '2'
),
(
 '5th village', '(50,50)', '2D' , '3'
)
GO



--structure table

INSERT INTO structure
( 
 [structure_name],[cost],[req_level]
)
VALUES
( 
 '1st castle','100','1'
),
(
 '2nd barrack','70','1'
),
( 
 '3rd house','10','1'
),
(
 '4th church','20', '2'
),
(
 '5th playground','20','3'
),
( 
 '6st island','50','1'
)
GO



--structure_built table

INSERT INTO structure_built
( 
 [location_id],[structure_id]
)
VALUES
( 
 '4','1'
),
(
 '4','2'
),
( 
 '1','1'
),
(
 '2','6'
)
GO



--unit table

INSERT INTO unit
( 
 [unit_name],[cost],[req_level]
)
VALUES
( 
 '1st sword','5','1'
),
(
 '2nd shield','3','1'
),
( 
 '3rd horse','10','1'
)
GO


--units_on_location table

INSERT INTO units_on_location
( 
 [unit_id],[location_id],[number]
)
VALUES
( 
 '1','1','10'
),
(
 '1','4','10'
),
( 
 '2','1','10'
),
(
 '3','4', '5'
)
GO



--group_movement table

INSERT INTO group_movement
( 
 [player_id],[movement_type_id],[location_from],[location_to],[return_time],[wait_time]
)
VALUES
( 
 '5','1','3','5',GETDATE(),'0'
),
( 
 '1','2','1','2',DATEADD(MINUTE, 60, GETDATE()),'60'
)
GO



--units_in_group table

INSERT INTO units_in_group
( 
 [unit_id],[group_moving_id],[number]
)
VALUES
( 
 '1','2','10'
),
(
 '2','2','10'
)
GO

