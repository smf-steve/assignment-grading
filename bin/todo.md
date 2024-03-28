# ToDo:  Assignment Grading



## Potential New Features:
1. add time on task for time activities
   - Release date
   - Due Date
   - Accept date
   - Final Commit 
   - Time on Task: Final - Accept
   - Available Time:  Release - Due Date
   * need to standardize Release time.
   * Add to the ag_log each of the final dates


## Assignment Preparation
1. Update into Key directroy/rubric
1. Update into Key directory/rubric_description
1. Place into Student Directory
   - Due Date
   - Release Date
1. Within github, assign all templates to there id number
   first-assignment  => 01-first assignment

1. Update using the given files with proper format
   - Release Date:
   - Due Date: 

## Pregrade stuff
pregrade_submissions
make -f $KEY_DIR/makefile pregrade

--
tag: graded_version,
does not make sense, when grading based upon code.


## Final Grading Process
  1. double check the assignment of negative values...
     - they should appear inthe .txt files
     - they should be convert to 0 in the .csv files

  1. double check whether or not the .txt files
     - include ALL students in the grade report..
     - e.g., Victor in 44.nextInt does not
 

## Makefile setup
 1. Insert or remove notion of top-level defualt Makefile
 1. review all to ensure
    - paper assignment is in place
 1. makefile for Java and MIPS


# Pregrade Step to Makefile
  - this will allow the student to do run
    $ make pregrade_check to see how things are.

  1. Add a step to do a pregrade check.  
     1. validates that the minimal has been done to do perform grading
        - if paper-based submission, 

     1. If not creates a file call "pregrade.report"
        - this report is published and is given to student
          1. submission.md exists
          1. submission.md differs from key/assignment.md
          1. checks for Name 
          1. checks for GitHub Account
          1. validates that the minum number of commits have been perform
          1. creates a stripped version to show the student what will be graded
     1. This should reduce the funcationality of grade_submission
#  Pregrade step ... Code
   This could be done by a makefile


    make -f MAKEFILE precheck  >string
    if $? error, then 
       string: reasing for failure
       score=0
    
    
    for i in DELIVEREABLES
      if all not found, exit
    
    
    diff $STARTER DELIVEABLE
    if [ $? -no ]
    
    Issue is one deliverable, or multiple




---


-- 
presume there is a defualt class file
presume that file is put in to the right location with being described via the instructions

--


# Todo List:

## Documentation:
  - ADD info of:
    * PREGRADE: TRUE | FALSE
    * GRADE:  make tag
    * ON_CAMPUS:  -z | -n
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

  1. Reset grading
     * Faculty requested -- delete the grading branch 
  1, Regrade
     * student requested regrade
       - previous grading information remains  
       - becasue it has been merged if published, 
          -- otherwise it is equiv to a reset

# Tagging Issue:
  Student did work after the due date
  Student tag their work after the due date
  Student wants grade based upon what they submitted before the due date

  Final Answer..
     - Student needs to tag what they want graded
     - Student must ensure that the tag is set prior to the due 

## Pregrade step
  - identify all assignments that
    1. were not accepted
    1. were accepted by made no additional commits
    1. were changes made but  assignment.md ~= submission.md 
  - update roster.submisions
    - roster.submissions.exceptions: list accounts that failed the pregrade ste
    - roster.submissions: only those that passed the pregrade step

## Grading: Possible issues

  - Notition of the type of assignment
    - is there any benefit to indicate that the assignment was code-base or paper-based or both 

  - Drive from a makefile

## Standard Makefile for
   - MIPS
   - Java
   - Makefile for paper submssion


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
## Logging Information
  - Been reducing the amount of logging
  - Not sure what type of loging is needed.
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



# Bugs

# Push Hook
  1. updates a file to indicate when a particular push is made
  1. potential perfors a pregrade check
     - this might make it easy for the students which is bad, they become dependent on it
  1. send an email to the student indicating blah...


## grade-status
   - review the git extension in .profile.comp122/git... blah
   - determines the status of all the repos.
     1. HEAD   != origin/main -- we have to publish
     1. brannch != main we have to reset
     1. what if origin/main is ahead? 
   - commits made, etc.
   * git status provides to much info, need summary


# activity report
  1. ag_commit_log
  1. transform into 1st level function
  1. ag_commit_log becomes the secondary command
  1. usage  activity_reports [ --date --date ]  [ nil | file | args ]
  1. include .. detached heads

   $ activity_report [ date1 [ date2 ]  ]
     activity_report now accept
      * no args:  shows the ag_show_commit_log
        --  -- :  shows the ag_show_commit_log
      * date1   :     ag_show_commit_log from date1 back in time
      * date1 --:     ag_show_commit_log from date1 back in time

      * date1 date2 :  ag_show_commit_log from date1 back in time until date2 
      *  --   date2 :  ag_show_commit_log from now back in time until date2 

    This is really ag_show_commit_log without report header.


# Multiple grading ...

   1. -- ability to have multiple assignments per repo
   1.  -- grade_start  (default) 
   1. -- grade_start <name>
      * grade_report.<name>
      * due.date.<name>
      * grades.42-string-mips.<name>

      - can allso include roster.<name> to overide the list of users
        - this would be helpful if the grading is for a class-based assignment

