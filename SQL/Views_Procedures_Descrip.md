# Description of the Views:

## Student

  - **student_timeslots** : Creates view for all timeslots of all students in the system

  - **student_peer_review_criteria** : Creates view for all criteria categories for all students in the system (for each section and review type)

  - **student_team_and_section** : Creates view for the team number and section code of all students in the system


## Professor 

  - **professor_sections** : Creates view for all sections taught by all professors

  - **professor_students** : Creates view for all students in all teams of all sections taught by all professors

  - **professor_peer_review_criteria** : Creates view for all criteria categories for all sections taught by all professors

  - **professor_student_scores** : Creates view for all scores that all students received in all sections taught by all professors



# Description of the Procedures:


## Student

  - **check_student_login** : Checks the student's inputted login information to see if it exists in the system  
      - *Inputs:* Inputted username, Inputted Password, @Variable to hold status/ error message  
      - *Outputs:* Message: either 'Success' or condition that was not met 
      
  - **change_student_password** : Allows the student to change their password  
      - *Inputs:* Student NetID, Old Password, New Password, @Variable to hold status/ error message  
      - *Outputs:* Message: either 'Success' or condition that was not met 

  - **student_insert_timeslot** : Allows the student to insert a timeslot, Description has to be longer than 30 characters, Date must be in most recent 3 days and not in future
      - *Inputs:* Student NetID, Timeslot Date, Description, and Duration  (Date in SQL is in format 'YYYY-MM-DD'), @Variable to hold status/ error message   
      - *Outputs:* Message: either 'Success' or condition that was not met
   
  - **student_edit_timeslot** : Allows the student to edit the description or duration of a timeslot. Must be within past three days, not in the future, and the description must remain longer than 30 characters.
      - *Inputs:* Student NetID, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Duration, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
  
  -  **student_delete_timeslot** : Allows the student to delete a timeslot as long as it is within the last 3 days
      - *Inputs:* Student NetID, Timeslot Date  ('YYYY-MM-DD'), @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
  
  - **student_insert_score** : Inserts the score for a peer review that a student gave
      - *Inputs:* Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, Score, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met

  - **student_get_peer_review_criteria** : Retrieves the peer review criteria for a particular student and section (given the review type)
      - *Inputs:* Student NetID, Review Type (Midterm or Final), Section Code
      - *Outputs:* For all criteria: Criteria Name, Criteria Description

  - **student_get_team_members** : Retrieves the team members of a particular team in a specific section
      - *Inputs:* Team Number, Section Code
      - *Outputs:* For all team members: Student Name, Student NetID

  - **student_view_averages** : Retrieves the average score that a student received for each criteria 
      - *Inputs:* Student NetID, Section Code, Review Type
      - *Outputs:* For all criteria of a particular review type: Criteria Name, Average Score
   
  - **number_student_in_team** : Retrieves the number of students in a student's team
      - *Inputs:* Student NetID, Section Code, @Variable for number in team, @Variable for status message
      - *Outputs:* Message: 'Success' or the condition not met, Number in Team: 0 if not found, or number in team
   
  - **check_peer_review_availability** : Allows the student to check whether there is currently a peer review that is available
      - *Inputs:* Section Code, @Variable for message
      - *Outputs:* Message: 'Success' or reason not available
   
  - **get_section_timeframe** : Allows the student side to grab the timeframe for the semester
      - *Inputs:* Section Code
      - *Outputs:* Start Date, End Date

  - **student_peer_review_page** : Checks what the peer review page should show for the student
      - *Inputs:* Student NetID, Section Code, @Variable for the message
      - *Outputs:* 'Peer Review needs to be completed', 'Peer Reviews completed, waiting until the end of the review session to view average scores''Average scores for the last review type: (review type)'
  
## General

  - **student_total_time** : Adds up the total time the student has spent on the project  
      - *Inputs:* Student NetID   
      - *Outputs:* The total time in HH:MM

  - **student_time_in_range** : Adds up the total time the student has spent during a given date range   
      - *Inputs:* Student NetID, Start Date, End Date (Dates in SQL are in format 'YYYY-MM-DD')   
      - *Outputs:* The total time in HH:MM for that range

  - **student_timeslot_by_date** : Retrieves all timeslots for a student on a given date
      - *Inputs:* Student NetID, Timeslot Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration
      - Note: This procedure, along with student_timeslot_by_week/month, would ideally be used in displaying the timeslots in calendar view in the student web app

  - **student_timeslot_by_week** : Retrieves all timeslots for a student in a 7 day window (given start date)
      - *Inputs:* Student NetID, Start Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration

  - **student_timeslot_by_month** : Retrieves all timeslots for a student in a 30 day window (given start date)
      - *Inputs:* Student NetID, Start Date
      - *Outputs:* For all timeslots: Student NetID, Student Name, Timeslot Date, Timeslot Description, Timeslot Duration

  - **get_section_students** : Retrieves all students in a given section
      - *Inputs:* Section Code
      - *Outputs:* Student NetIDs



## Professor 

  - **check_professor_login** : Checks the professor's inputted login information to see if it exists in the system  
      - *Inputs:* Inputted username, Inputted Password, @Variable to hold status/ error message   
      - *Outputs:* Message: either 'Success' or condition that was not met

  - **change_profesor_password** : Allows the professor to change their password  
      - *Inputs:* Professor NetID, Old Password, New Password, @Variable to hold status/ error message   
      - *Outputs:* Message: either 'Success' or condition that was not met
 
  - **get_section_criteriaid** : For the professor to get the criteria ID info for the section before being able to edit it
      - *Inputs:* Professor NetID, Section Code, Review Type, @Variable to hold status/ error message 
      - *Outputs:* CriteriaID, Criteria Name, Criteria Description for all Criteria

  - **professor_create_criteria** : Allows the professor to create new criteria for a section
      - *Inputs:* Professor NetID, Section Code, Criteria Name, Criteria Description, Review Type, @Variable to hold status/ error message  
      - *Outputs:*Message: either 'Success' or condition that was not met

  - **professor_edit_criteria** : Allows the professor to enter an updated Criteria Name and Description
      - *Inputs:* Professor NetID, Section Code, CriteriaID, Updated Criteria Name, Updated Criteria Description, Review Type, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
      - Ideally for this one get_section_criteriaid would be called first which would return all of the information for the criteria in this section, and then they would be able to alter from there because the CriteriaID is necessary to make the edits.
   
  - **professor_delete_criteria** : Allows the professor to delete a criteria from the database
      - *Inputs:* Professor NetID, Section Code, Criteria Name, Review Type, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
      - *Disclaimer:* A criteria cannot be deleted it is a part of a Peer Review/ used in the Scored Table. As mentioned in the create_peer_reviews function, once the peer reviews have been made the professor will not be able to alter or delete criteria or reviews.

  - **create_peer_reviews** : Allows the professor to create the peer reviews for a section  
      - *Inputs:* Professor NetID, Section Code, Review Type, Start Date, End Date @Variable to hold status/ error message    
      - *Outputs:* Message: either 'Success' or condition that was not met  
      - *SubProcedures:* insert_peer_reviews and insert_scored_table  
      - **_Creation Disclamer:_** For this one it creates a lot of entries for the PeerReviews, Reviewed, and Scored Tables which would be extremely difficult to try and remove. So if when the professor is choosing to create the peer reviews we should display a 'Are you sure you want to do this? Once these Peer Reviews have been created, the Peer Reviews and Criteria cannot be altered or deleted unless all associated Peer Reviews and Scores data is deleted' Or something along those lines if that seems feasible.  
      - *Working With load.sql:* This initializes all of the scores to 0, so if you want to test the scores and averages don't use this procedure and just use the data in load.sql. However if you want to test this procedure then you would comment out the PeerReview, Reviewed, and Scored insertions in load.sql.

  - **professor_view_averages** : Allows the professor to view the average score given to a particular student based on a specific criteria  
      - *Inputs:* Professor NetID, Student NetID, Section Code, Review Type (Midterm or Final)  
      - *Outputs:* For each criteria: Criteria Name and Average Score

  - **professor_view_individual_scores** : Allows the professor to view the individual scores the student received  
      - *Inputs:* Professor NetID, Section Code, Student NetID, Review Type (Midterm or Final)  
      - *Outputs:* Reviewer NetID, Reviewer Name, Criteria Name, and Score

  - **edit_scores_given** : Allows the professor to go in and change a score that was given for a student
      - *Inputs:* Professor NetID, Section Code, Reviewer NetID, Reviewee NetID, Criteria Name, New Score, Review Type, , @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met

  - **professor_insert_num_teams** : Inserts x teams into the section
      - *Inputs:* Professor NetID, Section Code, Number of Teams, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
 
  - **professor_delete_team** : Allows the professor to delete a team from their section
      - *Inputs:* Professor NetID, Section Code, Team Number, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
      - *Disclaimer:* This function goes into the MemberOf Table and removes every student from the team before deleting the team
 
  - **professor_change_student_team** : Allows the professor to switch a student to a different Team
      - *Inputs:* Professor NetID, Section Code, Student NetID, New Team Number, @Variable to hold status/ error message 
      - *Outputs:* Message: either 'Success' or condition that was not met
   
  - **reuse_criteria** : Allows the professor to reuse the criteria from a previous Review Type for a new Review Type
      - *Inputs:* Professor NetID, Section Code, Old Criteria Type, New Criteria Type, @Variable to hold status/ error message
      - *Outputs:* Message: 'Success' or the condition that was not met

  - **professor_get_sections** : Retrieves all sections that a given professor teaches
      - *Inputs:* Professor NetID
      - *Outputs:* Section Code and Section Name, for all sections

  - **professor_add_students** : Allows the professor to add students to a section
    - *Inputs:* Student NetID, Student UTDID, Student Name, Section Code, @Variable for message
    - *Outputs:* Message: 'Success' or condition not met
   
  - **add_student_to_team** : Allows the professor to add a student to a team
      - *Inputs:* Team number, Student NetID, Section Code, @Variable for message
      - *Outputs:* Message: 'Success' or condition not met
   
  - **professor_add_section** : Allows the professor to add their sections
      - *Inputs:* Professor NetID, Section Code, Section Name, Start Date, End Date, @Variable for message
      - *Outputs:* Message: 'Successs' or condition not met

  - **professor_get_incomplete_reviews** : Returns the students who haven't completed a specific peer review
      - *Inputs:* Section Code, Review Type
      - *Outputs:* Student NetIDs of students who have incomplete peer reviews

  - **professor_edit_timeslot** : Allows the professor to edit a student's timeslot
      - *Inputs:* Student NetID, Timeslot Date ('YYYY-MM-DD'), Updated Description, Updated Duration, and a variable to hold the error message
      - *Outputs:* Error Message: 'Success' or a description of which condition it violated
   
### Stretch Goals

  - **timetrack_student_emails** : Returns the emails for the students who have not entered any timeslots between a inputted date and the current date
      - *Inputs:* Section Code, Input Date (Most likely the start of the week)
      - *Outputs:* Student emails who have not added timeslots in time frame
   
  - **peerReviews_student_emails** : Returns the emails for the students who have not completed the current peer review for a section
      - *Inputs:* Section Code
      - *Outputs:* Student emails who have not completed the peer reviews 


*Disclaimer*: For a professor to initialize everything at the start of the semester they need to do it in this order:
  - professor_add_section
  - professor_add_students
  - professor_insert_num_teams
  - add_student_to_team
