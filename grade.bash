#! /bin/bash

# This script files defines a number of functions to faciliate
# the grading of student assignments submitted via GitHub Classroom.

# Theses assignments are presumed to be paper-based like assignments within a text file.
# Hence, a visual review of each SUBMISSION_FILE is neeeded.  It is also presumed that
# each line that contains an answer includes the ANSWER_TAG that allows for
# the collection of just the answers via a simple 'grep' of the SUBMISSION_FILE

# The appropriate file is opened for visual review, and then, via the CLI, the professor is 
# prompted for a score for each individual element in the scoring guide (rubric)


################################################################################################
# Classroom Setup Process
#   - create a github organization
#   - create a github classroom
#   - updated the classroom.env file

# Assignment Grading Setup Process
#   - publish via github classroom the assignment with the name "<assignment-name>"
#   - git clone the template assignment which ahs the name "<assignment-name>"
#   - cd "<assignment-name>"
#   - create an "assignment.env" file to override the defaults (optional)
#   - create the answers.md file
#   - create the rubric.grading file

# Assignment Grading Process
#   - cd "<assignment-name>"
#   - source grade_start
#   - reset_grading (optional)
#   - clone_submissions
#   - grade_submissions
#   - publish_grades
#   * recode the grades: "insert grades.<assignment>" into the master spreedsheet

# Assignment re-grading of single student process
#   - cd "<assignment-name>"
#   - source grade_start
#   - pull_submission "<account>"
#   - grade_submission "<account>"
#   - post_submission "<account>"
#   * recode the grades: "insert grades.<assignment>" into the master spreedsheet

#
#############################################################

GRADE_SCRIPT="${CLASSROOM_DIR}/grade.bash"  # This is the name of this particular script 
CLASSROOM_ENV="${CLASSROOM_DIR}/classroom.env"
ASSIGNMENT_ENV=${PWD}/default-assignment.env
source ${CLASSROOM_ENV}
source ${ASSIGNMENT_ENV}

# grade_start is presume to be executed within the top-level directory of a particular assignment
grade_start () {
  CLASSROOM_DIR="${PWD}/../"
  source ${GRADING_SCRIPT}
  [[ -f ${ASSIGNMENT_DIR}/assignment.env ]] && {
    ASSIGNMENT_ENV=${ASSIGNMENT_DIR}/assignment.env
    source ${ASSIGNMENT_ENV}
  } # If there is a per-assignment assignment.env allow that one to override the default
}

# Convention Related Files
CLASS_ROSTER=${CLASS_DIR}/roster                  # List of github usernames of each student
   # Modify the class roster to include: username <e.g. email address>
CLASS_GRADE_REPORT=${CLASS_DIR}/grades.${ASSIGNMENT_NAME}
SUBMISSION_DIR=${ASSIGNMENT_DIR}/submissions

# Assignment Based Files
ASSIGNMENT_FILE="assignment.md"                   # Contained within the student's repo
SUBMISSION_FILE="submission.md"                   # Contained within the student's repo
ANSWER_FILE=${ASSIGNMENT_DIR}/answers.md          # To be added to the student's repo
RUBRIC_FILE="${ASSIGNMENT_DIR}/rubric.grading"
STUDENT_GRADE_REPORT="grade.report"



# Define the name of the terminal for interactive input and output
terminal=$(tty)


# Grading Method: visual review of a .md file
#   - for each line in the rubric.grading file
#     - the prof is prompted for a score followed by an optional comment
#   - a grade report is created, with the total points tallied
#   - summary information is provided   
function grade_submission () {
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_PREFIX}-${1}

  (
    cd $_dir  
    rm -f ${STUDENT_GRADE_REPORT}

    grep ${ANSWER_TAG} "${STUDENT_ASSIGNMENT}" > ${STUDENT_ASSIGNMENT}.txt
    open -a ${GRADING_EDITOR} ${STUDENT_ASSIGNMENT} ${STUDENT_ASSIGNMENT}.txt

    _score=0
    # Add the grad.report prologue
    echo "Grading $_user" > $terminal
    { 
      echo '# Grading summary for ${ASSIGNMENT_NAME} Assignment'
      echo 
    }  >> ${STUDENT_GRADE_REPORT}
  
    # For each line in the rubric
    cat ${RUBRIC_FILE} | while read _line ; do
      echo $_line          > $terminal
      read _value _comment < $terminal
      printf "  $_value Points:\t\t$_line: $_comment\n"
      (( _score += _value ))
    done >> ${STUDENT_GRADE_REPORT}

    # Add the grade.report epilogue
    {
      echo "---"
      printf "$_score Points:\t\tTotal\n"
    } >> ${STUDENT_GRADE_REPORT}

    # Print out final score
    { echo ; 
      printf "$_user: $_score\n" ;
      echo ; 
    } > $terminal
    printf "$_user: $_score\n" >>${CLASS_GRADE_REPORT}
  )
}
function grade_submissions ()
  while read _user ; do
    grade_submission ${_user}
  done < ${CLASS_ROSTER}
}


function reset_grading () {
  [[ -f ${CLASS_GRADE_REPORT} ]] && 
      mv ${CLASS_GRADE_REPORT} ${CLASS_GRADE_REPORT}.$(date "+%Y:%m:%d:%H:%M")
  find ${SUBMISSION_DIR} -name ${STUDENT_GRADE_REPORT} -exec git rm -f {} \;
}


function clone_submission () {
   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_PREFIX}-${1}

   mkdir "$_dir"
   git -C ${_dir} clone ${REPO_PREFIX}/${ASSIGNMENT_PREFIX}-${_user}.git 
}
function clone_submissions () {
  while read _user ; do
    clone_submission ${_user}
  done < ${CLASS_ROSTER}
}  


function pull_submission () {
   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_PREFIX}-${1}/
   git -C ${_dir} pull
}
function pull_submissions () {
  while read _user ; do
    pull_submission $_user
  done < ${CLASS_ROSTER}
}  

function publish_grade () {
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_PREFIX}-${1}/

  if [[ -f {ANSWER_FILE } ]] {
    cp ${ANSWER_FILE} ${_dir}/.
    git -C ${_dir} add ${ANSWER_FILE}
    git -C ${_dir} commit -m 'Added Answers File' ${ANSWER_FILE}
  }
  git -C ${_dir} add ${STUDENT_GRADE_REPORT}
  git -C ${_dir} commit -m 'Added Student Grade Report' ${STUDENT_GRADE_REPORT}
  git -C ${_dir} push
}
function publish_grades () {
  while read _user  ; do
    public_grade $_user
  done < ${CLASS_ROSTER}
}  


