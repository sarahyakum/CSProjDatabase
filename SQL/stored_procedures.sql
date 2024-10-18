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



-- Procedure for inserting timeslots into the table, descipriotn >= 30 characters, Within past 3 days and not in future
-- Inputs: Student Net ID, Timeslot date, description, and duration
-- Output: 0 if the timeslot was inserted correctly, 1 if it was not
CREATE PROCEDURE student_insert_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    IN ts_description varchar(200),
    IN ts_duration varchar(5))
BEGIN
	DECLARE insert_status INT DEFAULT 0;
    IF (LENGTH(ts_description) < 30) OR (ts_date <= NOW() - INTERVAL 3 DAY) OR (ts_date > NOW()) THEN 
		SET insert_status = 1;
    ELSE
		INSERT INTO Timeslot (StuNetID, TSDate, TSDescription, TSDuration)
		VALUES (student_netID, ts_date, ts_description, ts_duration);
        SET insert_status = 0;
	END IF;
    SELECT insert_status;
END //



-- Procedure to allow students to edit their timeslot, have to be within past 3 days and the description has to be longer than 30 characters
-- Inputs: Student NetId, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Deuration
-- Outputs: 0 if was altered correctly, 1 if it was not
CREATE PROCEDURE student_edit_timeslot (
	IN student_netID char(9),
    IN ts_date DATE,
    IN updated_description varchar(200),
    IN updated_duration char(5))
BEGIN 
	DECLARE edit_status INT DEFAULT 1;
    
    IF NOT EXISTS (SELECT TimeslotID FROM Timeslot WHERE TSDate = ts_date AND StuNetID = student_netID) 
    OR (ts_date <= NOW() - INTERVAL 3 DAY)
    OR ( ts_date > NOW()) 
    OR (LENGTH(updated_description) < 30) THEN 
		SELECT edit_status;
	END IF;
    
    
    UPDATE Timeslot
    SET TSDuration = updated_duration, TSDescription = updated_description
    WHERE StuNetID = student_netID AND TSDate = ts_date;
    
    SELECT 0 AS edit_status;

END //



-- Procedure to allow students to delete timeslots that are within the three previous days
-- Inputs: Student NetID, Timeslot Date
-- Outputs: 0 if deleted correctly, 1 otherwise
CREATE PROCEDURE student_delete_timeslot (
	IN student_netID char(9),
    IN ts_date DATE)
BEGIN 
	DECLARE deletion_status INT DEFAULT 1;
    
    IF ts_date >= NOW() - INTERVAL 3 DAY THEN 
		SELECT deletion_status;
	END IF;
    
    DELETE FROM Timeslot 
    WHERE TSDate = ts_date AND StuNetID = student_netID;
    
    SELECT 0 AS deletion_status;

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
CREATE PROCEDURE student_timeslot_by_month(
    IN stu_netID char(9),
    IN start_date DATE)
BEGIN
    SELECT * 
    FROM student_daily_timeslots
    WHERE StuNetID = stu_netID AND TSDate >= start_date AND TSDate < DATE_ADD(start_date, INTERVAL 30 DAY); 
END //


-- Procedure to insert a student score for another student
-- Input: Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, New Score
-- Output: 0 if it was inserted correctly, 1 if it was not
CREATE PROCEDURE student_insert_score (
	IN section_code char(5),
	IN reviewer_netID char(9),
    IN reviewee_netID char(9),
    IN criteria_name varchar(35),
    IN updated_score INT)
inserting_score: BEGIN
	DECLARE insertion_status INT DEFAULT 1;
	DECLARE review_id INT DEFAULT 0;
    DECLARE criteria_id INT DEFAULT 0;
    
	SET criteria_id = (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND CriteriaName = criteria_name);
    
    SET review_id = (SELECT pr.ReviewID FROM PeerReview pr JOIN Reviewed r
		ON pr.ReviewID = r.ReviewID AND pr.SecCode = r.SecCode
		WHERE pr.SecCode = section_code AND pr.ReviewerID = reviewer_netID AND r.StuNetID = reviewee_netID ); 
    
    IF (criteria_id IS NULL) OR (review_ID IS NULL) OR (updated_score > 5) OR (updated_score < 0) THEN 
		SELECT insertion_status;
        LEAVE inserting_score;
	END IF;
    
    UPDATE Scored
    SET Score = updated_score
    WHERE SecCode = section_code AND ReviewID = review_id AND CriteriaID = criteria_id;
    
    SELECT 0 AS insertion_status;

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
-- Input: Professor Net ID, Section Code, Review Type
-- Output: Pulls the student averages for each criteria
CREATE PROCEDURE professor_view_averages (
	IN professor_netID char(9),
    IN section_code char(5),
    IN review_type char(7))
BEGIN
	SELECT Stu.StuNetID, Stu.StuName, C.CriteriaName, AVG(Sc.Score) AS AverageScore
    FROM Scored Sc
    JOIN PeerReview PR ON Sc.ReviewID = PR.ReviewID AND Sc.SecCode = PR.SecCode
    JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID AND Sc.SecCode = C.SecCode
    JOIN Student Stu ON PR.ReviewerID = Stu.StuNetID
    JOIN Attends A ON A.StuNetID = PR.ReviewerID AND A.SecCode = PR.SecCode
    JOIN Teaches T ON T.SecCode = A.SecCode AND T.ProfNetID = professor_netID
    WHERE PR.SecCode = section_code AND PR.ReviewType = review_type
    GROUP BY Stu.StuNetID, Stu.StuName, C.CriteriaName
    ORDER BY Stu.StuNetID, C.CriteriaName;
END //


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
    JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID AND Sc.Seccode = C.SecCode
    JOIN Reviewed R ON Sc.ReviewID = R.ReviewID AND Sc.SecCode = R.SecCode
    JOIN Student Stu ON R.StuNetID = Stu.StuNetID
    JOIN Student Reviewer ON PR.ReviewerID = Reviewer.StuNetID
    JOIN Attends A ON A.StuNetID = PR.ReviewerID AND A.SecCode = PR.SecCode
    JOIN Teaches T ON T.SecCode = A.SecCode AND T.ProfNetID = professor_netID
    WHERE PR.SecCode = section_code AND R.StuNetID = student_netID AND PR.ReviewType = review_type;
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



-- Procedure to retrieve the peer review criteria for a given professor's given section
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


-- Procedure for a professor to retrieve the scores that a specific student in a specific section received from all team members (for all criteria)
-- Input: Professor NetID, Section Code, Reviewee NetID, Review Type ("Midterm" or "Final")
-- Output: Professor NetID, Section Code, Team Number, Reviewee NetID, Reviewer NetID, Review Type, Criteria Name, Score
CREATE PROCEDURE get_student_scores_received(
    IN prof_netID char(9),
    IN section_code char(5),
    IN stu_netID char(9),
    IN review_type char(7))
BEGIN
    SELECT *
    FROM professor_student_scores
    WHERE ProfNetID = prof_netID AND SecCode = section_Code AND RevieweeNetID = stu_netID AND ReviewType = review_type;
END //


-- Procedure for a professor to retrieve the scores that a specific student in a specific section gave to all team members (for all criteria)
-- Input: Professor NetID, Section Code, Reviewer NetID, Review Type ("Midterm" or "Final")
-- Output: Professor NetID, Section Code, Team Number, Reviewee NetID, Reviewer NetID, Review Type, Criteria Name, Score
CREATE PROCEDURE get_student_scores_given(
    IN prof_netID char(9),
    IN section_code char(5),
    IN stu_netID char(9),
    IN review_type char(7))
BEGIN
    SELECT *
    FROM professor_student_scores
    WHERE ProfNetID = prof_netID AND SecCode = section_Code AND ReviewerNetID = stu_netID AND ReviewType = review_type;
END //


-- Procedure to edit the scores that a student gave to a different student
-- Professor NetID, Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, New Score
-- Outputs: 0 if altered corretly, 1 if was not
CREATE PROCEDURE edit_scores_given (
	IN professor_netID char(9),
    IN section_code char(5),
    IN reviewer_netID char(9),
    IN reviewee_netID char(9),
    IN criteria_name varchar(35),
    IN new_score INT)
BEGIN 
	DECLARE edit_status INT DEFAULT 1;
    DECLARE criteria_id INT;
    DECLARE review_id INT;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SELECT edit_status;
	END IF;
    
    SET criteria_id = (SELECT CriteriaID FROM Criteria WHERE SecCode = section_code AND CriteriaName = criteria_name);
    SET review_id = (SELECT pr.ReviewID FROM PeerReview pr JOIN Reviewed r
		ON pr.ReviewID = r.ReviewID AND pr.SecCode = r.SecCode
		WHERE pr.SecCode = section_code AND pr.ReviewerID = reviewer_netID AND r.StuNetID = reviewee_netID ); 
    
    UPDATE Scored
    SET Score = new_score
    WHERE CriteriaID = criteria_id AND SecCode = section_code AND ReviewID = review_id;
    
    SELECT 0 AS edit_status;
    

END //



-- Procedure to insert the correct number of teams for a section 
-- Inputs: Professor NetID, Section Code, Number of Teams for section
-- Outputs: 0 if the teams were inserted correctly, 1 if they were not
CREATE PROCEDURE professor_insert_num_teams (
	IN professor_netID char(9),
	IN section_code char(5),
    IN num_teams INT)
BEGIN 
	DECLARE insertion_status INT DEFAULT 1;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN 
		SELECT insertion_status;
	END IF;
        
	insertion_loop: LOOP
		IF num_teams > 0 THEN 
			INSERT INTO Team (SecCode)
            VALUES (section_code);
            SET num_teams = num_teams - 1;
		ELSE 
			LEAVE insertion_loop;
		END IF;
    END LOOP insertion_loop;
	SET insertion_status = 0;
    SELECT insertion_status;
END //



-- Procedure to Delete a team from the database, will remove all of the students from the team first 
-- Inputs: Professor NetID, Section Code, Team Num
-- Outputs: 0 if the deletion was successful, 1 if it was not
CREATE PROCEDURE professor_delete_team (
	IN professor_netID char(9),
    IN section_code char(5),
    IN team_num INT)
BEGIN 
	DECLARE deletion_status INT DEFAULT 1;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN 
		SELECT insertion_status;
	END IF;
    
    DELETE FROM MemberOf
    WHERE TeamNum = team_num AND SecCode = section_code;
    
    DELETE FROM Team
    WHERE TeamNum = team_num AND SecCode = section_code;
    
    SELECT 0 AS deletion_status;
	
END //



-- Procedure to get the CriteriaID and info for a section before it it edited
-- Input: Professor NetID, Section Code
-- Output: CriteriaId, Criteria Name, Criteria Description
CREATE PROCEDURE get_section_criteriaid(
    IN professor_netID char(9),
    IN section_code char(5))
BEGIN
	DECLARE retrieval_status INT DEFAULT 1;
    
    IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SELECT retrieval_status;
	END IF;
    
    SELECT CriteriaID, CriteriaName, CriteriaDescription
    FROM Criteria
    WHERE SecCode = section_code;
    
END //


-- Procedure to edit the criteria
-- Input: Professor NetID, Section Code, CriteriaID, Updated Criteria Name, updated Criteria Description
-- Output: 0 if it was edited correctly, 1 if it was not
CREATE PROCEDURE professor_edit_criteria (
	IN professor_netID char(9),
	IN section_code char(5), 
    IN criteria_id INT, 
    IN criteria_name varchar(35),
    IN criteria_description varchar(300))
BEGIN
	DECLARE alter_status INT DEFAULT 1;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SELECT retrieval_status;
	END IF;
    
    
    UPDATE Criteria
    SET CriteriaName = criteria_name, CriteriaDescription = criteria_description
    WHERE CriteriaID = criteria_id;
    
    SELECT 0 AS alter_status;

END //

-- Procedure to allow a professor to delete a criteria 
-- Inputs: Professor NetID, Section Code, Criteria Name
-- Outputs: 0 if it was deleted correctly, 1 if it was not
-- Disclaimer: Cannot delete a criteria that has been used to create the Peer Reviews and Scored Table
CREATE PROCEDURE professor_delete_criteria (
	IN professor_netID char(9),
    IN section_code char(5),
    IN criteria_name varchar(35))
criteria_deletion:BEGIN 
	DECLARE deletion_status INT DEFAULT 1;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SELECT change_status;
	END IF;
    
    IF EXISTS (SELECT * FROM Scored WHERE CriteriaName = criteria_name AND SecCode = section_code) THEN 
		SELECT change_status;
        LEAVE criteria_deletion;
	END IF;
    
    DELETE FROM Criteria
    WHERE CriteriaName = criteria_name AND SecCode = section_code;
    
    SELECT 0 AS deletion_status;


END //


-- Procedure to allow the professor to change a student's team number
-- Input: Professor NetID, Section Code, Student NetID, New Team Number
-- Output: 0 if the team was changed correctly, 1 if it was not
CREATE PROCEDURE professor_change_student_team(
	IN professor_netID char(9),
    IN section_code char(5),
    IN student_netID char(9),
    IN new_team INT)
BEGIN
	DECLARE change_status INT DEFAULT 1;
	DECLARE old_team INT;
    
	IF (SELECT COUNT(*) FROM Teaches WHERE ProfNetID = professor_netID AND SecCode = section_code ) < 1 THEN
		SELECT change_status;
	END IF;
    
    UPDATE MemberOf 
    SET TeamNum = new_team
    WHERE SecCode = section_code AND StuNetID = student_netID;

	SELECT 0 AS change_status;

END //


DELIMITER ;
