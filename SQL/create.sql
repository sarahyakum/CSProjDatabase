/*
	Written by Emma Hockett and Darya Anbar for CS 4485.0W1, Senior Design Project, Started October 14, 2024.
         NetID: ech210001 and dxa200020
         
	Statements to create the database, and then all of the tables and triggers associated with it. This file must be run first in order to work.
    Includes the tables: Student, Professor, Section, Teaches, Attends, Team, MemberOf, Timeslot, Peer Review, Reviewed, Criteria, Scored
    Triggers: before_insert_timeslot, before_insert_team, before_criteria_team

*/

DROP DATABASE IF EXISTS seniordesignproject;  
CREATE DATABASE seniordesignproject;  
USE seniordesignproject;  


-- Student Table: Represents the students and their attrbutes
CREATE TABLE Student (  
StuNetID char(9) NOT NULL,   
StuUTDID char(10) UNIQUE NOT NULL,   
StuName varchar(30) NOT NULL,   
StuPassword varchar(20) NOT NULL,  
PRIMARY KEY (StuNetID)  
);  

-- Professor Table: Represents the professor and their attributes
CREATE TABLE Professor (   
ProfNetID char(9) NOT NULL,  
ProfUTDID char(10) UNIQUE NOT NULL,  
ProfName varchar(30) NOT NULL,  
ProfPassword varchar(20) NOT NULL,  
PRIMARY KEY (ProfNetID)  
);  

-- Section Table: Represents the sections and their attibutes
CREATE TABLE Section (  
SecCode char(5) NOT NULL,  
SecName varchar(12) UNIQUE NOT NULL,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,  
PRIMARY KEY (SecCode)  
); 

-- Teaches Table: Represents the connection between professors and section
CREATE TABLE Teaches (  
ProfNetID char(9) NOT NULL,  
SecCode char(5) NOT NULL,   
PRIMARY KEY (ProfNetID, SecCode),  
FOREIGN KEY (ProfNetID) REFERENCES Professor(ProfNetID),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode) ON UPDATE CASCADE
);  

-- Attends Table: Represents the connection between students and sections
CREATE TABLE Attends (  
StuNetID char(9) NOT NULL,  
SecCode char(5) NOT NULL,  
PRIMARY KEY (StuNetID, SecCode),   
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID) ON UPDATE CASCADE,  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)  ON UPDATE CASCADE 
);  

-- Team Table: Represents the teams for the various sections, Weak Entity of the Section Table
CREATE TABLE Team (  
TeamNum int NOT NULL,  
SecCode char(5) NOT NULL,  
PRIMARY KEY (TeamNum, SecCode),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)  ON UPDATE CASCADE
);  

-- MemberOf Table: Represents the connection between teams and student, Dependent on Section Table
CREATE TABLE MemberOf (  
TeamNum int NOT NULL,  
SecCode char(5) NOT NULL, 
StuNetID char(9) NOT NULL,  
PRIMARY KEY (TeamNum, StuNetID, SecCode),  
FOREIGN KEY (TeamNum, SecCode) REFERENCES Team(TeamNum, SecCode), 
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID) ON UPDATE CASCADE
);  

-- Timeslot Table: Represents the timeslots for the student and its attributes, Weak Entity of the Student Table
CREATE TABLE Timeslot (   
TimeslotID int NOT NULL,  
StuNetID char(9) NOT NULL,
TSDate date NOT NULL,   
TSDescription varchar(200) NOT NULL,  
TSDuration varchar(5) NOT NULL,    
PRIMARY KEY (TimeSlotID, StuNetID),  
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID)  ON UPDATE CASCADE
);  

-- PeerReview Table: Represents the broad peer review entity, Weak Entity of Section
CREATE TABLE PeerReview (   
ReviewID int NOT NULL AUTO_INCREMENT, 
SecCode char(5) NOT NULL,  
ReviewType char(7) NOT NULL,  
ReviewerID char(9) NOT NULL,  	-- Net ID of student who is doing the reviewing 
StartDate DATE NOT NULL,
EndDate DATE NOT NULL, 
PRIMARY KEY (ReviewID, SecCode),   
FOREIGN KEY (ReviewerID) REFERENCES Student(StuNetID) ON UPDATE CASCADE,  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode) ON UPDATE CASCADE
);  

-- Reviewed Table: Represents the student who is being reviewed for a Peer Review, Connection between Student and Peer Review Tables
CREATE TABLE Reviewed (   
StuNetID char(9) NOT NULL,  
ReviewID int NOT NULL,  
SecCode char(5) NOT NULL,
PRIMARY KEY (StuNetID, ReviewID, SecCode),  
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID) ON UPDATE CASCADE,  
FOREIGN KEY (ReviewID, SecCode) REFERENCES PeerReview(ReviewID, SecCode)  
);  

-- Criteria Table: Represents the criteria that will be used for a Peer Review, Weak Entity of Section 
CREATE TABLE Criteria (   
CriteriaID int NOT NULL AUTO_INCREMENT,  
SecCode char(5) NOT NULL,
CriteriaName varchar(35) NOT NULL,  
CriteriaDescription varchar(300),  
ReviewType char(7) NOT NULL,
PRIMARY KEY (CriteriaID, SecCode),
FOREIGN KEY (SecCode) REFERENCES Section(SecCode) ON UPDATE CASCADE
);  

-- Scored Table: Represents the scores that entered for a given peer review, for a given criteria, Connects Section, PeerReview, and Criteria
CREATE TABLE Scored (  
ReviewID int NOT NULL,   
CriteriaID int NOT NULL,   
SecCode char(5) NOT NULL,
Score int,  
PRIMARY KEY (ReviewID, CriteriaID, SecCode),  
FOREIGN KEY (ReviewID, SecCode) REFERENCES PeerReview(ReviewID, SecCode),  
FOREIGN KEY (CriteriaID, SecCode) REFERENCES Criteria(CriteriaID, SecCode)  
); 

-- Trigger for considering the next TimeslotId that should be inserted, dependent on each student 
DELIMITER //
CREATE TRIGGER before_insert_timeslot
BEFORE INSERT ON Timeslot
FOR EACH ROW
BEGIN
    DECLARE maxID INT;
    -- Get the maximum TimeslotID for the specific StuNetID
    SELECT COALESCE(MAX(TimeslotID), 0) INTO maxID
    FROM Timeslot
    WHERE StuNetID = NEW.StuNetID;

    -- Set the new TimeslotID
    SET NEW.TimeslotID = maxID + 1;
END; //
DELIMITER ;

/*
-- Trigger for determing the next Team Number to be used, dependent on the section
DELIMITER //
CREATE TRIGGER before_insert_team
BEFORE INSERT ON Team
FOR EACH ROW
BEGIN
    DECLARE maxTeamNum INT;
    
    -- Get the maximum TeamNum for the specific SecCode
    SELECT COALESCE(MAX(TeamNum), 0) INTO maxTeamNum
    FROM Team
    WHERE SecCode = NEW.SecCode;

    -- Set the new TeamNum by incrementing the maximum team number for the given section
    SET NEW.TeamNum = maxTeamNum + 1;
END; //
DELIMITER ;
*/

-- Trigger for the next Criteria ID number to assign, dependent on the section
DELIMITER //
CREATE TRIGGER before_criteria_team
BEFORE INSERT ON Criteria
FOR EACH ROW
BEGIN
    DECLARE maxCriteriaNum INT;
    
    -- Get the maximum TeamNum for the specific SecCode
    SELECT COALESCE(MAX(CriteriaID), 0) INTO maxCriteriaNum
    FROM Criteria
    WHERE SecCode = NEW.SecCode;

    -- Set the new TeamNum by incrementing the maximum team number for the given section
    SET NEW.CriteriaID = maxCriteriaNum + 1;
END; //
DELIMITER ;

