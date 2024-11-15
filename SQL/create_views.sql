/*
	Written by Darya Anbar for CS 4485.0W1, Senior Design Project, Started October 17, 2024.
         NetID: dxa200020
         
	Statements to create the various views for the database. Most of the views are being used for the Stored Procedures.
    Must be run after create.sql and before stored_procedures.sql
*/

USE seniordesignproject;

-- View for all timeslots for all students in the system
-- Used in these procedures: student_timeslot_by_date, student_timeslot_by_week, student_timeslot_by_month
CREATE VIEW student_timeslots AS
SELECT S.StuNetID, S.StuName, T.TSDate, T.TSDescription, T.TSDuration
FROM Student S
JOIN Timeslot T ON T.StuNetID = S.StuNetID;


-- View for all criteria categories for all students in the system
-- Used in these procedures: student_get_peer_review_criteria
CREATE VIEW student_peer_review_criteria AS
SELECT S.StuNetID, C.CriteriaName, C.CriteriaDescription, Sc.SecCode, C.ReviewType
FROM Student S
JOIN MemberOf M ON M.StuNetID = S.StuNetID
JOIN Section Sc ON Sc.SecCode = M.SecCode
JOIN Criteria C ON C.SecCode = Sc.SecCode;


-- View for team number and section code for all students
-- Used in these procedures: student_get_team_members
CREATE VIEW student_team_and_section AS
SELECT M.TeamNum, M.SecCode, S.StuNetID, S.StuName
FROM MemberOf M
JOIN Student S ON M.StuNetID = S.StuNetID;


-- View for all scores that all students received in all professors' sections (for all criteria)
-- Used in these procedures: professor_view_averages
CREATE VIEW professor_student_scores AS
SELECT P.ProfNetID, Sec.SecCode, M.TeamNum, S.StuNetID AS RevieweeNetID, 
PR.ReviewerID AS ReviewerNetID, PR.ReviewType, C.CriteriaName, Sc.score

FROM Professor P 
JOIN Teaches T ON T.ProfNetID = P.ProfNetID
JOIN Section Sec ON Sec.SecCode = T.SecCode
JOIN Attends A ON A.SecCode = Sec.SecCode
JOIN Student S ON S.StuNetID = A.StuNetID
JOIN Reviewed R ON R.StuNetID = S.StuNetID
JOIN PeerReview PR ON PR.ReviewID = R.ReviewID
JOIN Scored Sc ON Sc.ReviewID = PR.ReviewID
JOIN Criteria C ON C.CriteriaID = Sc.CriteriaID
JOIN MemberOf M ON M.StuNetID = S.StuNetID;

