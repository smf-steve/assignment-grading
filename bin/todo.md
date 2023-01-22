# Todo List:

## Documentation:
  - Diagram of the process to perform grading
  - An API list (If you will) of all functions and what they do
  - Refine Process.md as appropriate
  - Explain the Grade Report
  - Document all the Professor realted files:
    - I.e. those in xx-assignment/
    - release_date&
    - due_date
    - time_limit
    - grace_period

## Pregrade step
  - identify all assignments that
    1. were not accepted
    1. were accepted by made no additional commits
    1. were changes made but  assignment.md ~= submission.md 
  - update roster.submisions
    - roster.submissions.exceptions: list accounts that failed the pregrade ste
    - roster.submissions: only those that passed the pregrade step

## Grading: Possible issues
  - clone_assignment of a student who did not accept the assignment
    * Essentially, you clone at the due date -- any futher updates are not possible
    - you are left with a missing directory
      - grade report is assumed to be nil -- this impacts the grade reporting issue
    - you have an empty directory
      - allows a grade report to be provided
      - prevents the student from accepting the assignment later

  - Notition of the type of assignment
    - is there any benefit to indicate that the assignment was code-base or paper-based or both 

  - Drive from a makefile

  - Test Grading does the branch process correctly

  - Change of current process?  
    - Is there a benefit? : it allows for simplier code(?), allows for review of all gr
    * Current
      - grade_submissions
      - publish_submissions
    * Future:
      - grade_submissions: creates branch
      - commit_grading : merges branch, add grade.report, answers.md, etc.
      - publish_grades:  only performs the push operaton

## Standard Makefile for
   - MIPS
   - Java

## Grade Report
  - Review the presentation
  - Review and revised the statistical report
  - if Comments are made, force a new line as opposed to printing them at the end of the line

## Generate a Class Grade Report
  - summary:  #students, #accepts, #valid_submissions, #average, 
    - #students: wc classroom
    - #accepts: ls -d submissions/* | wc
    - #valid:  pretest past
    - #average: of valid

---
## Testing
  - Grade processing to
    - checkout the version
    - branch the version
    - commit the files
    - then merge the files
  - Makefile for paper submssion

## Logging Information
  - Not sure what the current logging of information provides
  - Perhaps two types of logging.  
    - Aggregate Logging:  i.e., clone_submission"s", apply_all
    - Individual Loggin:  i.e. pull_submission student


## Ability to have multiple assignments per repo
  - grade_start  (default) 
  - grade_start "\<name\>"
  * grade_report.\<name>
  * due.date.\<name>
  * grades.42-string-mips.\<name>.txt


## Review
  - mechanism to prompt rubric.grading
  - error messages are relative
  - need to error/ override correct by Prof.   create branch, make fix, merge (or leave it as is ) ???


## Coding Grading:
  - Testing hook for programming
    - must compile
    - must have intial files that are for the deliverables


## Internal Code
  - error messages with relative filenames
    - ../assignment-grading/.....
  - update the names of functions to determine which are internal and not internal
  - harding ensure all external functions have 
    - a usage
    - validity check to be calls.
  - do we force all functions to only be called from the Assignment-directory
    - NO. 
    - No, but printout the name of the assignment being actied upon
    - Yes.
      ```bash
        if [[ $ASSIGNMENT_NAME != $(basename $ASSIGNMENT_GRADING_DIR ]] ; then
          echo "Error: Need to run grad"
        fi 
      ```
