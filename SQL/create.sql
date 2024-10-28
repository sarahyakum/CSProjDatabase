DROP DATABASE IF EXISTS seniordesignproject;  
CREATE DATABASE seniordesignproject;  
USE seniordesignproject;  

-- Creating the Student Table
CREATE TABLE Student (  
StuNetID char(9) NOT NULL,   
StuUTDID char(10) UNIQUE NOT NULL,   
StuName varchar(30) NOT NULL,   
StuPassword varchar(20) NOT NULL,  
PRIMARY KEY (StuNetID)  
);  

-- Creating the Professor Table
CREATE TABLE Professor (   
ProfNetID char(9) NOT NULL,  
ProfUTDID char(10) UNIQUE NOT NULL,  
ProfName varchar(30) NOT NULL,  
ProfPassword varchar(20) NOT NULL,  
PRIMARY KEY (ProfNetID)  
);  

-- Creating the Section (class) Table
CREATE TABLE Section (  
SecCode char(5) NOT NULL,  
SecName varchar(12) UNIQUE NOT NULL,  
PRIMARY KEY (SecCode)  
); 

-- Creating the Teaches Table: Relationship between professor and section
CREATE TABLE Teaches (  
ProfNetID char(9) NOT NULL,  
SecCode char(5) NOT NULL,   
PRIMARY KEY (ProfNetID, SecCode),  
FOREIGN KEY (ProfNetID) REFERENCES Professor(ProfNetID),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode) 
);  

-- Creating the Attends Table: Relationship between student and section
CREATE TABLE Attends (  
StuNetID char(9) NOT NULL,  
SecCode char(5) NOT NULL,  
PRIMARY KEY (StuNetID, SecCode),   
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)  
);  

-- Creating the Team Table: Weak entity of section
CREATE TABLE Team (  
TeamNum int NOT NULL,  
SecCode char(5) NOT NULL,  
PRIMARY KEY (TeamNum, SecCode),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)  
);  

-- Creating the MemberOf Table: Relationship between team and student
CREATE TABLE MemberOf (  
TeamNum int NOT NULL,  
SecCode char(5) NOT NULL, 
StuNetID char(9) NOT NULL,  
PRIMARY KEY (TeamNum, StuNetID, SecCode),  
FOREIGN KEY (TeamNum, SecCode) REFERENCES Team(TeamNum, SecCode),  
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID) 
);  

-- Creating the Timeslot Table: Weak entity of Student
CREATE TABLE Timeslot (   
TimeslotID int NOT NULL,  
StuNetID char(9) NOT NULL,
TSDate date NOT NULL,   
TSDescription varchar(200) NOT NULL,  
TSDuration varchar(5) NOT NULL,    
PRIMARY KEY (TimeSlotID, StuNetID),  
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID)  
);  

-- Creating the Peer Review Table
CREATE TABLE PeerReview (   
ReviewID int NOT NULL AUTO_INCREMENT, 
SecCode char(5) NOT NULL,  
ReviewType char(7) NOT NULL,  
ReviewerID char(9) NOT NULL,  
StartDate DATE NOT NULL,
EndDate DATE NOT NULL, 
PRIMARY KEY (ReviewID, SecCode),   
FOREIGN KEY (ReviewerID) REFERENCES Student(StuNetID),  
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)
);  

-- Creating the Reviewed Table: Relationship between Peer Review and student who is being reviewed 
CREATE TABLE Reviewed (   
StuNetID char(9) NOT NULL,  
ReviewID int NOT NULL,  
SecCode char(5) NOT NULL,
PRIMARY KEY (StuNetID, ReviewID, SecCode),  
FOREIGN KEY (StuNetID) REFERENCES Student(StuNetID),  
FOREIGN KEY (ReviewID, SecCode) REFERENCES PeerReview(ReviewID, SecCode)  
);  

-- Creating the Criteria Table: Weak entity of section
CREATE TABLE Criteria (   
CriteriaID int NOT NULL AUTO_INCREMENT,  
SecCode char(5) NOT NULL,
CriteriaName varchar(35) NOT NULL,  
CriteriaDescription varchar(300),  
ReviewType char(7) NOT NULL,
PRIMARY KEY (CriteriaID, SecCode),
FOREIGN KEY (SecCode) REFERENCES Section(SecCode)   
);  

-- Creating the Scored Table: Relationship between peer review and criteria
CREATE TABLE Scored (  
ReviewID int NOT NULL,   
CriteriaID int NOT NULL,   
SecCode char(5) NOT NULL,
Score int,  
PRIMARY KEY (ReviewID, CriteriaID, SecCode),  
FOREIGN KEY (ReviewID, SecCode) REFERENCES PeerReview(ReviewID, SecCode),  
FOREIGN KEY (CriteriaID, SecCode) REFERENCES Criteria(CriteriaID, SecCode)  
); 

-- Creating a trigger to auto-increment the TimeslotID on a per student basis
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

-- Creating a trigger to auto-increment the Team number on a per section basis
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

-- Creating a trigger so that the criteria auto-incremented based on the section
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
