# Description of the Views:

## Student

  - **student_timeslots** : Creates view for all timeslots of all students in the system

  - **student_peer_review_criteria** : Creates view for all criteria categories for all students in the system

  - **student_team_and_section** : Creates view for the team number and section code of all students in the system


## General


## Professor 

  - **professor_sections** : Creates view for all sections of all professors in the system

  - **professor_students** : Creates view for all students in all teams of all sections of all professors in the system

  - **professor_peer_review_criteria** : Creates view for all criteria categories for all sections of all professors in the system


# Description of the Procedures:


## Student

  - **check_student_login** : Checks the student's inputted login information to see if it exists in the system  
      - *Inputs:* Inputted username, Inputted Password  
      - *Outputs:* Count of matches in system (should be 1)
      
  - **change_student_password** : Allows the student to change their password  
      - *Inputs:* Student NetID, Old Password, New Password  
      - *Outputs:* 0 if the password was changed correctly, 1 otherwise

  - **student_insert_timeslot** : Allows the student to insert a timeslot, Description has to be longer than 30 characters, Date must be in most recent 3 days and not in future
      - *Inputs:* Student NetID, Timeslot Date, Description, and Duration  (Date in SQL is in format 'YYYY-MM-DD')  
      - *Outputs:* 0 if timeslot was inserted correctly, 1 otherwise
   
  - **student_edit_timeslot** : Allows the student to edit the description or duration of a timeslot. Must be within past three days, not in the future, and the description must remain longer than 30 characters.
      - *Inputs:* Student NetID, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Duration
      - *Outputs:* 0 if timeslot was altered correctly, 1 otherwise
   
 -  **student_delete_timeslot** : Allows the student to delete a timeslot as long as it is within the last 3 days
      - *Inputs:* Student NetID, Timeslot Date  ('YYYY-MM-DD')
      - *Outputs:* 0 if deleted corretly, 1 otherwise
  
- **student_insert_score**: Inserts the score for a peer review that a student gave
    - *Inputs:* Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, Score
    - *Outputs:* 0 if inserted correctly, 1 otherwise

  
## General

  - **student_total_time** : Adds up the total time the student has spent on the project  
      - *Inputs:* Student NetID   
      - *Outputs:* The total time in minutes

  - **student_time_in_range** : Adds up the total time the student has spent during a given date range   
      - *Inputs:* Student NetID, Start Date, End Date (Dates in SQL are in format 'YYYY-MM-DD')   
      - *Outputs:* The total time in minutes for that range

  - **student_timeslot_by_date** : Retrieves all timeslots for a student on a given date
      - *Inputs:* Student NetID, Timeslot Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration

  - **student_timeslot_by_week** : Retrieves all timeslots for a student in a 7 day window (given start date)
      - *Inputs:* Student NetID, Start Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration

  - **student_timeslot_by_month** : Retrieves all timeslots for a student in a 30 day window (given start date)
      - *Inputs:* Student NetID, Start Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration


## Professor 

 - **check_professor_login** : Checks the professor's inputted login information to see if it exists in the system  
    - *Inputs:* Inputted username, Inputted Password  
    - *Outputs:* Count of matches in system (should be 1)

  - **change_profesor_password** : Allows the professor to change their password  
      - *Inputs:* Professor NetID, Old Password, New Password  
      - *Outputs:* 0 if the password was changed correctly, 1 otherwise

- **get_section_criteria** : Retrieves all peer review criteria for a given professor's given section
    - *Inputs:* Professor NetID, Section Code
    - *Outputs:* For all criteria: Professor NetID, Criteria Name, Criteria Description, Section Code
 
- **get_section_criteriaid** : For the professor to get the criteria ID info for the section before being able to edit it
    - *Inputs:* Professor NetID, Section Code
    - *Outputs:* CriteriaID, Criteria Name, Criteria Description for all Criteria

- **professor_create_criteria** : Allows the professor to create new criteria for a section
    - *Inputs:* Professor NetID, Section Code, Criteria Name, Criteria Description 
    - *Outputs:* 0 if the criteria was added correctly, 1 otherwise

- **professor_edit_criteria** : Allows the professor to enter an updated Criteria Name and Description
    - *Inputs:* Professor NetID, Section Code, CriteriaID, Updated Criteria Name, Updated Criteria Description
    - *Outputs:* 0 if it was edited corretly, 1 if it was not
    - Ideally for this one get_section_criteriaid would be called first which would return all of the information for the criteria in this section, and then they would be able to alter from there because the CriteriaID is necessary to make the edits.
   
- **professor_delete_criteria** : Allows the professor to delete a criteria from the database
    - *Inputs:* Professor NetID, Section Code, Criteria Name
    - *Outputs:* 0 if deleted correctly, 1 otherwise
    - *Disclaimer:* A criteria cannot be deleted it is a part of a Peer Review/ used in the Scored Table. As mentioned in the create_peer_reviews function, once the peer reviews have been made the professor will not be able to alter or delete criteria or reviews.


- **create_peer_reviews** : Allows the professor to create the peer reviews for a section  
    - *Inputs:* Professor NetID, Section Code, Review Type   
    - *Outputs:* 0 if the reviews were made correctly, 1 if it was not  
    - *SubProcedures:* insert_peer_reviews and insert_scored_table  
    - **_Creation Disclamer:_** For this one it creates a lot of entries for the PeerReviews, Reviewed, and Scored Tables which would be extremely difficult to try and remove. So if when the professor is choosing to create the peer reviews we should display a 'Are you sure you want to do this? Once these Peer Reviews have been created, the Peer Reviews and Criteria cannot be altered or deleted unless all associated Peer Reviews and Scores data is deleted' Or something along those lines if that seems feasible.  
    - *Working With load.sql:* This initializes all of the scores to 0, so if you want to test the scores and averages don't use this procedure and just use the data in load.sql. However if you want to test this procedure then you would comment out the PeerReview, Reviewed, and Scored insertions in load.sql.

- **professor_view_averages** : Allows the professor to view the average score given to each student based on the criteria  
    - *Inputs:* Professor NetID, Section Code, Review Type (Midterm or Final)  
    - *Outputs:* Pulls the student averages for each criteria

- **change_view_individual_scores** : Allows the professor to view the individual scores the student received  
    - *Inputs:* Professor NetID, Section Code, Student NetID, Review Type (Midterm or Final)  
    - *Outputs:* Reviewer NetID, Reviewer Name, Criteria Name, and Score

- **get_student_scores_received** : Pulls all of the scores that a student was given from their team members and themselves
    - *Inputs:* Professor NetID, Section Code, Reviewee NetID, Review Type
    - *Outputs:* Professor NetID, Section Code, Team Number, Reviewee NetID, Reviewer NetID, Review Type, Criteria Name, Score
 
- **get_student_scores_given** : Pulls all of the scores that a student gave to all of their team members and themselves
    - *Inputs:* Professor NetID, Section Code, Student NetID, Review Type
    - *Outputs:* Professor NetID, Section Code, Team Number, Reviewee NetID, Reviewer NetID, Review Type, Criteria Name, Score

- **edit_scores_given** : Allows the professor to go in and change a score that was given for a student
    - *Inputs:* Professor NetID, Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, New Score
    - *Outputs:* 0 if altered correctly, 1 otherwise

- **professor_insert_num_teams** : Inserts x teams into the section
    - *Inputs:* Professor NetID, Section Code, Number of Teams
    - *Outputs:* 0 if the teams were inserted correctly, 1 if they were not
 
- **professor_delete_team** : Allows the professor to delete a team from their section
    - *Inputs:* Professor NetID, Section Code, Team Number
    - *Outputs:* 0 if deletion was successful, 1 otherwise
    - *Disclaimer:* This function goes into the MemberOf Table and removes every student from the team before deleting the team
 
- **professor_change_student_team** : Allows the professor to switch a student to a different Team
    - *Inputs:* Professor NetID, Section Code, Student NetID, New Team Number
    - *Outputs:* 0 if the Team was changed correctly, 1 otherwise
