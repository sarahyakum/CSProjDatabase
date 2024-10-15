USE seniordesignproject;

DELIMITER //

-- Procedure to check whether the student's attempted username and password are in the system
-- Input: Student username, Student password
-- Output: Count of matches in the system
CREATE PROCEDURE check_student_login (
	IN stu_input_username varchar(20), 
	IN stu_input_password varchar(20))
BEGIN
	DECLARE user_count INT;
    
	SELECT COUNT(*) INTO user_count
	FROM Student
	WHERE StuNetID = stu_input_username AND StuPassword = stu_input_password;
    
	SELECT user_count AS user_count_result;
END //


-- Procedure to check whether the professor's attempted username and password are in the system
-- Input: Professor username, Professor password
-- Output: Integer count of the number of matches

CREATE PROCEDURE check_professor_login (
	IN prof_input_username varchar(20), 
	IN prof_input_password varchar(20))
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


DELIMITER ;


