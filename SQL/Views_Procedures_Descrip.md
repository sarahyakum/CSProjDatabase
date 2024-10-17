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
      - *Outputs:* 0 if the password was changed correctly, 1 if it was not

  - **student_insert_timeslot** : Allows the student to insert a timeslot  
      - *Inputs:* Student NetID, Timeslot Date, Description, and Duration  (Date in SQL is in format 'YYYY-MM-DD')  
      - *Outputs:* 0 if timeslot was inserted correctly, 1 if it was not

  
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
      - *Outputs:* 0 if the password was changed correctly, 1 if it was not

  - **professor_create_criteria** : Allows the professor to create new criteria for a section
      - *Inputs:* Professor NetID, Section Code, Criteria Name, Criteria Description 
      - *Outputs:* 0 if the criteria was added correctly, 1 if it was not

  - **professor_view_averages** : Allows the professor to view the average score given to each student based on the criteria  
      - *Inputs:* Professor NetID, Section Code, Review Type (Midterm or Final)  
      - *Outputs:* Pulls the student averages for each criteria

  - **change_view_individual_scores** : Allows the professor to view the individual scores the student received  
      - *Inputs:* Professor NetID, Section Code, Student NetID, Review Type (Midterm or Final)  
      - *Outputs:* Reviewer NetID, Reviewer Name, Criteria Name, and Score

  - **create_peer_reviews** : Allows the professor to create the peer reviews for a section  
      - *Inputs:* Professor NetID, Section Code, Review Type   
      - *Outputs:* 0 if the reviews were made correctly, 1 if it was not  
      - *SubProcedures:* insert_peer_reviews and insert_scored_table  
      - *Creation Disclamer:* For this one it creates a lot of entries for the PeerReviews, Reviewed, and Scored Tables which would be extremely difficult to try and remove. So if when the professor is choosing to create the peer reviews we should display a 'Are you sure you want to do this? Once they have been created they cannot be altered or deleted.' Or something along those lines if that seems feasible.  
     - *Working With load.sql:* This initializes all of the scores to 0, so if you want to test the scores and averages don't use this procedure and just use the data in load.sql. However if you want to test this procedure then you would comment out the PeerReview, Reviewed, and Scored insertions in load.sql.

 - **get_section_criteria** : Retrieves all peer review criteria for a given professor's given section
      - *Inputs:* Professor NetID, Section Code
      - *Outputs:* For all criteria: Professor NetID, Criteria Name, Criteria Description, Section Code
