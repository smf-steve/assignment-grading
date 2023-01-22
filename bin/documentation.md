# Documentation

## User-level Files
 - grading_directory
   - assignment_directory
     - assignment.env
     - submissions/
     - key/
     - release_date
     - due_date
     - time_limit
     - grace_period
     - grades.txt
     - makefile
     - grades.txt
     * roster.submissions
     * roster.nonsubmissions
     * roster.nonaccept ?

## Installation
  1. clone the reposityr
  1. mkdir $HOME/bin
  1. ln -s files to repo
  1. edit $HOME/.profile
     - source $HOME/bin/ 

## User-Level Fuction List

### System Setup Fuctions:
  * create_grading_dir ${class}
  * create_assignment ${assignment}

### Grade Reporting Functions:
  * grade_join:
  * grades2csv:
  * all_grades2csv:

### Class Grading Functions:
  * grade_start
     - reset_grading
  * clone_submissions
  * pull_submissions
  * grade_submissions
  * * commit_grading  (not implemented)
  * publish_grades
  * apply_all

### Individual Student Grading Functions
  * regrade_submission ${student}
  * grade_submission ${student}
  * clone_submission ${student}
  * pull_submission ${student}
  * grade_submission ${student}
  * regrade_submission ${student} [ ${commit} ]
     - saves previsous grade report
  * publish_grade ${student}

## Student Content Review Functions 
  * checkout_date ${date} ${student}
  * checkout_due_date ${student}

---
## Support Fuctions