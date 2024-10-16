USE seniordesignproject;

DELIMITER //

-- Procedure to check whether the student's attempted username and password are in the system
-- Input: Student username, Student password
-- Output: Count of matches in the system
CREATE PROCEDURE check_student_login (
	IN stu_input_username varchar(20), 
    IN stu_input_password varchar(20)
    )
BEGIN
	DECLARE user_count INT;
    
	SELECT COUNT(*) INTO user_count
	FROM Student
	WHERE StuNetID = stu_input_username AND StuPassword = stu_input_password;
    
    SELECT user_count AS user_count_result;
END //


-- Procedure to change student password
-- Input: Student Net ID, Old Password, New Password
-- Output: 0 if the password was changed, 1 if it was not
CREATE PROCEDURE change_student_password (
	IN stu_username varchar(20),
    IN old_student_password varchar(20),
    IN new_student_password varchar(20))
BEGIN
	DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count
    FROM Student
    WHERE StuNetID = stu_username AND StuPassword = old_student_password;
    
    IF user_count > 0 THEN 
		UPDATE Student
		SET StuPassword = new_student_password
		WHERE StuNetID = stu_username;
		SELECT 0 AS password_change_status;
	ELSE
		SELECT 1 AS password_change_status;
	END IF;
END //


-- Procedure for inserting timeslots into the table
-- Inputs: Student Net ID, Timeslot date, description, and duration
-- Output: 0 if the timeslot was inserted correctly, 1 if it was not
CREATE PROCEDURE student_insert_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    IN ts_description varchar(200),
    IN ts_duration varchar(5))
BEGIN
	DECLARE insert_status INT DEFAULT 0;
    IF LENGTH(ts_description) < 30 THEN 
		SET insert_status = 1;
    ELSE
		INSERT INTO Timeslot (StuNetID, TSDate, TSDescription, TSDuration)
		VALUES (stu_netID, ts_date, ts_description, ts_duration);
        SET insert_status = 0;
	END IF;
END //

-- Procedure to return the total time the student has spent for the project
-- Input: Student NetID, Start Date, End Date
-- Output: Total time in Minutes
-- CALL student_total_time('student_netID', @TotalTime); SELECT @TotalTime;
CREATE PROCEDURE student_total_time (
	IN student_netID char(9),
    OUT student_total INT)
BEGIN 
	SET student_total = 0;
    
    SELECT SUM( HOUR(SEC_TO_TIME(TIME_TO_SEC(TSDuration))) * 60 + MINUTE(SEC_TO_TIME(TIME_TO_SEC(TSDuration))))
    INTO student_total
    FROM Timeslot
    WHERE StuNetID = student_netID;
END //


-- Procedure to return the time has spent on the project within a certain date range
-- Input: Student NetID
-- Output: Total time in Minutes
-- CALL student_total_time('student_netID', 'YYYY-MM-DD', 'YYYY-MM-DD', @TotalTime); SELECT @TotalTime;
CREATE PROCEDURE student_time_in_range (
	IN student_netID char(9),
    IN startDate DATE,
    IN endDate DATE,
    OUT student_total INT)
BEGIN 
	SET student_total = 0;
    
    SELECT SUM( HOUR(SEC_TO_TIME(TIME_TO_SEC(TSDuration))) * 60 + MINUTE(SEC_TO_TIME(TIME_TO_SEC(TSDuration))))
    INTO student_total
    FROM Timeslot
    WHERE StuNetID = student_netID AND TSDate BETWEEN startDate AND endDate;
END //




-- Procedure to check whether the professor's attempted username and password are in the system
-- Input: Professor username, Professor password
-- Output: Integer count of the number of matches
CREATE PROCEDURE check_professor_login (
	IN prof_input_username varchar(20), 
    IN prof_input_password varchar(20)
    )
BEGIN
	DECLARE user_count INT;
    
	SELECT COUNT(*) INTO user_count
	FROM Professor
	WHERE ProfNetID = prof_input_username AND ProfPassword = prof_input_password;
    
    SELECT user_count AS user_count_result;
END //


-- Procedure to change student password
-- Input: Student Net ID, Old Password, New Password
-- Output: 0 if the password was changed, 1 if it was not
CREATE PROCEDURE change_professor_password (
	IN prof_username varchar(20),
    IN old_professor_password varchar(20),
    IN new_professor_password varchar(20))
BEGIN
	DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count
    FROM Professor
    WHERE ProfNetID = prof_username AND ProfPassword = old_professor_password;
    
    IF user_count > 0 THEN 
		UPDATE Professor
		SET ProfPassword = new_professor_password
		WHERE ProfNetID = prof_username;
		SELECT 0 AS password_change_status;
	ELSE 
		SELECT 1 AS password_change_status;
	END IF;
END //


-- Procedure for the professor to create a new criteria, but only if they teach the class
-- Input: Professor NetID, Section Code, Criteria Name, Criteria Description
-- Output:0 if the criteria added correctly, 1 if it was not
CREATE PROCEDURE professor_create_criteria (
	IN professor_netID char(9),
    IN section_code char(5),
    IN criteria_name varchar(35),
    IN criteria_description varchar(300))
BEGIN
	DECLARE professor_teaches INT;
    DECLARE insert_status INT;
    
    SELECT COUNT(*) INTO professor_teaches
    FROM Teaches
    WHERE ProfNetID = professor_netID AND SecCode = section_code;
    
    IF professor_teaches > 0 THEN
		INSERT INTO Criteria (SecCode, CriteriaName, CriteriaDescription)
        VALUES (section_code, criteria_name, criteria_description);
        SELECT 0 AS insert_status;
	ELSE
		SELECT 1 AS insert_status;
    END IF;
END //


-- Procedure to allow the professor to view the student's averages in his sections
-- Input: Professor Net ID, Section Code
-- Output: Pulls the student averages for each criteria
CREATE PROCEDURE professor_view_averages (
	IN professor_netID char(9),
    IN section_code char(5))
BEGIN
	SELECT Stu.StuNetID, Stu.StuName, C.CriteriaName, AVG(Sc.Score) AS AverageScore
    FROM Scored Sc
    JOIN PeerReview PR ON Sc.ReviewID = PR.ReviewID AND Sc.SecCode = PR.SecCode
    JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID AND Sc.SecCode = C.SecCode
    JOIN Student Stu ON PR.ReviewerID = Stu.StuNetID
    JOIN Attends A ON A.StuNetID = PR.ReviewerID AND A.SecCode = PR.SecCode
    JOIN Teaches T ON T.SecCode = A.SecCode AND T.ProfNetID = professor_netID
    WHERE PR.SecCode = section_code
    GROUP BY Stu.StuNetID, Stu.StuName, C.CriteriaName
    ORDER BY Stu.StuNetID, C.CriteriaName;
END //


-- Procedure for the professor to view the individual scores given to a student
-- Inputs: Professor Net ID, Section Code, Student Net ID
-- Outputs: Reviewer net ID, Reviewer Name, Criteria Name, and Score
CREATE PROCEDURE professor_view_individual_scores (
	IN professor_netID char(9),
    IN section_code char(5),
    IN student_netID char(9))

BEGIN 
	SELECT Reviewer.StuNetID AS ReviewerNetID, Reviewer.StuName AS ReviewerName, 
    C.CriteriaName, Sc.Score
    FROM Scored Sc
    JOIN PeerReview PR ON Sc.ReviewID = PR.ReviewID AND Sc.SecCode = PR.SecCode
    JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID AND Sc.Seccode = C.SecCode
    JOIN Reviewed R ON Sc.ReviewID = R.ReviewID AND Sc.SecCode = R.SecCode
    JOIN Student Stu ON R.StuNetID = Stu.StuNetID
    JOIN Student Reviewer ON PR.ReviewerID = Reviewer.StuNetID
    JOIN Attends A ON A.StuNetID = PR.ReviewerID AND A.SecCode = PR.SecCode
    JOIN Teaches T ON T.SecCode = A.SecCode AND T.ProfNetID = professor_netID
    WHERE PR.SecCode = section_code AND R.StuNetID = student_netID;
END //



-- Procedure for creating/ populating the peer reviews for a class
-- Inputs: Professor NetID, Section Code, and Review Type
-- Outputs: Populates the Peer Review, Reviewed, and Scored Tables
CREATE PROCEDURE create_peer_reviews (
	IN professor_netID char(9),
    IN section_code char(5),
    IN review_type char(7))
BEGIN 
	DECLARE creation_status INT DEFAULT 1;
    DECLARE student_id char(9);
    DECLARE done INT DEFAULT 0;
    DECLARE team_num INT DEFAULT 0;
    
    DECLARE student_cursor CURSOR FOR 
		SELECT StuNetID FROM Attends
		WHERE SecCode = section_code;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- If the professor does not teach the class they cannot create the peer review
    IF ( SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN 
		SELECT creation_status;
	END IF;
    
    -- Iterating through every student in the section 
    OPEN student_cursor;
    student_loop: LOOP
		FETCH student_cursor INTO student_id;
		IF done THEN 
			LEAVE student_loop;
		END IF;
           
		SET team_num = (SELECT TeamNum FROM MemberOf WHERE StuNetID = student_id AND SecCode = section_code);
		CALL insert_peer_reviews(student_id, team_num, review_type, section_code);
        
	END LOOP student_loop;
	CLOSE student_cursor;
    
    SET creation_status = 0;
    SELECT creation_status;
    

END //

-- Subset Procedure of the create_peer_reviews Procedure
CREATE PROCEDURE insert_peer_reviews (
	IN student_id char(9),
    IN team_num INT,
    IN review_type char(7),
    IN section_code char(5) )
BEGIN 
	DECLARE creation_status INT DEFAULT 1;
    DECLARE other_student char(9);
    DECLARE done_member INT DEFAULT 0;
    DECLARE done_criteria INT DEFAULT 0;
    DECLARE last_reviewID INT;
    DECLARE criteria_id INT;
    
    DECLARE member_cursor CURSOR FOR 
		SELECT StuNetID FROM MemberOf
        WHERE SecCode = section_code AND TeamNum = team_num;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_member = 1;
     
	-- Based on the student selected in the previous section, iterates through everyone in the same group as them
	SET done_member = 0;
	OPEN member_cursor;
	member_loop: LOOP
		
		FETCH member_cursor INTO other_student;
        IF done_member THEN 
			LEAVE member_loop;
		END IF;
        
        -- Inserts the peer reviews 
        INSERT INTO PeerReview (SecCode, ReviewType, ReviewerID)
        VALUES (section_code, review_type, other_student);
        
		SET last_reviewID = LAST_INSERT_ID();
        
        -- Inserts into the Reviewed Table 
        INSERT INTO Reviewed (StuNetID, ReviewID, SecCode)
        VALUES (student_id, last_reviewID, section_code);
        
        CALL insert_scored_table(last_reviewID, section_code);
        
	END LOOP member_loop;
    CLOSE member_cursor;
END// 

-- Sub Procedure of the create_peer_reviews Procedure
CREATE PROCEDURE insert_scored_table (
	IN review_id INT,
    IN section_code char(5))
    
BEGIN 
	DECLARE creation_status INT DEFAULT 1;
    DECLARE criteria_id INT;
    DECLARE done_criteria INT DEFAULT 0;
    
	DECLARE criteria_cursor CURSOR FOR 
		SELECT CriteriaID FROM Criteria
        WHERE SecCode = section_code;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_criteria = 1;

	-- Iterates through every criteria to add to the scored table, initialized everything to 0
	SET done_criteria = 0;
	OPEN criteria_cursor;
	criteria_loop: LOOP
		FETCH criteria_cursor INTO criteria_id;
		IF done_criteria THEN
			LEAVE criteria_loop;
		END IF;
            
		INSERT INTO Scored (ReviewID, CriteriaID, SecCode, Score)
		VALUES (review_id, criteria_id, section_code, 0);
            
	END LOOP criteria_loop;
	CLOSE criteria_cursor;

END//



-- Procedure to retrieve all timeslots for a specific student on a specific date
-- Input: Student NetID, Timeslot Date
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_date(
    IN stu_netID char(9),
    IN input_date DATE)
BEGIN
    SELECT * 
    FROM student_daily_timeslots
    WHERE StuNetID = stu_netID AND TSDate = input_date;
END //


-- Procedure to retrieve all timeslots for a specific student during a specific week (given a start date)
-- Input: Student NetID, Start Date
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_week(
    IN stu_netID char(9),
    IN start_date DATE)
BEGIN
    SELECT * 
    FROM student_daily_timeslots
    WHERE StuNetID = stu_netID AND TSDate >= start_date AND TSDate < DATE_ADD(start_date, INTERVAL 7 DAY); 
END //


-- Procedure to retrieve all timeslots for a specific student during a specific month (given a start date)
-- Input: Student NetID, Start Date
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_week(
    IN stu_netID char(9),
    IN start_date DATE)
BEGIN
    SELECT * 
    FROM student_daily_timeslots
    WHERE StuNetID = stu_netID AND TSDate >= start_date AND TSDate < DATE_ADD(start_date, INTERVAL 30 DAY); 
END //


-- Procedure to retrive the peer review criteria for a given professor's given section
-- Input: Professor NetID, Section Code
-- Output: For all criteria: Professor NetID, Criteria Name, Criteria Description, Section Code
CREATE PROCEDURE get_section_criteria(
    IN prof_netID char(9),
    IN section_code char(5))
BEGIN
    SELECT *
    FROM professor_peer_review_criteria
    WHERE ProfNetID = prof_netID AND SecCode = section_code;
END //


DELIMITER ;


