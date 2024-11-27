USE seniordesignproject;

/*
	Written by Emma Hockett and Darya Anbar for CS 4485.0W1, Senior Design Project, Started October 13, 2024
    Net ID: ech210001 and dxa200020
    
    Statements that are used to create all of the stored procedures for the database. Each procedure represents an interaction between the front end and the database.
    Must be run after the create.sql file and create_views.sql
    
    Student Procedures: 
		General: check_student_login, change_student_passwordm student_get_team_members, number_student_in_team, get_section_timeframe
        Time Tracking: student_insert_timeslot, student_edit_timeslot, student_edit_timeslot
        Peer Review: student_insert_score, student_get_peer_review_criteria, student_view_averages, student_peer_review_page
        
	General Procedures: student_total_time, student_time_in_range, student_timeslot_by_date, student_timeslot_by_week, student_timeslot_by_month, get_section_student
    
    Professor Procedures: 
		General: check_professor_login, change_professor_password, professor_insert_num_teams, professor_delete_team, professor_change_student_team, professor_get_sections, professor_add_students, 
			add_student_to_team, professor_add_section, 
        Time Tracking: professor_edit_timeslot, timetrack_student_emails
        Peer Review: get_section_criteriaid, professor_create_criteria, professor_edit_criteria, professor_delete_criteria, create_peer_reviews, professor_view_averages, professor_view_individual_scores,
			edit_scores_given, reuse_criteria, professor_get_incomplete_reviews, peerReview_student_emails
*/

DELIMITER //

-- Written by Emma Hockett October 13, 2024
-- Procedure to check whether the student's attempted username and password are in the system 
-- Input: Student username, Student password, A way for the error message to be returned
-- Output: Error Message: 'Success' or 'Incorrect username or password'   
CREATE PROCEDURE check_student_login (
	IN stu_input_username varchar(20), 
    IN stu_input_password varchar(20),
    OUT error_message varchar(100))
check_stu_login:BEGIN
	DECLARE user_count INT;
    SET error_message = 'Success';
    
    -- Checks whether the student is a member of the database, if they are and this is their first login prompt to change password
	IF stu_input_username NOT REGEXP '^[a-zA-Z0-9]+$' THEN
        SET error_message = 'Username must be alphanumeric';
        LEAVE check_stu_login;
	ELSEIF NOT EXISTS (SELECT * FROM Student WHERE StuNetID = stu_input_username AND StuPassword = stu_input_password) THEN 
		SET error_message = 'Incorrect username or password';
        LEAVE check_stu_login;
	ELSEIF stu_input_password = (SELECT StuUTDID FROM Student WHERE StuNetID = stu_input_username) THEN 
		SET error_message = 'Change password';
	END IF;
END //


-- Written by Emma Hockett October 13, 2024
-- Procedure to change student password 
-- Input: Student Net ID, Old Password, New Password, A variable for the error message to be returned as
-- Output: Error Message: 'Success', 'Incorrect username or password', or 'Password cannot be the same'
CREATE PROCEDURE change_student_password (
	IN stu_username varchar(20),
    IN old_student_password varchar(20),
    IN new_student_password varchar(20),
    OUT error_message varchar(100))
change_stu_password: BEGIN
	DECLARE user_count INT;
    SET error_message = 'Success';
    
	IF stu_username NOT REGEXP '^[a-zA-Z0-9]+$' THEN
        SET error_message = 'Username must be alphanumeric';
        LEAVE change_stu_password;
	END IF;
    
    SELECT COUNT(*) INTO user_count
    FROM Student
    WHERE StuNetID = stu_username AND StuPassword = old_student_password;
    
    -- Prevents certain passwords: the same as the last password, or their UTDID
	IF user_count < 1 THEN 
		SET error_message = 'Incorrect username or password';
        LEAVE change_stu_password;
	ELSEIF old_student_password = new_student_password THEN 
		SET error_message = 'Password cannot be the same';
        LEAVE change_stu_password;
	ELSEIF new_student_password = (SELECT StuUTDID FROM Student WHERE StuNetID = stu_username) THEN 
		SET error_message = 'Password cannot be UTD ID';
        LEAVE change_stu_password;
	END IF;
    
	UPDATE Student
	SET StuPassword = new_student_password
	WHERE StuNetID = stu_username;

END //


-- Written by Emma Hockett, October 13, 2024
-- Procedure for inserting timeslots into the table, descipriotn >= 30 characters, Within past 3 days and not in future
-- Inputs: Student Net ID, Timeslot date, description, duration, and a variable to hold the error message
-- Output: Error Message: 'Success' or a description of which condition it violated
CREATE PROCEDURE student_insert_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    IN ts_description varchar(200),
    IN ts_duration varchar(5),
    OUT error_message varchar(100))
inserting_timeslot:BEGIN
	SET error_message = 'Success';
    
    -- Checking constraints: Description longer than 30 characters, Date in past 3 days, Duration in correct format, Duration not unreasonable, and in Increments of 15 minutes
    IF NOT EXISTS (SELECT * FROM Attends WHERE StuNetID = student_netID) THEN 
		SET error_message = 'Not a member of a section';
        LEAVE inserting_timeslot;
	ELSEIF EXISTS (SELECT * FROM Timeslot WHERE StuNetId = student_netID AND TSDate = ts_date) THEN 
		SET error_message = 'Only one timeslot allowed per day, to add more time Edit Timeslot';
        LEAVE inserting_timeslot;
    ELSEIF (LENGTH(ts_description) < 30) THEN
		SET error_message = 'Description must be at least 30 characters';
        LEAVE inserting_timeslot;
    ELSEIF (ts_date <= NOW() - INTERVAL 3 DAY) THEN
		SET error_message = 'Can only insert timeslots within the past 3 days';
        LEAVE inserting_timeslot;
    ELSEIF (ts_date > NOW()) THEN
		SET error_message = 'Cannot add timeslots for future dates';
        LEAVE inserting_timeslot;
    ELSEIF (ts_duration NOT REGEXP '^(2[0-3]|[01][0-9]):([0-5][0-9])$') THEN 
		SET error_message = 'Durations must be in the form HH:MM and cannot 24 or more hours or more than 60 minutes.';
        LEAVE inserting_timeslot;
	ELSEIF (TIME_TO_SEC(STR_TO_DATE(ts_duration, '%H:%i')) < TIME_TO_SEC('00:15')) THEN
        SET error_message = 'Duration must be at least 15 minutes';
        LEAVE inserting_timeslot;
    ELSEIF (MINUTE(STR_TO_DATE(ts_duration, '%H:%i')) NOT IN (0, 15, 30, 45)) THEN
        SET error_message = 'Duration must be rounded to the nearest 15 minutes';
        LEAVE inserting_timeslot;
	ELSEIF ts_date NOT BETWEEN (SELECT StartDate From Section WHERE SecCode = (SELECT SecCode FROM Attends WHERE StuNetID = student_netID)) AND (SELECT EndDate From Section WHERE SecCode = (SELECT SecCode FROM Attends WHERE StuNetID = student_netID)) THEN 
		SET error_message = 'Timeslot date must be within the section timeframe';
        LEAVE inserting_timeslot;
    END IF;
    
	INSERT INTO Timeslot (StuNetID, TSDate, TSDescription, TSDuration)
	VALUES (student_netID, ts_date, ts_description, ts_duration);
    
END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to allow students to edit their timeslot, have to be within past 3 days and the description has to be longer than 30 characters 
-- Inputs: Student NetId, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Deuration, and a variable to hold the error message
-- Outputs: Error Message: 'Success' or a description of which condition it violated
CREATE PROCEDURE student_edit_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    IN updated_description varchar(200),
    IN updated_duration char(5),
    OUT error_message varchar(100))
edit_timeslot:BEGIN 
	SET error_message = 'Success';
    
    -- Checking constraints: Checking the constraints on the desciption and duartion before allowing any changes 
    IF NOT EXISTS (SELECT * FROM Timeslot WHERE TSDate = ts_date AND StuNetID = student_netID) THEN 
		SET error_message = 'Timeslot does not exist for this date';
		LEAVE edit_timeslot;
    ELSEIF (LENGTH(updated_description) < 30) THEN
		SET error_message = 'Description must be at least 30 characters';
        LEAVE edit_timeslot;
    ELSEIF (ts_date <= NOW() - INTERVAL 3 DAY) THEN
		SET error_message = 'Can only edit timeslots within the past 3 days';
        LEAVE edit_timeslot;
    ELSEIF (updated_duration NOT REGEXP '^(2[0-3]|[01][0-9]):([0-5][0-9])$') THEN 
		SET error_message = 'Durations must be in the form HH:MM and cannot 24 or more hours or more than 60 minutes.';
        LEAVE edit_timeslot;
	ELSEIF (TIME_TO_SEC(STR_TO_DATE(ts_duration, '%H:%i')) < TIME_TO_SEC('00:15')) THEN
        SET error_message = 'Duration must be at least 15 minutes';
        LEAVE edit_timeslot;
    ELSEIF (MINUTE(STR_TO_DATE(ts_duration, '%H:%i')) NOT IN (0, 15, 30, 45)) THEN
        SET error_message = 'Duration must be rounded to the nearest 15 minutes';
        LEAVE edit_timeslot;
    END IF;
    
    UPDATE Timeslot
    SET TSDuration = updated_duration, TSDescription = updated_description
    WHERE StuNetID = student_netID AND TSDate = ts_date;

END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to allow students to delete timeslots that are within the three previous days
-- Inputs: Student NetID, Timeslot Date, and a variable to hold the error message
-- Outputs: Error Message: 'Success' or 'Must be within the previous 3 days to delete'
CREATE PROCEDURE student_delete_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    OUT error_message varchar(100))
delete_timeslot: BEGIN 
	SET error_message = 'Success';
    
    IF ts_date >= NOW() - INTERVAL 3 DAY THEN 
		SET error_message = 'Must be within the previous 3 days to delete';
        LEAVE delete_timeslot;
	ELSEIF NOT EXISTS (SELECT * FROM Timeslot WHERE StuNetID = student_netID AND TSDate = ts_date) THEN
		SET error_message = 'Timeslot does not exist for this date';
        LEAVE delete_timeslot;
	END IF;
    
    DELETE FROM Timeslot 
    WHERE TSDate = ts_date AND StuNetID = student_netID;

END //


-- Written by Darya Anbar and Emma Hockett, Started October 14, 2024
-- Procedure to return the total time the student has spent for the project
-- Input: Student NetID, Start Date, End Date
-- Output: Total time in Minutes
CREATE PROCEDURE student_total_time (
	IN student_netID char(9),
    OUT student_total INT)
BEGIN 
    
    SET student_total = (SELECT SUM( HOUR(SEC_TO_TIME(TIME_TO_SEC(TSDuration))) * 60 + MINUTE(SEC_TO_TIME(TIME_TO_SEC(TSDuration))))
    FROM Timeslot
    WHERE StuNetID = student_netID);
    
END //


-- Written by Darya Anbar and Emma Hockett, Started October 15, 2024
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


-- Written by Darya Anbar, Started October 16, 2024
-- Procedure to retrieve all timeslots for a specific student on a specific date 
-- Input: Student NetID, Timeslot Date ('YYYY-MM-DD')
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_date(
    IN stu_netID char(9),
    IN input_date DATE)
BEGIN
    SELECT * 
    FROM student_timeslots
    WHERE StuNetID = stu_netID AND TSDate = input_date;
END //


-- Written by Darya Anbar, Started October 16, 2024
-- Procedure to retrieve all timeslots for a specific student during a specific week (given a start date)
-- Input: Student NetID, Start Date
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_week(
    IN stu_netID char(9),
    IN start_date DATE)
BEGIN
    SELECT * 
    FROM student_timeslots
    WHERE StuNetID = stu_netID AND TSDate >= start_date AND TSDate < DATE_ADD(start_date, INTERVAL 7 DAY); 
END //

-- Written by Darya Anbar, Started October 16, 2024
-- Procedure to retrieve all timeslots for a specific student during a specific month (given a start date) 
-- Input: Student NetID, Start Date
-- Output: For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
CREATE PROCEDURE student_timeslot_by_month(
    IN stu_netID char(9),
    IN start_date DATE)
BEGIN
    SELECT * 
    FROM student_timeslots
    WHERE StuNetID = stu_netID AND TSDate >= start_date AND TSDate < DATE_ADD(start_date, INTERVAL 30 DAY); 
END //


-- Written by Darya Anbar, Started October 23, 2024
-- Procedure to retrieve the peer review criteria for a particular student and section (given the review type)
-- Input: Student NetID, Review Type (Midterm or Final), Section Code
-- Output: For all criteria: Criteria Name, Criteria Description
CREATE PROCEDURE student_get_peer_review_criteria (
    IN stu_netID char(9),
    IN review_type char(7),
    IN section_code char(5))
BEGIN
    SELECT CriteriaName, CriteriaDescription
    FROM student_peer_review_criteria
    WHERE StuNetID = stu_netID AND SecCode = section_code AND ReviewType = review_type;
END //


-- Written by Darya Anbar, Started on October 23, 2024
-- Procedure to retrieve the team members of a particular team in a specific section
-- Input: Team Number, Section Code
-- Output: For all team members: Student Name, Student NetID
CREATE PROCEDURE student_get_team_members (
    IN team_num int,
    IN section_code char(5))
BEGIN
    SELECT StuName, StuNetID
    FROM student_team_and_section
    WHERE TeamNum = team_num AND SecCode = section_code;
END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to insert a student score for another student 
-- Input: Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, Review Type, New Score, @Variable to get the error message
-- Output: Error Message: 'Success' or the condition that was not met
CREATE PROCEDURE student_insert_score (
	IN section_code char(5),
	IN reviewer_netID char(9),
    IN reviewee_netID char(9),
    IN criteria_name varchar(35),
    IN review_type char(7),
    IN updated_score INT,
    OUT error_message varchar(100))
inserting_score: BEGIN
	DECLARE review_id INT DEFAULT 0;
    DECLARE criteria_id INT DEFAULT 0;
    SET error_message = 'Success';
    
    SET review_id = (SELECT pr.ReviewID FROM PeerReview pr JOIN Reviewed r
		ON pr.ReviewID = r.ReviewID AND pr.SecCode = r.SecCode
		WHERE pr.SecCode = section_code AND pr.ReviewerID = reviewer_netID AND r.StuNetID = reviewee_netID AND pr.ReviewType = review_type); 
        	
    SET criteria_id = (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND CriteriaName = criteria_name AND ReviewType = review_type);
    
    -- Checks that the Review and Criteria exists, and that the score must be between 0 and 5 and not NULL
    IF (criteria_id IS NULL) THEN 
		SET error_message = 'Criteria ID does not exist';
        LEAVE inserting_score;
    ELSEIF (review_ID IS NULL) THEN 
		SET error_message = 'Review does not exist';
        LEAVE inserting_score;
	ELSEIF updated_score = NULL THEN 
		SET error_message = 'Score must have a value between 0 and 5';
        LEAVE inserting_score;
    ELSEIF (updated_score > 5) OR (updated_score < 0) THEN 
		SET error_message = 'Score must be between 0 and 5';
        LEAVE inserting_score;
	END IF;
    
    UPDATE Scored
    SET Score = updated_score
    WHERE SecCode = section_code AND ReviewID = review_id AND CriteriaID = criteria_id;
END //


-- Written by Darya Anbar, Started October 23, 2024
-- Procedure to get the average score that a student received for each criteria (given the review type)
-- Input: Student NetID, Section Code, Review Type (Midterm or Final)
-- Output: For each criteria: Criteria Name and Average Score
CREATE PROCEDURE student_view_averages (
    IN stu_netID char(9),
    IN section_code char(5),
    IN review_type char(7))
BEGIN
    SELECT CriteriaName, AVG(Score) AS AvgScore
    FROM student_scores_received
    WHERE StuNetID = stu_netID AND SecCode = section_code AND ReviewType = review_type
    GROUP BY CriteriaName;
END //


-- Written by Emma Hockett, Started October 13, 2024
-- Procedure to check whether the professor's attempted username and password are in the system
-- Input: Professor username, Professor password, @Variable to get the error message
-- Output: Error Message: 'Success' or 'Incorrect username or password'
CREATE PROCEDURE check_professor_login (
	IN prof_input_username varchar(20), 
    IN prof_input_password varchar(20),
    OUT error_message varchar(100))
check_prof_login:BEGIN
	DECLARE user_count INT DEFAULT 0;
	SET error_message = 'Success';
    
	IF prof_input_username NOT REGEXP '^[a-zA-Z0-9]+$' THEN
        SET error_message = 'Username must be alphanumeric';
        LEAVE check_prof_login;
	END IF;
    
	SELECT COUNT(*) INTO user_count
	FROM Professor
	WHERE ProfNetID = prof_input_username AND ProfPassword = prof_input_password;
    
    IF user_count < 1 THEN 
		SET error_message = 'Incorrect username or password';
        LEAVE check_prof_login;
	ELSEIF prof_input_password = (SELECT ProfUTDID FROM Professor WHERE ProfNetID = prof_input_username) THEN 
		SET error_message = 'Change password';
	END IF;
END //


-- Written by Emma Hockett, Started October 13, 2024
-- Procedure to change professor password
-- Input: Student Net ID, Old Password, New Password, @Variable to hold get the error message
-- Output: Error Message: 'Success" or the condition that was not met
CREATE PROCEDURE change_professor_password (
	IN prof_username varchar(20),
    IN old_professor_password varchar(20),
    IN new_professor_password varchar(20),
    OUT error_message varchar(100))
prof_change_pass: BEGIN
	DECLARE user_count INT;
    SET error_message = 'Success';
    
	IF prof_username NOT REGEXP '^[a-zA-Z0-9]+$' THEN
        SET error_message = 'Username must be alphanumeric';
        LEAVE prof_change_pass;
	END IF;
    
    SELECT COUNT(*) INTO user_count
    FROM Professor
    WHERE ProfNetID = prof_username AND ProfPassword = old_professor_password;
    
    -- Checks Condiitons: User exists, the new password is not the same as the old one, the new password is not the UTDID
    IF user_count < 1 THEN 
		SET error_message = 'Incorrect username or password';
        LEAVE prof_change_pass;
	ELSEIF old_professor_password = new_professor_password THEN 
		SET error_message = 'Password cannot be the same';
        LEAVE prof_change_pass;
	ELSEIF new_professor_password = (SELECT ProfUTDID FROM Professor WHERE ProfNetID = prof_username) THEN 
		SET error_message = 'Password cannot be UTD ID';
        LEAVE prof_change_pass;
	END IF;
    
	UPDATE Professor
	SET ProfPassword = new_professor_password
	WHERE ProfNetID = prof_username;

END //


-- Written by Emma Hockett, Started October 15, 2024
-- Procedure for the professor to create a new criteria, but only if they teach the class
-- Input: Professor NetID, Section Code, Criteria Name, Criteria Description,  Review Type, @Variable to get error status
-- Output: Error Message: 'Success' or condition that was not met
CREATE PROCEDURE professor_create_criteria (
	IN professor_netID char(9),
    IN section_code char(5),
    IN criteria_name varchar(35),
    IN criteria_description varchar(300),
    IN review_type char(7),
    OUT error_message varchar(100))
create_criteria:BEGIN
	DECLARE professor_teaches INT DEFAULT 0;
    DECLARE criteria_name_count INT DEFAULT 0;
    SET error_message = 'Success';
    
    -- The criteria cannot have the same name as a different one for that review type
    IF NOT EXISTS (SELECT * FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code)THEN 
		SET error_message = 'Can only create criteria for your class';
        LEAVE create_criteria;
	ELSEIF EXISTS (SELECT * FROM Criteria WHERE CriteriaName = criteria_name AND SecCode = section_code AND ReviewType = review_type) THEN 
		SET error_message = 'Cannot have the same name as an existing criteria of this type';
        LEAVE create_criteria;
	END IF;
    
	INSERT INTO Criteria (SecCode, CriteriaName, CriteriaDescription, ReviewType)
	VALUES (section_code, criteria_name, criteria_description, review_type);

END //

-- Written by Darya Anbar, Started October 15, 2024
-- Procedure to allow the professor to view a student's average scores received for a review type 
-- Input: Professor NetID, Student NetID, Section Code, Review Type
-- Output: For each criteria: Criteria Name and Average Score
CREATE PROCEDURE professor_view_averages (
	IN prof_netID char(9),
    IN stu_netID char(9),
    IN section_code char(5),
    IN review_type char(7))
BEGIN
    SELECT CriteriaName, AVG(Score) AS AvgScore
    FROM professor_student_scores
    WHERE ProfNetID = prof_netID AND RevieweeNetID = stu_netID AND SecCode = section_code AND ReviewType = review_type
    GROUP BY CriteriaName;
END //


-- Written by Emma Hockett, Started October 15, 2024
-- Procedure for the professor to view the individual scores given to a student 
-- Inputs: Professor Net ID, Section Code, Student Net ID, Review Type
-- Outputs: Reviewer net ID, Reviewer Name, Criteria Name, and Score
CREATE PROCEDURE professor_view_individual_scores (
	IN professor_netID char(9),
    IN section_code char(5),
    IN student_netID char(9),
    IN review_type char(7))
BEGIN 
	SELECT Reviewer.StuNetID AS ReviewerNetID, Reviewer.StuName AS ReviewerName, 
    C.CriteriaName, Sc.Score
    FROM Scored Sc
    JOIN PeerReview PR ON Sc.ReviewID = PR.ReviewID AND Sc.SecCode = PR.SecCode
    JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID AND Sc.Seccode = C.SecCode AND C.ReviewType = PR.ReviewType
    JOIN Reviewed R ON Sc.ReviewID = R.ReviewID AND Sc.SecCode = R.SecCode
    JOIN Student Stu ON R.StuNetID = Stu.StuNetID
    JOIN Student Reviewer ON PR.ReviewerID = Reviewer.StuNetID
    JOIN Attends A ON A.StuNetID = PR.ReviewerID AND A.SecCode = PR.SecCode
    JOIN Teaches T ON T.SecCode = A.SecCode AND T.ProfNetID = professor_netID
    WHERE PR.SecCode = section_code AND R.StuNetID = student_netID AND PR.ReviewType = review_type;
END //


-- Written by Emma Hockett, Started October 15, 2024
-- Procedure for creating/ populating the peer reviews for a class 
-- Inputs: Professor NetID, Section Code, and Review Type
-- Outputs: Populates the Peer Review, Reviewed, and Scored Tables
CREATE PROCEDURE create_peer_reviews (
	IN professor_netID char(9),
    IN section_code char(5),
    IN review_type char(7),
    IN start_date DATE,
    IN end_date DATE,
    OUT error_message varchar(100))
creating_peer_reviews:BEGIN 
    DECLARE student_id char(9);
    DECLARE done INT DEFAULT 0;
    DECLARE team_num INT DEFAULT 0;
    DECLARE student_cursor CURSOR FOR 
		SELECT StuNetID FROM Attends
		WHERE SecCode = section_code;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    SET error_message = 'Success';
    
    -- Checking conditions before it allows the professor to create peer reviews
    IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN 
		SET error_message = 'Can only create peer reviews for classes you teach';
        LEAVE creating_peer_reviews;
	ELSEIF NOT EXISTS (SELECT * FROM Attends WHERE SecCode = section_code) THEN 
		SET error_message = 'No students currently in this section';
        LEAVE creating_peer_reviews;
	ELSEIF NOT EXISTS (SELECT * FROM Criteria WHERE SecCode = section_code AND ReviewType = review_type) THEN 
		SET error_message = 'No criteria for this section or review type currently';
        LEAVE creating_peer_reviews;
	ELSEIF NOT EXISTS (SELECT * FROM MemberOf WHERE SecCode = section_code) THEN 
		SET error_message = 'No students on teams for this section currently';
        LEAVE creating_peer_reviews;
	ELSEIF (SELECT COUNT(*) FROM Student S LEFT JOIN MemberOf M ON S.StuNetID = M.StuNetID WHERE M.TeamNum IS NULL) > 0 THEN 
		SET error_message = 'There are students who are not on a team';
        LEAVE creating_peer_reviews;
	ELSEIF EXISTS (SELECT * FROM PeerReview WHERE SecCode = section_code AND ReviewType = review_type) THEN 
		SET error_message = 'Peer Reviews of this type already exist';
        LEAVE creating_peer_reviews;
	ELSEIF start_date >= end_date THEN 
		SET error_message = 'Start date must be before the end date';
        LEAVE creating_peer_reviews;
	ELSEIF EXISTS (SELECT * FROM PeerReview WHERE SecCode = section_code AND 
		(start_date BETWEEN StartDate AND EndDate OR end_date BETWEEN StartDate AND EndDate
		OR StartDate BETWEEN start_date AND end_date OR EndDate BETWEEN start_date AND end_date)) THEN 
		SET error_message = 'Peer Reviews cannot overlap in availability';
        LEAVE creating_peer_reviews;
	ELSEIF start_date <= (SELECT StartDate FROM Section WHERE SecCode = section_code) OR start_date >= (SELECT EndDate FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'Start date must be within the section time frame';
        LEAVE creating_peer_reviews;
	ELSEIF end_date <= (SELECT StartDate FROM Section WHERE SecCode = section_code) OR end_date >= (SELECT EndDate FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'End Date must be within the section time frame';
        LEAVE creating_peer_reviews;
	END IF;
    
    -- Iterating through every student in the section so that they all get their own to Reviews
    OPEN student_cursor;
    student_loop: LOOP
		FETCH student_cursor INTO student_id;
		IF done THEN 
			LEAVE student_loop;
		END IF;
           
		SET team_num = (SELECT TeamNum FROM MemberOf WHERE StuNetID = student_id AND SecCode = section_code);
        
        -- Calls this procedure to iterate through every member of this students team
		CALL insert_peer_reviews(student_id, team_num, review_type, section_code, start_date, end_date);
        
	END LOOP student_loop;
	CLOSE student_cursor;

END //

-- Written by Emma Hockett, Started October 15, 2024
-- Subset Procedure of the create_peer_reviews Procedure 
CREATE PROCEDURE insert_peer_reviews (
	IN student_id char(9),
    IN team_num INT,
    IN review_type char(7),
    IN section_code char(5),
    IN start_date DATE,
    IN end_date DATE)
inserting_peer_and_scored: BEGIN 
    DECLARE other_student char(9);
    DECLARE done_member INT DEFAULT 0;
    DECLARE done_criteria INT DEFAULT 0;
    DECLARE last_reviewID INT;
    DECLARE criteria_id INT;
    DECLARE member_cursor CURSOR FOR 
		SELECT StuNetID FROM MemberOf
        WHERE SecCode = section_code AND TeamNum = team_num;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_member = 1;
	
	-- Based on the student selected in the previous section, iterates through everyone in the same group
	SET done_member = 0;
	OPEN member_cursor;
	member_loop: LOOP
		
		FETCH member_cursor INTO other_student;
        IF done_member THEN 
			LEAVE member_loop;
		END IF;
        
        -- Inserts the peer reviews where the student is the the one being reviewed 
        INSERT INTO PeerReview (SecCode, ReviewType, ReviewerID, StartDate, EndDate)
        VALUES (section_code, review_type, other_student, start_date, end_date);
        
		SET last_reviewID = LAST_INSERT_ID();
        
        -- Inserts the peer reviews into the Reviewed Table so the student is being reviewed 
        INSERT INTO Reviewed (StuNetID, ReviewID, SecCode)
        VALUES (student_id, last_reviewID, section_code);
        
        -- Calls this to iterate through each criteria for this review type to populate the Scored Table
        CALL insert_scored_table(last_reviewID, review_type, section_code);
        
	END LOOP member_loop;
    CLOSE member_cursor;
END// 

-- Written by Emma Hockett, Started October 15, 2024
-- Sub Procedure of the create_peer_reviews Procedure (Emma)
CREATE PROCEDURE insert_scored_table (
	IN review_id INT,
    IN review_type char(7),
    IN section_code char(5))
    
BEGIN 
    DECLARE criteria_id INT;
    DECLARE done_criteria INT DEFAULT 0;
    
	DECLARE criteria_cursor CURSOR FOR 
		SELECT CriteriaID FROM Criteria
        WHERE SecCode = section_code AND ReviewType = review_type;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_criteria = 1;

	-- Iterates through every criteria for each Peer Review, sets all scores to NULL initially
	SET done_criteria = 0;
	OPEN criteria_cursor;
	criteria_loop: LOOP
		FETCH criteria_cursor INTO criteria_id;
		IF done_criteria THEN
			LEAVE criteria_loop;
		END IF;
            
		INSERT INTO Scored (ReviewID, CriteriaID, SecCode, Score)
		VALUES (review_id, criteria_id, section_code, NULL);
            
	END LOOP criteria_loop;
	CLOSE criteria_cursor;

END//


-- Written by Emma Hockett, Statred on November 20, 2024
-- Procedure to change the dates for a peer review
-- Inputs: Section code, Review type, updated start date, updates end date, @Variable for status update
-- Outputs: Success or the condition that was not met
CREATE PROCEDURE edit_peer_review_dates (
	IN section_code char(5),
    IN review_type char(7),
    IN start_date DATE,
    IN end_date DATE,
    OUT error_message varchar(200))
edit_pr_dates:BEGIN
	
    IF start_date >= end_date THEN
		SET error_message = 'Start date must be before the end end date';
        LEAVE edit_pr_dates;
	ELSEIF EXISTS (SELECT * FROM PeerReview WHERE SecCode = section_code AND ReviewType != review_type AND 
		(start_date BETWEEN StartDate AND EndDate OR end_date BETWEEN StartDate AND EndDate
		OR StartDate BETWEEN start_date AND end_date OR EndDate BETWEEN start_date AND end_date)) THEN 
		SET error_message = 'Peer Reviews cannot overlap in availability';
        LEAVE edit_pr_dates;
	ELSEIF start_date <= (SELECT StartDate FROM Section WHERE SecCode = section_code) OR start_date >= (SELECT EndDate FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'Start date must be within the section time frame';
        LEAVE edit_pr_dates;
	ELSEIF end_date <= (SELECT StartDate FROM Section WHERE SecCode = section_code) OR end_date >= (SELECT EndDate FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'End Date must be within the section time frame';
        LEAVE edit_pr_dates;
	END IF;
    
    UPDATE PeerReview
    SET StartDate = start_date, EndDate = end_date
    WHERE SecCode = section_code AND ReviewType = review_type;
    
    SET error_message = 'Success';


END //



-- Written by Emma Hockett, Started on November 20, 2024
-- Procedure to delete a type of peer reviews
-- Inputs: Section code, Review Type, @Variable for the status message
-- Outputs: Success or not
CREATE PROCEDURE delete_peer_review (
	IN section_code char(5),
    IN review_type char(7),
    OUT error_message varchar(200))
delete_pr:BEGIN
	SET error_message = 'Not Success';

	SET SQL_SAFE_UPDATES = 0;
    
	DELETE FROM Reviewed
	WHERE ReviewID IN (SELECT ReviewID FROM PeerReview WHERE SecCode = secCode AND ReviewType = reviewType) AND SecCode = secCode;

    
	DELETE FROM Scored
    WHERE ReviewID IN (SELECT ReviewID FROM PeerReview WHERE SecCode = section_code AND ReviewType = review_type) AND SecCode = section_code;
    
    DELETE FROM PeerReview
    WHERE SecCode = section_code AND ReviewType = review_type;

	SET SQL_SAFE_UPDATES = 1;
	SET error_message = 'Success';

END//


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to edit the scores that a student gave to a different student
-- Professor NetID, Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, New Score, Reiew Type, @Variable for error message
-- Outputs: Error Message: 'Success' or condition that was not met
CREATE PROCEDURE edit_scores_given (
	IN professor_netID char(9),
    IN section_code char(5),
    IN reviewer_netID char(9),
    IN reviewee_netID char(9),
    IN criteria_name varchar(35),
    IN new_score INT,
    IN review_type char(7),
    OUT error_message varchar(100))
edit_score: BEGIN 
    DECLARE criteria_id INT;
    DECLARE review_id INT;
    SET error_message = 'Success';
    
    -- Only allows the professor to alter the scores and must be within the constraints
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SET error_message = 'Can only edit scores for your classes';
        LEAVE edit_score;
	ELSEIF (new_score > 5) OR (new_score < 0) THEN 
		SET error_message = 'Score must be between 0 and 5';
        LEAVE edit_score;
	ELSEIF (SELECT COUNT(*) FROM Criteria WHERE SecCode = section_code AND CriteriaName = criteria_name AND ReviewType = review_type ) < 1 THEN
		SET error_message = 'Criteria does not exist for this section or review type';
        LEAVE edit_score;
	END IF;
    
    SET criteria_id = (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND CriteriaName = criteria_name AND ReviewType = review_type);
    SET review_id = (SELECT pr.ReviewID FROM PeerReview pr JOIN Reviewed r
		ON pr.ReviewID = r.ReviewID AND pr.SecCode = r.SecCode
		WHERE pr.SecCode = section_code AND pr.ReviewerID = reviewer_netID AND r.StuNetID = reviewee_netID ); 
    
    UPDATE Scored
    SET Score = new_score
    WHERE CriteriaID = criteria_id AND SecCode = section_code AND ReviewID = review_id;

END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to insert the correct number of teams for a section
-- Inputs: Professor NetID, Section Code, Number of Teams for section, @Variable for error message
-- Outputs: Error Message: 'Success' or the condition that was not met
CREATE PROCEDURE professor_insert_team_num(
	IN section_code char(5),
    IN team_num INT,
    OUT error_message varchar(100))
insert_teams: BEGIN 
	SET error_message = 'Success';
    
	IF EXISTS (SELECT * FROM Team WHERE SecCode = section_code AND TeamNum = team_num) THEN 
		SET error_message = 'Team already exists';
        LEAVE insert_teams;
	END IF;
        
	-- Inserting the team number into for the section 
	INSERT INTO Team(TeamNum, SecCode)
    VALUES(team_num, section_code);
    
END //

-- Written by Emma Hockett, Started November 20, 2024
-- Procedure to allow the professor to change the team number 
-- Inputs: Section Code, Old Team Number, New Team Number, @Variable for status message
-- Outputs: Success or not
CREATE PROCEDURE professor_edit_team_num(
	IN section_code char(5),
    IN team_num INT,
    IN new_team_num INT,
    OUT error_message varchar(100))
edit_teams: BEGIN 
	SET error_message = 'Not Success';
    
    IF EXISTS (SELECT * FROM Team WHERE SecCode = section_code AND TeamNum = new_team_num) THEN 
		SET error_message = "Team Number already in use for this section";
        LEAVE edit_teams;
	END IF;
    
	UPDATE Team
    SET TeamNum = new_team_num
    WHERE TeamNum = team_num;
    
    SET error_message = 'Success';
    
END //

-- Written by Emma Hockett, Started on November 17, 2024
-- Procedure to check whether a team number already exists for a section 
-- Inputs: Section Code, Team Number, @Variable for return message
-- Outputs: Whether the team exists in that section 

CREATE PROCEDURE check_if_team_exists(
	IN section_code char(9),
    IN team_num INT,
    OUT error_message varchar(200))
BEGIN
	IF EXISTS (SELECT * FROM Team WHERE SecCode = section_code AND TeamNum = team_num) THEN 
		SET error_message = "Team exists";
	ELSE
		SET error_message = "Team doesn't exist";
	END IF;

END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to Delete a team from the database, will remove all of the students from the team first
-- Inputs: Professor NetID, Section Code, Team Num, @Variable for error message
-- Outputs: Error Message: 'Success' or the condition that was not met
CREATE PROCEDURE professor_delete_team (
    IN section_code char(5),
    IN team_num INT,
    OUT error_message varchar(100))
team_deletion:BEGIN 
	SET error_message = 'Success';
    
	IF (SELECT COUNT(*) FROM Team WHERE TeamNum = team_num AND SecCode = section_Code) < 1 THEN 
		SET error_message = 'Team does not exist for this section';
        LEAVE team_deletion;
	END IF;
    
    -- Deletes insatnces from the MemberOf table with this team number and section before deleting the team
    DELETE FROM MemberOf
    WHERE TeamNum = team_num AND SecCode = section_code;
    
    DELETE FROM Team
    WHERE TeamNum = team_num AND SecCode = section_code;
END //

-- Written by Darya Anbar, Started October 16, 2024
-- Procedure to get the CriteriaID and info for a section before it it edited 
-- Input: Professor NetID, Section Code, Review Type, @Variable for error message
-- Output: CriteriaId, Criteria Name, Criteria Description
CREATE PROCEDURE get_section_criteriaid(
    IN professor_netID char(9),
    IN section_code char(5),
    IN review_type char(7),
    OUT error_message varchar(100))
get_criteriaid: BEGIN
	SET error_message = 'Success';
    
    IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SET error_message = 'Can only retrieve information about your class';
        LEAVE get_criteriaid;
	ELSEIF NOT EXISTS (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND ReviewType = review_type) THEN 
		SET error_message = 'Criteria does not exist for either this section of this review type';
        LEAVE get_criteriaid;
	END IF;
    
    SELECT CriteriaID, CriteriaName, CriteriaDescription
    FROM Criteria
    WHERE SecCode = section_code AND ReviewType = review_type;
END //


-- Written by Emma Hockett, Started on November 20, 2024
-- Procedure to check whether a peer review of this type exists 
-- Inputs: Section code, review type, @Variable for status message
-- Outputs: Whether there is a peer review that exists
CREATE PROCEDURE check_type_in_pr (
	IN section_code char(5),
    IN review_type char(7),
    OUT error_message varchar(200))
BEGIN 

	IF EXISTS (SELECT * FROM PeerReview WHERE ReviewType = review_type AND SecCode = section_code) THEN 
		SET error_message = 'Peer Review exists';
	else
		SET error_message = 'Does not exist';
	END IF;

END //

-- Written by Emma Hockett, October 17, 2024
-- Procedure to edit the criteria 
-- Input: Professor NetID, Section Code, CriteriaID, Updated Criteria Name, updated Criteria Description, Review Type, @Variable for error message
-- Output: Error Message: 'Success' or condition that was not met
CREATE PROCEDURE professor_edit_criteria (
	IN section_code char(5), 
    IN criteria_id INT, 
    IN criteria_name varchar(35),
    IN criteria_description varchar(300), 
    IN review_type char(7),
    OUT error_message varchar(100))
edit_criteria: BEGIN
	SET error_message = 'Success';
    
	IF NOT EXISTS (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND ReviewType = review_type) THEN 
		SET error_message = 'Criteria either does not exist for this section or this review type';
        LEAVE edit_criteria;
	ELSEIF EXISTS (SELECT * FROM Criteria WHERE CriteriaID != criteria_id AND CriteriaName = criteria_name AND ReviewType = review_type) THEN 
		SET error_message = 'Criteria with updated name already exists for this review type.';
        LEAVE edit_criteria;
	END IF;
    
    UPDATE Criteria
    SET CriteriaName = criteria_name, CriteriaDescription = criteria_description
    WHERE CriteriaID = criteria_id;

END //



-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to allow a professor to delete a criteria 
-- Inputs: Professor NetID, Section Code, Criteria Name, Rview Type, @Variable for error message
-- Outputs: Error Message: 'Success" or condition not met
-- Disclaimer: Cannot delete a criteria that has been used to create the Peer Reviews and Scored Table
CREATE PROCEDURE professor_delete_criteria (
    IN section_code char(5),
    IN criteria_name varchar(35), 
    IN review_type char(7),
    OUT error_message varchar(100))
criteria_deletion:BEGIN 
	SET error_message = 'Success';
    
    IF EXISTS (SELECT * FROM PeerReview WHERE ReviewType = review_type) THEN 
		SET error_message = 'Criteria already being used for this review type, cannot delete';
        LEAVE criteria_deletion;
	END IF;
    
    DELETE FROM Criteria
    WHERE CriteriaName = criteria_name AND SecCode = section_code AND ReviewType = review_type;

END //


-- Written by Emma Hockett, Started October 17, 2024
-- Procedure to allow the professor to change a student's team number 
-- Input: Professor NetID, Section Code, Student NetID, New Team Number, @Variable for error message
-- Output: Error Message: 'Success' or condition not met
CREATE PROCEDURE professor_change_student_team(
    IN section_code char(5),
    IN student_netID char(9),
    IN new_team INT, 
    OUT error_message varchar(100))
change_team:BEGIN
	DECLARE old_team INT;
    SET error_message = 'Success';
    
    -- Checks whether the student is eligible to be moved to a new team
	IF NOT EXISTS (SELECT StuNetID FROM Attends WHERE StuNetID = student_netID AND SecCode = section_code) THEN 
		SET error_message = 'Student not found in this section';
        LEAVE change_team;
	ELSEIF NOT EXISTS (SELECT TeamNum FROM Team WHERE SecCode = section_code AND TeamNum = new_team) THEN 
		SET error_message = 'New team does not exist';
        LEAVE change_team;
	END IF;
    
    UPDATE MemberOf 
    SET TeamNum = new_team
    WHERE SecCode = section_code AND StuNetID = student_netID;

END //

-- Written by Emma Hockett, Started October 23, 2024
-- Procedure to allow the professor to reuse the criteria from a previous review for a new review (Darya)
-- Input: Professor NetID, Section Code, Old Criteria Type, New Criteria Type, @Variable for error message
-- Output: Message: 'Success' or condition that was not met
CREATE PROCEDURE reuse_criteria (
	IN professor_netID char(9),
    IN section_code char(5),
    IN old_criteria_type char(7),
    IN new_criteria_type char(7),
    OUT error_message varchar(100))
keep_criteria_same: BEGIN 
	DECLARE criteria_id INT;
    DECLARE criteria_name varchar(35);
    DECLARE criteria_description varchar(300);
	DECLARE done_criteria INT DEFAULT 0;
	DECLARE criteria_cursor CURSOR FOR 
		SELECT CriteriaID FROM Criteria
        WHERE SecCode = section_code AND ReviewType = old_criteria_type;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_criteria = 1;
    SET error_message = 'Success';
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SET error_message = 'Can only select criteria from your section';
        LEAVE keep_criteria_same;
	ELSEIF NOT EXISTS (SELECT * FROM Criteria WHERE SecCode = section_code AND ReviewType = old_criteria_type) THEN 
		SET error_message = 'No previous criteria to select';
        LEAVE keep_criteria_same;
	ELSEIF old_criteria_type = new_criteria_type THEN 
		SET error_message = 'Cannot have the same review type';
        LEAVE keep_criteria_same;
	END IF;
    
    -- For each of the criteria that was in the old review type, insert it into the table with the new review type 
    OPEN criteria_cursor;
    criteria_loop: LOOP
		FETCH criteria_cursor INTO criteria_id;
		IF done_criteria THEN
			LEAVE criteria_loop;
		END IF;
        
        SET criteria_name = (SELECT CriteriaName FROM Criteria WHERE CriteriaID = criteria_id AND SecCode = section_code AND ReviewType = old_criteria_type);
        SET criteria_description = (SELECT CriteriaDescription FROM Criteria WHERE CriteriaID = criteria_id AND SecCode = section_code AND ReviewType = old_criteria_type);
        
        INSERT INTO Criteria(Seccode, CriteriaName, CriteriaDescription, ReviewType)
        VALUES (section_code, criteria_name, criteria_description, new_criteria_type);
    
	END LOOP criteria_loop;
	CLOSE criteria_cursor;
END //


-- Written by Darya Anbar, Started October 23, 2024
-- Procedure to retrieve all sections that a professor teaches
-- Input: Professor NetID
-- Output: For all sections: Section Code and Section Name
CREATE PROCEDURE professor_get_sections (
    IN prof_netID char(9))
BEGIN
    SELECT Sec.SecCode, Sec.SecName, Sec.StartDate, Sec.EndDate
    FROM Section Sec
    JOIN Teaches T ON T.SecCode = Sec.SecCode
    JOIN Professor P ON P.ProfNetID = T.ProfNetID
    WHERE P.ProfNetID = prof_netID AND CURDATE() BETWEEN Sec.StartDate AND Sec.EndDate;
END //


-- Written by Darya Anbar, Started October 24, 2024
-- Procedure to get all students in a given section
-- Input: Section Code
-- Output: Student Names and NetIDs
CREATE PROCEDURE get_section_students (
	IN section_code char(5))
BEGIN
	SELECT S.StuName, S.StuNetID 
	FROM Student S, Attends A
	WHERE A.SecCode = section_code AND S.StuNetID = A.StuNetID;
END //


-- Written by Emma Hockett, Started October 25, 2024
-- Procedure to get the number of students in a students team
-- Inputs: Student NetID, Section Code, @Variable for num in team, @Variable for error message
-- Outputs: Message: Success or condition not met, Number in Team: 0 if not found, or the number in the team
CREATE PROCEDURE number_students_in_team (
	IN student_netID char(9),
    IN section_code char(5),
    OUT num_in_team INT,
    OUT error_message varchar(100))
num_in_team:BEGIN
	DECLARE team_num INT DEFAULT 0;
    SET error_message = 'Success';
    SET num_in_team = 0;
    
	IF NOT EXISTS (SELECT TeamNum FROM MemberOf WHERE StuNetID = student_netID AND SecCode = section_code) THEN 
		SET error_message = 'Not a member of a team';
        LEAVE num_in_team;
	END IF;
    
    SET team_num = (SELECT TeamNum FROM MemberOf WHERE StuNetID = student_netID AND SecCode = section_code);
    
    SELECT COUNT(*) INTO num_in_team
    FROM MemberOf WHERE SecCode = section_code AND TeamNum = team_num;

END // 

-- Written by Emma Hockett, Started October 25, 2024
-- Updated by Darya Anbar with appropriate logic and error messages, November 22, 2024
-- Procedure to check whether there is a peer review for the section that is currently available
-- Inputs: Student NetID, Section Code
-- Outputs: 'Unavailable' or if available, the review type
CREATE PROCEDURE check_peer_review_availability (
	IN student_netID char(9),
	IN section_code char(5),
    OUT error_message varchar(100))
pr_availability:BEGIN 
    DECLARE review_type char(7);
	SET error_message = 'Unavailable';
    
	IF NOT EXISTS (SELECT * FROM PeerReview PR JOIN Scored S ON PR.ReviewID = S.ReviewID AND PR.SecCode = S.SecCode 
		WHERE PR.ReviewerID = student_netID AND S.SecCode = section_code AND (CURDATE() BETWEEN StartDate AND EndDate) AND S.Score is NULL) THEN 
		SET error_message = 'Completed';
        LEAVE pr_availability;
	END IF;
    
	SELECT ReviewType INTO review_type FROM PeerReview WHERE ReviewerID = student_netID AND SecCode = section_code AND (CURDATE() BETWEEN StartDate AND EndDate) LIMIT 1;
	
    IF review_type IS NOT NULL THEN
		SET error_message = review_type;
        LEAVE pr_availability;
	END IF;
        
END //


-- Written by Emma Hockett, Started October 25, 2024
-- Procedure to add students to a class
-- Inputs: Student NetID, Student UTDID, Student Name, Section code, @Variable to hold message
-- Outputs: Message: 'Success' or condition not met
CREATE PROCEDURE professor_add_students (
	IN student_netID char(9),
    IN student_UTDID char(10),
    IN student_name varchar(30),
    IN section_code char(5),
    OUT error_message varchar(100))
add_student: BEGIN
	SET error_message = 'Success';
    
    -- Checks that the student values being added are in the correct format for the database.
    IF student_netID NOT REGEXP '^[a-zA-Z]{3}[0-9]{6}$' THEN 
		SET error_message = 'Student NetID not in correct format';
        LEAVE add_student;
	ELSEIF student_UTDID NOT REGEXP '^[0-9]{10}$' THEN 
		SET error_message = 'Student UTDID not in correct format';
        LEAVE add_student;
	ELSEIF NOT EXISTS (SELECT * FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'Section does not exist';
        LEAVE add_student;
	ELSEIF student_UTDID IN (SELECT StuUTDID FROM Student) THEN 
		SET error_message = 'UTDID already in use';
        LEAVE add_student;
	ELSEIF student_netid IN (SELECT StuNetID FROM Student) THEN 
		SET error_message = 'NetID already in use';
        LEAVE add_student;
	END IF;
    
    INSERT INTO Student (StuNetID, StuUTDID, StuName, StuPassword)
    VALUES (student_netID, student_UTDID, student_name, student_UTDID);
    
    INSERT INTO Attends (StuNetID, SecCode) 
    VALUES (student_netID, section_code);

END //


-- Written by Emma Hockett Started on November 19, 2024
-- Procedure to allow the professor to edit student information 
-- Inputs: Original netid, updated netid, updated utdid, updated name, @Variable for the error message
-- Outputs: Success or condition not met
CREATE PROCEDURE professor_edit_student (
	IN original_student_netid varchar(9),
    IN updated_netid varchar(9),
    IN updated_name varchar(30),
    IN updated_utdid varchar(10),
    OUT error_message varchar(200))
edit_student: BEGIN 
	SET error_message = 'Success';
    
    -- Checks that the student values being added are in the correct format for the database.
    IF updated_netID NOT REGEXP '^[a-zA-Z]{3}[0-9]{6}$' THEN 
		SET error_message = 'Student NetID not in correct format';
        LEAVE edit_student;
	ELSEIF updated_utdid NOT REGEXP '^[0-9]{10}$' THEN 
		SET error_message = 'Student UTDID not in correct format';
        LEAVE edit_student;
	ELSEIF updated_netid != original_student_netid AND EXISTS (SELECT * FROM Student WHERE StuNetID = updated_netid) THEN 
		SET error_message = 'NetID already in use';
        LEAVE edit_student;
	ELSEIF updated_utdid != (SELECT StuUTDID FROM Student WHERE original_student_netid = StuNetID) AND EXISTS (SELECT * FROM Student WHERE StuUTDID = updated_utdid) THEN 
		SET error_message = 'UTDID already in use';
        LEAVE edit_student;
	END IF;
    
    UPDATE Student
    SET StuNetID = updated_netid, StuName = updated_name, StuUTDID = updated_utdid
    WHERE StuNetID = original_student_netid;


END //


-- Written by Emma Hockett, Statred November 19, 2024
-- Procedure to allow the professor to delete a student 
-- Inputs: student NetID, @Variable to hold the error message
-- Outputs: Success or not
CREATE PROCEDURE professor_delete_student (
	IN student_netid char(9),
    OUT error_message varchar(200))
delete_student:BEGIN
	SET error_message = "Not Successful";
    
    SET SQL_SAFE_UPDATES = 0;
    
    DELETE FROM Scored 
    WHERE ReviewID IN (SELECT ReviewID FROM PeerReview WHERE ReviewerID = student_netid);
    
    DELETE FROM Reviewed WHERE StuNetID = student_netid;
    DELETE FROM PeerReview WHERE ReviewerID = student_netid AND ReviewID IS NOT NULL ;
    DELETE FROM Timeslot WHERE StuNetID = student_netid;
    DELETE FROM MemberOf WHERE StuNetID = student_netid;
    DELETE FROM Attends WHERE StuNetID = student_netid;
    DELETE FROM Student WHERE StuNetID = student_netid;
    
    SET SQL_SAFE_UPDATES = 1;
    SET error_message = "Success";

END //


-- Written by Emma Hockett, Started October 25, 2024
-- Procedure to add a student to a team
-- Inputs: Team Number, Student NetID, Section Code, @Variable for the error message
-- Outputs: Message: 'Success' or condition not met
CREATE PROCEDURE add_student_to_team (
	IN team_num INT,
    IN student_netID char(9),
    IN section_code char(5),
    OUT error_message varchar(100))
add_to_team:BEGIN 
	SET error_message = 'Success';
    
    -- Checks whether the student is eligible to be added to the team
    IF NOT EXISTS ( SELECT * FROM Team WHERE TeamNum = team_num AND SecCode = section_code) THEN 
		SET error_message = 'Team number does not exist for this section';
        LEAVE add_to_team;
	ELSEIF NOT EXISTS (SELECT * FROM Attends WHERE StuNetID = student_netID AND SecCode = section_code) THEN 
		SET error_message = 'Student does not attend this class';
        LEAVE add_to_team;
	ELSEIF EXISTS (SELECT * FROM MemberOf WHERE StuNetID = student_netID AND SecCode = section_code) THEN 
		SET error_message = 'Student already a member of a team';
        LEAVE add_to_team;
	END IF;
    
    INSERT INTO MemberOf (TeamNum, StuNetID, SecCode) 
    VALUES (team_num, student_netID, section_code);

END //

-- Written by Emma Hockett, Started on November 20, 2024
-- Procedure to remove a student from a team
-- Inputs: Student NetID, @Variable for error message
-- Outputs: Success or what condition was not met
CREATE PROCEDURE professor_remove_student_team (
	IN student_netID char(9),
    OUT error_message varchar(200))
remove_student_team:BEGIN
	SET error_message = "Not Success";
    
    IF EXISTS (SELECT * FROM PeerReview WHERE ReviewerID = student_netid) THEN 
		SET error_message = "Cannot remove a student from a team once a Peer Review has been created";
		LEAVE remove_student_team;
	END IF;
    
    DELETE FROM MemberOf
    WHERE StuNetID = student_netid;

	SET error_message = "Success";

END //


-- Written by Emma Hockett, Started on November 20, 2024
-- Procedure to check whether a peer review has already been created with the team in question 
-- Inputs: Team Number, Section, @Variable to hold response 
-- Outputs: Whether a peer review exists or not
CREATE PROCEDURE check_peer_review_exists (
	IN team_num int,
    IN section_code char(5),
    OUT error_message varchar(200))
cpre: BEGIN
	
    IF (SELECT StuNetID FROM MemberOf WHERE SecCode = section_code) IN (SELECT ReviewerID FROM PeerReview WHERE SecCode = section_code) THEN 
		SET error_message = "Peer Reviews have already been created";
        LEAVE cpre;
	END IF;
    
    SET error_message = "No peer reviews exist";

END //


-- Written by Emma Hockett, Started October 25, 2024
-- Procedure for a professor to add their section 
-- Input: Professor NetID, Section Code, Section Name, @Variable to hold message
-- Output: Message: 'Success' or condition not met
CREATE PROCEDURE professor_add_section (
	IN professor_netID char(9),
    IN section_code char(5),
    IN section_name varchar(12),
    IN start_date DATE,
    IN end_date DATE,
    OUT error_message varchar(100))
add_section: BEGIN 
	SET error_message = 'Success';
    
    
    -- Checks whether the values trying to be added are consistent with what is expected
    IF EXISTS (SELECT * FROM Section WHERE SecCode = section_code) THEN 
		SET error_message = 'Section Code already in use';
        LEAVE add_section;
	ELSEIF EXISTS (SELECT * FROM Section WHERE SecName = section_name) THEN 
		SET error_message = 'Section name already in use';
        LEAVE add_section;
	ELSEIF NOT EXISTS (SELECT * FROM Professor WHERE ProfNetID = professor_netID) THEN 
		SET error_message = 'Professor NetID does not exist in the system';
        LEAVE add_section;
	ELSEIF end_date <= start_date THEN 
		SET error_message = 'Start date must be before end date';
        LEAVE add_section;
	END IF;
    
    INSERT INTO Section (SecCode, SecName, StartDate, EndDate) 
    VALUES (section_code, section_name, start_date, end_date);
    
    INSERT INTO Teaches (ProfNetID, SecCode)
    VALUES (professor_netID, section_code);

END // 


-- Procedure to check get the start and end dates for the section (Darya)
-- Inputs: Section Code
-- Outputs: Start Date, End Date 
CREATE PROCEDURE get_section_timeframe (
	IN section_code char(5))
BEGIN
	SELECT StartDate, EndDate FROM Section WHERE SecCode = section_code;

END //


-- Written by Emma Hockett and Darya Anbar, Started October 29, 2024
-- Procedure to check what needs to be shown on the student peer review page 
-- Intputs: Student NetID, Section Code
-- Outputs: 
-- The student has not completed the peer review:  'Peer Review needs to be completed'
-- The peer review window is still open: 'Peer Reviews completed, waiting until the end of the review session to view average scores'
-- Show the average scores: 'Average scores for the last review type: (review type)'
CREATE PROCEDURE student_peer_review_page ( 
    IN student_netID char(9),
    IN section_code char(5),
    OUT error_message varchar(150))
pr_page: BEGIN 
    DECLARE pr_done BOOLEAN DEFAULT FALSE;
    DECLARE in_waiting BOOLEAN DEFAULT FALSE;
    DECLARE show_average BOOLEAN DEFAULT FALSE;
    DECLARE review_type CHAR(7);

    SET error_message = '';

	-- Checks whether the student has completed the current peer review 
    IF EXISTS (SELECT 1 FROM PeerReview pr JOIN Scored s ON pr.ReviewID = s.ReviewID AND pr.SecCode = s.SecCode
        WHERE pr.ReviewerID = student_netID AND s.Score IS NULL AND pr.SecCode = section_code AND CURDATE() BETWEEN pr.StartDate AND pr.EndDate) THEN
        
        SET pr_done = TRUE;
    END IF;

	-- Checks wether the student has completed the peer review, but has to wait until the end of the review window to see scores
    IF NOT pr_done AND EXISTS (SELECT 1 FROM PeerReview pr WHERE pr.ReviewerID = student_netID 
		AND pr.SecCode = section_code AND CURDATE() BETWEEN pr.StartDate AND pr.EndDate 
		AND NOT EXISTS (SELECT 1 FROM Scored s WHERE s.ReviewID = pr.ReviewID AND s.SecCode = pr.SecCode AND s.Score IS NULL)) THEN
        
        SET in_waiting = TRUE;
    END IF;

	-- Checks whether it is between peer review windows, so the student can see their average scores for the previous peer review
    IF NOT pr_done AND NOT in_waiting AND EXISTS (SELECT 1 FROM PeerReview pr_latest WHERE pr_latest.SecCode = section_code
          AND pr_latest.EndDate = (SELECT MAX(EndDate) FROM PeerReview WHERE SecCode = section_code AND EndDate <= CURDATE())
          AND NOT EXISTS (SELECT 1 FROM PeerReview pr_next WHERE pr_next.SecCode = section_code AND pr_next.StartDate > CURDATE() AND pr_next.StartDate = (
		SELECT MIN(StartDate) FROM PeerReview WHERE SecCode = section_code AND StartDate > pr_latest.EndDate))) THEN
        
        SET show_average = TRUE;

        SELECT ReviewType INTO review_type FROM PeerReview WHERE SecCode = section_code 
          AND EndDate = (SELECT MAX(EndDate) FROM PeerReview WHERE SecCode = section_code AND EndDate <= CURDATE()) LIMIT 1;
    END IF;


    IF pr_done THEN
        SET error_message = CONCAT('Peer Review needs to be completed of type: ', review_type);
    ELSEIF in_waiting THEN 
        SET error_message = 'Peer Reviews completed, waiting until the end of the review session to view average scores. To make edits to score, email professor';
    ELSEIF show_average THEN 
        SET error_message = CONCAT('Average scores for the last review type: ', review_type);
    ELSE
        SET error_message = 'No active or upcoming peer reviews found';
    END IF;

END //


-- Written by Darya Anbar, Started October 30, 2024
-- Procedure to return the students who didn't complete the peer review in time
-- Inputs: Section Code, Review Type
-- Outputs: Student NetIDs of students who didn't/haven't completed the review
CREATE PROCEDURE professor_get_incomplete_reviews (
    IN section_code char(5),
    IN review_type char(7))
BEGIN
    SELECT Pr.ReviewerID AS StuNetID
    FROM PeerReview Pr
    JOIN Scored Sc ON Sc.ReviewID = Pr.ReviewID
    WHERE Pr.SecCode = section_code AND Pr.ReviewType = review_type AND Sc.Score IS NULL;
END //


-- Written by Darya Anbar, Started October 30, 2024
-- Procedure for a professor to edit a student's timeslot 
-- Inputs: Student NetID, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Duration, and a variable to hold the error message
-- Outputs: Error Message: 'Success' or a description of which condition it violated
CREATE PROCEDURE professor_edit_timeslot (
    IN student_netID char(9),
    IN ts_date DATE,
    IN updated_description varchar(200),
    IN updated_duration char(5),
    OUT error_message varchar(100))
edit_timeslot:BEGIN
    SET error_message = 'Success';
    
    -- Checking constraints: Description and Duration constraints must be consistent with what is expected
   IF (LENGTH(updated_description) < 30) THEN
        SET error_message = 'Description must be at least 30 characters';
        LEAVE edit_timeslot;
    ELSEIF (updated_duration NOT REGEXP '^(2[0-3]|[01][0-9]):([0-5][0-9])$') THEN 
        SET error_message = 'Durations must be in the form HH:MM and cannot 24 or more hours or more than 60 minutes.';
        LEAVE edit_timeslot;
    ELSEIF (TIME_TO_SEC(STR_TO_DATE(ts_duration, '%H:%i')) < TIME_TO_SEC('00:15')) THEN
        SET error_message = 'Duration must be at least 15 minutes';
        LEAVE edit_timeslot;
    ELSEIF (MINUTE(STR_TO_DATE(ts_duration, '%H:%i')) NOT IN (0, 15, 30, 45)) THEN
        SET error_message = 'Duration must be rounded to the nearest 15 minutes';
        LEAVE edit_timeslot;
    END IF;
    
    UPDATE Timeslot
    SET TSDuration = updated_duration, TSDescription = updated_description
    WHERE StuNetID = student_netID AND TSDate = ts_date;

END //


-- Written by Emma Hockett Started on November 19, 2024
-- Procedure to allow the professor to update information about the sections
-- Inputs: Original Section Code, Updated name, updated code, updated start date, updated end date, @Variable for error message
-- Outputs: Either success or the condition not met
CREATE PROCEDURE professor_edit_section (
	IN original_section_code varchar(5),
    IN updated_name varchar(12),
    IN updated_code varchar(5),
    IN updated_start_date DATE,
    IN updated_end_date DATE,
    OUT error_message varchar(200))
edit_section: BEGIN
	SET error_message = "Success";
    
    IF NOT EXISTS (SELECT *  FROM Section WHERE SecCode = original_section_code) THEN 
		SET error_message = "Original Section code does not exist";
        LEAVE edit_section;
	ELSEIF original_section_code != updated_code AND EXISTS (SELECT * FROM Section WHERE SecCode = updated_code) THEN 
		SET error_message = 'Section Code already in use';
        LEAVE edit_section;
	ELSEIF ((SELECT SecName FROM Section WHERE SecCode = original_section_code) != updated_name) AND EXISTS (SELECT * FROM Section WHERE SecName = updated_name) THEN 
		SET error_message = 'Section name already in use';
        LEAVE edit_section;
	ELSEIF updated_end_date <= updated_start_date THEN 
		SET error_message = 'Start date must be before end date';
        LEAVE edit_section;
	END IF;
    
	UPDATE Section
	SET SecCode = updated_code, SecName = updated_name, StartDate = updated_start_date, EndDate = updated_end_date
	WHERE SecCode = original_section_code;
    

END //

-- Written by Emma Hockett, Started on November 19, 2024
-- Procedure to allow the professor to delete a section 
-- Inputs: Section Code, @Variable for error message
-- Outputs: Whether it was successful or not
CREATE PROCEDURE professor_delete_section (
	IN section_code varchar(5),
    OUT error_message varchar(200))
BEGIN
    SET error_message = "Not successful";
    
    DELETE FROM Scored WHERE SecCode = section_code;
    DELETE FROM Criteria WHERE SecCode = section_code;
    DELETE FROM Reviewed WHERE SecCode = section_code;
    DELETE FROM PeerReview WHERE SecCode = section_code;
    DELETE FROM MemberOf WHERE SecCode = section_code;
    DELETE FROM Team WHERE SecCode = section_code;
    DELETE FROM Attends WHERE SecCode = section_code;
    DELETE FROM Teaches WHERE SecCode = section_code;
    DELETE FROM Section WHERE SecCode = section_code;
    DELETE FROM Student WHERE StuNetID NOT IN (SELECT StuNetID FROM Attends);
    
    SET error_message = "Success";

END //


-- Written by Emma Hockett, Started November 3, 2024
-- Procedure to return the emails of all of the student who have not inputted any time for the week
-- Inputs: Section Code, Date of the start of the week, @Variable for error message
-- Outputs: Emails for all of the students who have not put timeslots in for the current week
CREATE PROCEDURE timetrack_student_emails (
	IN section_code char(5),
    IN start_week DATE)
tt_emails:BEGIN
    -- Creates the emails of the students who have not entered any time from the given date to the current date
	SELECT CONCAT(s.StuNetID, '@utdallas.edu') AS Email
    FROM Student s
    JOIN Attends a ON s.StuNetID = a.StuNetID
    WHERE a.SecCode = section_code
      AND s.StuNetID NOT IN (
          SELECT t.StuNetID
          FROM Timeslot t
          WHERE t.TSDate BETWEEN start_week AND CURDATE());
          
END //


-- Written by Emma Hockett, Started November 3, 2024
-- Procedure to return all of the emails of the students who have not completed the current peer reviews
-- Inputs: Section Code
-- Outputs: Emails of those who have not completed them 
CREATE PROCEDURE peerReview_student_emails (
	IN section_code char(5))
pr_emails: BEGIN
	DECLARE review_type char(7);
    
    SELECT ReviewType INTO review_type FROM PeerReview WHERE SecCode = section_code AND CURDATE() BETWEEN StartDate AND EndDate LIMIT 1;
    
    -- Creates the emails of the students who have not completed the current peer review
	SELECT DISTINCT CONCAT(Pr.ReviewerID, '@utdallas.edu') AS Email
    FROM PeerReview Pr
    JOIN Scored Sc ON Sc.ReviewID = Pr.ReviewID
    WHERE Pr.SecCode = section_code AND Pr.ReviewType = review_type AND Sc.Score IS NULL;

END //


-- Written by Darya Anbar, Started November 26, 2024
-- Procedure to check if peer review scores are avaiable for a section
-- Inputs: Student NetID, Section Code
-- Outputs: 'Unavailable' or if available, the review type of the most recent peer review
CREATE PROCEDURE check_scores_availability (
    IN student_netID CHAR(9),
    IN section_code CHAR(5),
    OUT error_message VARCHAR(100))
scores_availability:BEGIN
	DECLARE section_start_date DATE;
    DECLARE section_end_date DATE;
    DECLARE current_review_start DATE;
    DECLARE current_review_end DATE;
    DECLARE review_type char(7);

    SET error_message = 'Unavailable';

    -- Gets section start and end date
    SELECT StartDate, EndDate INTO section_start_date, section_end_date FROM Section WHERE SecCode = section_code;

    IF CURDATE() > section_end_date or CURDATE() < section_start_date THEN
        LEAVE scores_availability;
    END IF;
    
    -- Checks if there's a current review window
	IF EXISTS (SELECT * FROM PeerReview WHERE ReviewerID = student_netID AND SecCode = section_code AND (CURDATE() BETWEEN StartDate AND EndDate) LIMIT 1) THEN
        LEAVE scores_availability;
	END IF;
    
    -- No reviews yet
    IF NOT EXISTS (SELECT * FROM PeerReview WHERE SecCode = section_code AND CURDATE() > EndDate) THEN
		LEAVE scores_availability;
	END IF;
    
    -- Gets most recent review type
    SELECT ReviewType INTO review_type FROM PeerReview WHERE SecCode = section_code AND CURDATE() > EndDate ORDER BY EndDate DESC LIMIT 1;
	IF review_type IS NOT NULL THEN
		SET error_message = review_type;
        LEAVE scores_availability;
    END IF;

END //


DELIMITER ;
