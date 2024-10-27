USE seniordesignproject; 

-- Inserting the data into the Student Table
INSERT INTO Student (StuNetID, StuUTDID, StuName, StuPassword) VALUES 
('axa190000', 2021504000, 'Prakash Acharya', 2021504000),
('dxa190111', 2021482111, 'Dhanushu Priya', 2021482111),
('sib170121', 2021393333, 'David Barrameda', 2021393333),
('nxb200088', 2021542222, 'Darwin Bollepalli', 2021542222),
('cab160444', 2021308444, 'Chase Burrell', 2021308444),
('nkc160199', 2021345555, 'Kevin Chen', 2021345555),
('zjd130000', 2021188666, 'Zach Dewey', 2021188666),
('lbm170023', 2021427001, 'Lucas Martinez', 2021427001),
('pmr190299', 2021509002, 'Paige Remington', 2021509002),
('vnz180088', 2021445003, 'Veronica Cohen', 2021445003),
('qsw200111', 2021566004, 'Quincy Wells', 2021566004),
('amv170077', 2021391222, 'Anika Verma', 2021391222),
('hjb190045', 2021503111, 'Harvey Blackwell', 2021503111),
('rwf170011', 2021388008, 'Rachel Franklin', 2021388008),
('ckb160099', 2021324555, 'Caleb Bryant', 2021324555),
('xyf190123', 2021512345, 'Xander Fields', 2021512345),
('jpd180567', 2021445678, 'Jessica Diaz', 2021445678),
('mtb170321', 2021398765, 'Michael Burton', 2021398765),
('wkc190011', 2021507890, 'Willow Clark', 2021507890),
('gxh200432', 2021554321, 'Grant Hughes', 2021554321),
('ats180299', 2021459876, 'Alison Swift', 2021459876),
('opd190212', 2021511222, 'Olivia Dunn', 2021511222),
('qzr200010', 2021567890, 'Quentin Rogers', 2021567890),
('rvm170033', 2021399888, 'Rebecca Miller', 2021399888),
('szp190054', 2021514004, 'Samuel Patel', 2021514004),
('ltm180765', 2021465432, 'Lauren Matthews', 2021465432),
('vkj200099', 2021561234, 'Victor Jackson', 2021561234),
('njr170890', 2021387654, 'Noah Richardson', 2021387654),
('kdh190888', 2021501223, 'Kylie Henderson', 2021501223),
('wvf180876', 2021454321, 'William Faulkner', 2021454321);

-- Inserting the data into the Professor Table
INSERT INTO Professor (ProfNetID, ProfUTDID, ProfName, ProfPassword) VALUES 
    ('jdf180090', '2021432123', 'Jason Ford', '2021432123'), 
    ('mks190321', '2021510333', 'Maria Sokolov', '2021510333'), 
    ('tbg170456', '2021367456', 'Tiffany Gibbs', '2021367456'), 
    ('ldw200222', '2021556789', 'Liam Wade', '2021556789'), 
    ('cnj160789', '2021329789', 'Chloe Jensen', '2021329789'); 

-- Inserting the data into the Section Table
INSERT INTO Section (SecCode, SecName) VALUES 
(84745, 'CS 4485.0W1'),
(83909, 'CS 4485.0W2'),
(83568, 'CS 4389.001');

-- Inserting the data into the Teaches Table
INSERT INTO Teaches (ProfNetID, SecCode) VALUES 
('jdf180090', 84745),
('jdf180090', 83909),
('mks190321', 83568);

-- Inserting the data into the Attends Table
INSERT INTO Attends (StuNetID, SecCode) VALUES 
('axa190000', 84745),('dxa190111', 84745),('sib170121', 84745),('nxb200088', 84745),
('cab160444', 84745),('nkc160199', 84745),('zjd130000', 84745),('lbm170023', 84745),
('pmr190299', 84745),('vnz180088', 84745),('qsw200111', 84745),('amv170077', 84745),
('hjb190045', 84745),('rwf170011', 84745),('ckb160099', 84745),('xyf190123', 83909),
('jpd180567', 83909),('mtb170321', 83909),('wkc190011', 83909),('gxh200432', 83909),
('ats180299', 83909),('opd190212', 83909),('qzr200010', 83909),('rvm170033', 83568),
('szp190054', 83568),('ltm180765', 83568),('vkj200099', 83568),('njr170890', 83568),
('kdh190888', 83568),('wvf180876', 83568);

-- Inserting the data into the Team Table (How many inserts per section = number of teams)
INSERT INTO Team (SecCode) VALUES 
(84745),(84745),(84745),
(83909),(83909),
(83568),(83568);

-- Inserting the data into the MemberOf Table
INSERT INTO MemberOf (TeamNum, SecCode, StuNetID) VALUES 
(1, 84745, 'axa190000'),(1, 84745, 'dxa190111'),(1, 84745, 'sib170121'),(1, 84745, 'nxb200088'),(1, 84745, 'cab160444'),
(2, 84745, 'nkc160199'),(2, 84745, 'zjd130000'),(2, 84745, 'lbm170023'),(2, 84745, 'pmr190299'),(2, 84745, 'vnz180088'),
(3, 84745, 'qsw200111'),(3, 84745, 'amv170077'),(3, 84745, 'hjb190045'),(3, 84745, 'rwf170011'),(3, 84745, 'ckb160099'),
(1, 83909, 'xyf190123'),(1, 83909, 'jpd180567'),(1, 83909, 'mtb170321'),(1, 83909, 'wkc190011'),
(2, 83909, 'gxh200432'),(2, 83909, 'ats180299'),(2, 83909, 'opd190212'),(2, 83909, 'qzr200010'),
(1, 83568, 'rvm170033'),(1, 83568, 'szp190054'),(1, 83568, 'ltm180765'),(1, 83568, 'vkj200099'),
(2, 83568, 'njr170890'),(2, 83568, 'kdh190888'),(2, 83568, 'wvf180876');
 
 -- Inserting the data into the Timeslot Table
INSERT INTO Timeslot (StuNetID, TSDate, TSDescription, TSDuration) VALUES
('axa190000', '2024-10-01', 'Worked on the database and importing fake data.', '0:30'),
('axa190000', '2024-10-03', 'Watched a video lecture on Ethics.', '1:15'),
('axa190000', '2024-10-07', 'Met with team members to discuss next steps.', '2:00'),
('axa190000', '2024-10-28', 'Met with the professor for the standup meeting', '0:30'),
('axa190000', '2024-10-29', 'Watched videos on the set up for the web pages in C#', '1:15'),
('axa190000', '2024-10-31', 'Met with team members to discuss next steps.', '2:00'),
('axa190000', '2024-11-01', 'Worked on the student front end framework', '2:00'),
('axa190000', '2024-11-03', 'Made the bare bones student web pages and got the files set up correctly', '4:00'),
('axa190000', '2024-11-04', 'Made the student login page', '0:45'),
('axa190000', '2024-11-06', 'Made the student timesheet week view', '1:30'),
('axa190000', '2024-11-08', 'Made the student timesheet month and project views', '1:30'),
('axa190000', '2024-11-09', 'Made the student peer review bare bones web pages and got the files set up correctly', '3:00'),
('axa190000', '2024-11-10', 'Made the student peer review login page', '0:45'),
('axa190000', '2024-11-11', 'Made the student peer review review page', '1:15'),
('axa190000', '2024-11-12', 'Worked on trying to configure the database and student front end', '1:00'),
('axa190000', '2024-11-13', 'Connected the student login with the database', '0:45'),
('axa190000', '2024-11-14', 'Connected the student change password with the database', '0:45'),
('axa190000', '2024-11-15', 'Connected the student insert timeslot with the database', '0:45'),
('axa190000', '2024-11-16', 'Connected the student delete timeslot with the database', '0:45'),
('axa190000', '2024-11-18', 'Connected the student edit timeslot with the database', '0:45'),
('axa190000', '2024-11-22', 'Worked on the view for the timesheets and how it will be shown on the student side', '2:00'),
('axa190000', '2024-11-24', 'Worked on the student peer review front end', '3:00'),
('axa190000', '2024-11-26', 'Met with the team to try and finish up some of the things as the deadline gets closer', '2:30'),
('axa190000', '2024-11-27', 'Worked on the presentation slides', '0:30'),
('axa190000', '2024-11-29', 'Completed my part of the project and met with the team', '3:00'),
('axa190000', '2024-11-30', 'Worked on organizing all of the source code to make it easier to turn in later', '0:45'),
('axa190000', '2024-12-01', 'Finished up the testing for the project', '2:00'),
('axa190000', '2024-12-03', 'Worked on the presentation slides', '0:30'),
('axa190000', '2024-12-05', 'Practiced our presentations as a group', '1:00'),
('axa190000', '2024-12-06', 'Presented our completed project and participated in Q & A sessions', '5:00'),
('axa190000', '2024-10-21', 'Worked on some of the front end framework', '1:00'),
('axa190000', '2024-10-23', 'Participated in a team meeting to discuss the way we want the front end to look as well as the database', '3:00'),
('axa190000', '2024-10-25', 'Met with the professor for a standup meeting', '0:30'),
('dxa190111', '2024-09-15', 'Met with team members to talk about what we wanted to do next.', '2:00'),
('dxa190111', '2024-09-20', 'Worked on the front end web application.', '2:30'),
('dxa190111', '2024-09-30', 'Set up the Professor\'s desktop app with MAUI.', '1:45'),
('sib170121', '2024-10-08', 'Watched the video lecture on Software Planning.', '1:00'),
('sib170121', '2024-10-08', 'Agile standup meeting with the faculty sponsor.', '0:12'),
('sib170121', '2024-10-08', 'Worked on the database and trying to figure out the relations.', '3:00'),
('nxb200088', '2024-09-12', 'Project specification document diagrams section.', '0:45'),
('nxb200088', '2024-09-13', 'Set up a barebones log in page for the student web application.', '1:30'),
('nxb200088', '2024-09-14', 'Worked on the set up of the student time sheets.', '0:30'),
('cab160444', '2024-09-01', 'Tried to figure out how we wanted to set up the peer review for the professors.', '1:00'),
('cab160444', '2024-09-15', 'Did my part of the project proposal by working on the introduction and the project metrics and the risk analysis.', '1:30'),
('cab160444', '2024-09-30', 'Downloaded C# and .NET on VSCode.', '0:30'),
('nkc160199', '2024-09-27', 'Database configuration, SQL statements, importing to GitHub.', '1:45'),
('nkc160199', '2024-09-30', 'Made up some fake data to add to the database.', '1:00'),
('nkc160199', '2024-10-05', 'Met with the team to figure out what we\'re doing.', '1:45'),
('zjd130000', '2024-10-02', 'Front end: barebones for the peer review student application.', '2:00'),
('zjd130000', '2024-10-07', 'Team Meeting: Plan for faculty meeting, front end discussion, UI barebones ideas.', '2:00'),
('zjd130000', '2024-10-09', 'Front end: worked on more error messages and specification for the peer review student application.', '2:00'),
('lbm170023', '2024-10-01', 'Agile meeting with sponsor.', '0:10'),
('lbm170023', '2024-10-10', 'Worked on setting up the desktop application for the professors and making a basic login page.', '3:30'),
('lbm170023', '2024-10-11', 'Set up the database integration for the professor login page.', '0:45'),
('pmr190299', '2024-09-19', 'Set up the meeting agenda for the week and the weekly meeting time.', '0:20'),
('pmr190299', '2024-09-21', 'Worked on the project proposal introduction.', '0:30'),
('pmr190299', '2024-09-23', 'Met with team, presented what we\'d all done so far, talked about next steps.', '1:00');

-- Inserting the data into the Peer Review Table

INSERT INTO PeerReview (SecCode, ReviewType, ReviewerID) VALUES
(84745, 'Midterm', 'axa190000'),(84745, 'Midterm', 'axa190000'),(84745, 'Midterm', 'axa190000'),(84745, 'Midterm', 'axa190000'),(84745, 'Midterm', 'axa190000'),
(84745, 'Midterm', 'dxa190111'),(84745, 'Midterm', 'dxa190111'),(84745, 'Midterm', 'dxa190111'),(84745, 'Midterm', 'dxa190111'),(84745, 'Midterm', 'dxa190111'),
(84745, 'Midterm', 'sib170121'),(84745, 'Midterm', 'sib170121'),(84745, 'Midterm', 'sib170121'),(84745, 'Midterm', 'sib170121'),(84745, 'Midterm', 'sib170121'),
(84745, 'Midterm', 'nxb200088'),(84745, 'Midterm', 'nxb200088'),(84745, 'Midterm', 'nxb200088'),(84745, 'Midterm', 'nxb200088'),(84745, 'Midterm', 'nxb200088'),
(84745, 'Midterm', 'cab160444'),(84745, 'Midterm', 'cab160444'),(84745, 'Midterm', 'cab160444'),(84745, 'Midterm', 'cab160444'),(84745, 'Midterm', 'cab160444');
 
 
 
 
 -- Inserting the data into the Reviewed Table
INSERT INTO Reviewed (StuNetID, ReviewID, SecCode) VALUES
('axa190000', 1, 84745),('dxa190111', 2, 84745),('sib170121', 3, 84745),('nxb200088', 4, 84745),('cab160444', 5, 84745),
('axa190000', 6, 84745),('dxa190111', 7, 84745),('sib170121', 8, 84745),('nxb200088', 9, 84745),('cab160444', 10, 84745),
('axa190000', 11, 84745),('dxa190111', 12, 84745),('sib170121', 13, 84745),('nxb200088', 14, 84745),('cab160444', 15, 84745),
('axa190000', 16, 84745),('dxa190111', 17, 84745),('sib170121', 18, 84745),('nxb200088', 19, 84745),('cab160444', 20, 84745),
('axa190000', 21, 84745),('dxa190111', 22, 84745),('sib170121', 23, 84745),('nxb200088', 24, 84745),('cab160444', 25, 84745);



-- Inserting the data into the Criteria Table
INSERT INTO Criteria (SecCode, CriteriaName, CriteriaDescription, ReviewType) VALUES
(84745, 'Contributing to Team''s Work', 'How well does the person contributions improve the team''s work? Do they help their teammates who are having a difficult time completing their work?', 'Midterm'),
(84745, 'Interacting with Teammates', 'Do they show an interest in their teammates'' ideas? Do they provide encouragement? Do they ask for feedback and use suggestions?', 'Midterm'),
(84745, 'Keeping Team on Track', 'Do they watch the conditions affecting the team and monitor the progress? Do they make sure the team is making appropriate progress? Do they give feedback on a timely manner?', 'Midterm');


-- Inserting the data into the Scored Table
INSERT INTO Scored (ReviewID, CriteriaID, SecCode, Score) VALUES
(1, 1, 84745, 0),(1, 2, 84745, 0),(1, 3, 84745, 0),
(2, 1, 84745, 0),(2, 2, 84745, 0),(2, 3, 84745, 0),
(3, 1, 84745, 0),(3, 2, 84745, 0),(3, 3, 84745, 0),
(4, 1, 84745, 0),(4, 2, 84745, 0),(4, 3, 84745, 0),
(5, 1, 84745, 0),(5, 2, 84745, 0),(5, 3, 84745, 0),
(6, 1, 84745, 5),(6, 2, 84745, 4),(6, 3, 84745, 3),
(7, 1, 84745, 1),(7, 2, 84745, 2),(7, 3, 84745, 5),
(8, 1, 84745, 4),(8, 2, 84745, 3),(8, 3, 84745, 0),
(9, 1, 84745, 0),(9, 2, 84745, 4),(9, 3, 84745, 2),
(10, 1, 84745, 3),(10, 2, 84745, 5),(10, 3, 84745, 4),
(11, 1, 84745, 2),(11, 2, 84745, 1),(11, 3, 84745, 3),
(12, 1, 84745, 0),(12, 2, 84745, 4),(12, 3, 84745, 5),
(13, 1, 84745, 1),(13, 2, 84745, 1),(13, 3, 84745, 1),
(14, 1, 84745, 3),(14, 2, 84745, 5),(14, 3, 84745, 4),
(15, 1, 84745, 2),(15, 2, 84745, 0),(15, 3, 84745, 5),
(16, 1, 84745, 5),(16, 2, 84745, 5),(16, 3, 84745, 4),
(17, 1, 84745, 2),(17, 2, 84745, 3),(17, 3, 84745, 4),
(18, 1, 84745, 3),(18, 2, 84745, 3),(18, 3, 84745, 3),
(19, 1, 84745, 1),(19, 2, 84745, 0),(19, 3, 84745, 2),
(20, 1, 84745, 5),(20, 2, 84745, 4),(20, 3, 84745, 4),
(21, 1, 84745, 1),(21, 2, 84745, 2),(21, 3, 84745, 3),
(22, 1, 84745, 5),(22, 2, 84745, 4),(22, 3, 84745, 2),
(23, 1, 84745, 0),(23, 2, 84745, 0),(23, 3, 84745, 1),
(24, 1, 84745, 3),(24, 2, 84745, 4),(24, 3, 84745, 5),
(25, 1, 84745, 2),(25, 2, 84745, 1),(25, 3, 84745, 3);
