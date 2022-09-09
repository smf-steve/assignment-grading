# Issues and Improvements


## Process Issues:
After using this system to grade student submissions for two semesters, here is a list of common issues encountered.

1. use the github classroom roster format for the roster.

1. Even with repeations, students find it difficult to follow the process.
   * So reenforcement is good.

1. Submissions are now more abstract, hence students tend to forget about deadlines
   * Provide support deadlines would help. Some dates to consider:
     - Release-date: first date to create a repo
     - Accept-by:    last date to create a repo
     - Due-date: the expected date in which a valid push can be made to a repo
     - Grading-date: the day in which the grading will begin
     - Freeze-date: the last date in which a grade change can be mad

1. Grade Reporting
   * The name of the grade report is the same for each process
     - update the name to be assignment specific
   * Update the structure of the report to more clearly hightlight feedback
     - for example
     ```
     # Grading summary for sample_assignment Assignment
     Points  Description
     5 / 5   Name
     5 / 5   GitHub Account
     8 / 10  Section One #1:
     	 did not provide full year
     2 / 10  Section One #2:
             wrong text
     5 / 40  Section Two: 
             missed the point of the question
     4 / 15  Section Four: 
             Fetch, Decode, Execute, Mem, Write-back
     10 / 15  Adherence to protocol:

     ------
     39 / 39 Total

     <Summary Feedback>

     ```
   * Ignore blank lines in the grading_rubric file
   * Auto add blank line at the end to provide summary feedback
   * It would be better to pull up an editor for each submission for grading, instead of using the CLI

## Implementations Issues

1. The process is highly dependent on both the $PWD, and environment variables
   - it is easy to be confused which assignment is current the "active assignment"
   1. modify the grade_start command to provide a summary the assignment information
   1. validate that the $PWD and enviroment varialbes are in sync

1. We have the following major things
   1. assignment:  ``grade_start`` ensures this are set correct
   1. class:       ``source bin/grading.bash .`` ensures this is set correct
   - If you have multiple classes then, 
     1. need to source grading.bash script once
     1. need to have a command that picks a class -- by location?
     1. need to have a command that picks an assignment
1. A makefile process was added to allow different processes for grading
   1. The structure of the makefile is a bit brittle (need to cleanup)
   1. There is a possibility of inconsistent values between the ENV and Make-Variables.
   1. It would be great if a makefile was provided to the students
      - the issue here is some are using windows that might not have the right environment

1. Roster is based upon github handle
   1. Update the roster to provide a second filed for, e.g., student email address

1. Final grades consolidation
   1. Regrading is possible, and values are added to the bottom
   1. There is also a non submission list
   1. Need a process by which the two files can be added, with
      the earliest duplicate removed

1. Consider Introducting a NAMESPACE prefix for Environment variables: - GRADE_ ?

1. Rename ENVs to clearly identify which are 
   - relative to the student repo (relative URLs)
   - relative to the assignment (absolute URLs)

1. Reconsider the name of these functions to be more consistent
   ```
   clone_submission () 
   clone_submissions () 
   grade_start () 
   grade_submission () 
   grade_submissions () 
   publish_grade () 
   publish_grades () 
   pull_submission () 
   pull_submissions () 
   reset_grading ()
   ```

