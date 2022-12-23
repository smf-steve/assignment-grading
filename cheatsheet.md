# Cheatsheet for Assignment Grading

## Files:
   - nn-assignment-directory
     * release.date
     * due.date:
       - date format: "+%b %d %T"
       - example: "Nov 12 00:00:00"  
     * timelimit
       - date format: "value[ymwdHMS]"
       - example: 2H
     * grace_period: Note provided by the professor
       - date format: "value[ymwdHMS]"
       - example: 15M
     * submissions: directory of all the student's submission

## Setup
1. mkdir -p assignment-grading/nn-assignment-name
1. cd assignment-grading/nn-assginment-directory            
1. git clone assignment-key.git key

## Assignment Prepare
1. cd nn-assginment-directory/key
1. ...

## Cloning of Submissions
1. cd nn-assginment-directory
1. source ../bin/grade.bash
1. grade_start
1. clone_submissions

## Grading of Submissions
1. cd nn-assginment-directory
1. source ../bin/grade.bash
1. grade_start
1. 