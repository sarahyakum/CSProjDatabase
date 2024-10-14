-- Student_Sections
CREATE VIEW Student_Sections AS
SELECT S.StuName, S.StuNetID, Sec.SecName, Sec.SecCode
FROM Student S
JOIN Attends A ON S.StuNetID = A.StuNetID
JOIN Section Sec ON A.SecCode = Sec.SecCode;

-- Professor_Sections
CREATE VIEW Professor_Sections AS
SELECT P.ProfName, P.ProfNetID, Sec.SecName, Sec.SecCode
FROM Professor P
JOIN Teaches T ON P.ProfNetID = T.ProfNetID
JOIN Section Sec ON T.SecCode = Sec.SecCode;

-- Team_Members
CREATE VIEW Team_Members AS
SELECT M.TeamNum, M.SecCode, S.StuNetID, S.StuName
FROM MemberOf M
JOIN Student S ON M.StuNetID = S.StuNetID;

-- Section_Teams
CREATE VIEW Section_Teams AS
SELECT T.TeamNum, T.SecCode, S.SecName
FROM Team T
JOIN Section S ON T.SecCode = S.SecCode;

-- Student_Reviews
CREATE VIEW Student_Reviews AS
SELECT 
    S.StuName AS ReviewedStudent, 
    R.ReviewID, 
    Reviewer.StuName AS ReviewerName, 
    P.ReviewType, 
    C.CriteriaName, 
    Sc.Score
FROM Reviewed R
JOIN Student S ON R.StuNetID = S.StuNetID
JOIN PeerReview P ON R.ReviewID = P.ReviewID
JOIN Student Reviewer ON P.ReviewerID = Reviewer.StuNetID
JOIN Scored Sc ON P.ReviewID = Sc.ReviewID
JOIN Criteria C ON Sc.CriteriaID = C.CriteriaID
ORDER BY S.StuName, Reviewer.StuName;

-- Student_Timeslots
CREATE VIEW Student_Timeslots AS
SELECT S.StuName, T.TimeslotID, T.TSDate, T.TSDescription, T.TSDuration
FROM Timeslot T
JOIN Student S ON T.StuNetID = S.StuNetID;
