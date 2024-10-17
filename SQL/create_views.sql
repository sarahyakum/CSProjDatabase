USE seniordesignproject;

-- View for all timeslots for all students in the system
CREATE VIEW student_timeslots AS
SELECT S.StuNetID, S.StuName, T.TSDate, T.TSDescription, T.TSDuration
FROM Student S
JOIN Timeslot T ON T.StuNetID = S.StuNetID;


-- View for all criteria categories for all students in the system
CREATE VIEW student_peer_review_criteria AS
SELECT S.StuNetID, C.CriteriaName, C.CriteriaDescription, Sc.SecCode
FROM Student S
JOIN MemberOf M ON M.StuNetID = S.StuNetID
JOIN Section Sc ON Sc.SecCode = M.SecCode
JOIN Criteria C ON C.SecCode = Sc.SecCode;


-- View for team number and section code for all students
CREATE VIEW student_team_and_section AS
SELECT M.TeamNum, M.SecCode, S.StuNetID, S.StuName
FROM MemberOf M
JOIN Student S ON M.StuNetID = S.StuNetID;


-- View for all sections of all professors
CREATE VIEW professor_sections AS
SELECT P.ProfName, P.ProfNetID, Sec.SecName, Sec.SecCode
FROM Professor P
JOIN Teaches T ON P.ProfNetID = T.ProfNetID
JOIN Section Sec ON T.SecCode = Sec.SecCode;


-- View for all students in all teams of all sections of all professors
CREATE VIEW professor_students AS
SELECT P.ProfName, P.ProfNetID, Sc.SecName, Sc.SecCode, T.TeamNum, S.StuNetID, S.StuName
FROM Professor P
JOIN Teaches Te ON P.ProfNetID = Te.ProfNetID
JOIN Section Sc ON Te.SecCode = Sc.SecCode
JOIN Team T ON Sc.SecCode = T.SecCode
JOIN MemberOf M ON T.TeamNum = M.TeamNum
JOIN Student S ON M.StuNetID = S.StuNetID;


-- View for all criteria categories for all sections of all professors
CREATE VIEW professor_peer_review_criteria AS
SELECT P.ProfNetID, C.CriteriaName, C.CriteriaDescription, Sc.SecCode
FROM Professor P
JOIN Teaches T ON T.ProfNetID = P.ProfNetID
JOIN Section Sc ON Sc.SecCode = T.SecCode
JOIN Criteria C ON C.SecCode = Sc.SecCode;


-- View for all scores that all students received in all professors' sections (for all criteria)
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