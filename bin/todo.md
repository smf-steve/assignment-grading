
--
Within github, assign all templates to there id number
  first-assignment  => 01-first assignment

Update the code to reflect this... it might be the case already

---
update the system to ignore comments in 
  timelimit and graceperiod
  add the default settings if you will to these filfes

--
change name of directory from 
   key --> template

-- 
presume there is a defualt class file
presume that file is put in to the right location with being described via the instructions

  -- 
  get rid of the notaion of the release date...or starte adding it.

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

# Makefiles
  -- makefile for Java and MIPS


# Bugs

1. assignment-grading/grades..txt
   - This file gets created under some condition
   - Need to determine when and how

# Santity Checks
1. Grade_start
   is used to do some santity checks and to source the environment
   but 
      - we have to cd to the correct assignment directory
      - we have to run the other commands from that location
      - Hence, other than doing a santity check, why do we need to run grade_start
         -- BECAUSE then we don't need to resource the environent
            -- if and only if
               -- we are in the tree of  ..../assignment-grading/xxx-assignment

    should each of the subsequent commands
       A: resource the environment -- hance no need to do a grade_start
       B: simple check that a signle ENV is set to
          - e.g, ASSIGNMENT_Director == the parent of the cwd

    due date must have seconds in it
       - not valid: mar 23 23:59
     - valid:  mar 23 23:59:59



# Regrade
  1. Regrade needs to have a different process..
     - should it copy the original grade.report to something else
     - should it have an extra line in the report noting it is a regrade.
     - should the branch name be updated
     1. Consider `regrade_submission hash username ...`


# Push Hook
  1. updates a file to indicate when a particular push is made
  1. potential perfors a pregrade check
     - this might make it easy for the students which is bad, they become dependent on it
  1. send an email to the student indicating blah...

# Pregrade Step
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




## Grading Rubric / Description
   - add option to include information in the grade report
     ```
     # Grading Report
     # Github Account: 
     # Assignment: 
     # Assignment ID: 
     # --- Due Date:        "Feb 19 23:59:59"
     # --- Submission Date: "Feb 19 20:20:23"
     # --- Tag & Hash:      "submission (83ecbf1)"
     
     %include $KEY_DIR/grading_description

        8 Points:            Theoretical machines (10 points): 4 abstract machines
     ---
      98 Points:             Total
    ```     

## grade-status
   - determines the status of all the repos.
     1. HEAD   != origin/main -- we have to publish
     1. brannch != main we have to reset
     1. what if origin/main is ahead? 
   - commits made, etc.
   * git status provides to much info, need summary


# git pull
  1. validate git pull does an auto merge and/or reports if a conflic exists

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

    This is rally ag_show_commit_log without report header.


# Multiple grading ...

   1. -- ability to have multiple assignments per repo
   1.  -- grade_start  (default) 
   1. -- grade_start <name>
      * grade_report.<name>
      * due.date.<name>
      * grades.42-string-mips.<name>

      - can allso include roster.<name> to overide the list of users
        - this would be helpful if the grading is for a class-based assignment


