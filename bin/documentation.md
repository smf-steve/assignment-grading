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
  1. clone the repository
  1. mkdir $HOME/bin
  1. ln -s files to repo
  1. edit $HOME/.profile
     - source $HOME/bin/ 

## User-Level Fuction List

### System Setup Fuctions:
  * create_grading_dir ${class}
    -- update to create roster from classroom_roster.csv
  * create_assignment ${assignment}
    -- if not roster, then generates from classroom_roster.csv
    -- otherwise errors out

### Grade Reporting Functions:
  * grade_join:
  * grades2csv:
  * all_grades2csv:

### Class Grading Functions:
  * grade_start
     - reset_grading
  * clone_submissions [ nil | file | list-of-students ]
  * pull_submissions  [ nil | file | list-of-students ]
  * grade_submissions [ nil | file | list-of-students ]
  * commit_grades     [ nil | file | list-of-students ]
  * publish_grades    [ nil | file | list-of-students ]

  * apply_all         [ nil | file | list-of-students ]


## Grace Period and timelimits
Appears to be a bug 

STATUS="Submission On Time"
GRACE_PERIOD="4m"

ACCEPT_DATE="Feb 19 19:45:09"
 TIME_LIMIT="2H"
   DUE_DATE="Jun 19 21:45:09"
CUTOFF_DATE="Feb 19 23:59:59"

Nop this is currect, 
            you only get the grace period if it is submitted befor the cUTOFF_DATE



---
## Support Fuctions