# Cheatsheet for Assignment Grading

ASSIGNMENT_DIRECTORY=
CLASS_DIR=
GITHUB_CLASS=

## Repository Install and Setup
   1. git clone assignment-grading.git $ASSIGNMENT_DIRECTORY
   1. cd ~/bin/
      1. ln -s $ASSIGNMENT_DIRECTORY/bin/grade.bash
      1. ln -s $ASSIGNMENT_DIRECTORY/bin/git.statistics.bash
   1. 
      ```
      cat >> ~/.profile <EOF
      source $HOME/bin/grade.bash
      EOF
      ```

## Class Setup
   1. mkdir $CLASS_DIR
   1. cd $CLASS_DIR
   1. create_grading_directory $GITHUB_CLASS
   1. download classroom_roster.csv from GitHubClassroom
   1. create roster
      ```
      awk -F, '{print $2}' classroom_roster.csv |
        sed 's/"//g' | sort -f > roster
      ```
   1. Post grading:
      - grades2csv grades_xxxx.txt

## Assignment Setup
   1. cd $CLASS_DIR/assignment-grading
   1. create_assignment "xx-assignment-name"
   1. cd "xx-assignment-name"
   1. git clone assignment-key.git key
   1. Revise files as needed
      * release_date:
      * due_date:
        - date format: "+%b %d %T"
        - example: "Nov 12 00:00:00"  
      * time_limit:
      * grace_period: 
        - date format: "value[ymwdHMS]"
        - example: 15M

## Grading Process
   1. cd $CLASS_DIR/assignment-grading
   1. cd "xx-assignment-name"
   1. grade_start
   1. reset_grading

## Assignment Grading Commands
   1. clone_submissions
   1. pull_submissions
   1. grade_submissions
   1. publish_grades
   1. apply_all  "command list"

## Individual Grading Commands
   1. clone_submission  student
   1. pull_submission   student
   1. grade_submission  student [ commit ]
   1. publish_grade     student


## Final Grading process.

   1. Download Official Roster
   1. Integerate github account names, and sort by...
   1. Validate all grades.\*.txt have no duplicates (from individual regrades)
   1. Run `grades_log2cvs` on all grades.\*.txt
   1. Update spreadsheet to includ grades.\*.cvs files

