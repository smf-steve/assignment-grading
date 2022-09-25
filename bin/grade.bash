#! /bin/bash

# This script files defines a number of functions to facilitate
# the grading of student assignments submitted via GitHub Classroom.

# These assignments are presumed to be paper-like assignments within a text file.
# Hence, a visual review of each SUBMISSION_FILE is needed.  It is also presumed that
# each line that contains an answer includes the RESPONSE_TAG that allows for
# the collection of just the answers via a simple 'grep' of the SUBMISSION_FILE.

# The appropriate file is opened for visual review, and then, via the CLI, the professor is 
# prompted for a score for each individual element in the scoring guide (rubric)


################################################################################################
# Processes:
#
#   Prerequisites:  (See the process.md file)
#     - create a assignment template repository
#     - create a assignment solution repository
#
#   Setup Processes
#   - cd ${CLASSROOM_DIR}/assignment_grading
#   - make a directory for the assignment :  cd nn-assignment-name
#   - clone the assignment-solution repository into the ``key`` directory
#
#   Grading Process
#   - source ../bin/grade.bash ${CLASSROOM_DIR}
#   - cd assignment_grading/"<nn-assignment-name>"
#   - grade_start
#   - reset_grading (optional)
#   - clone_submissions
#   - pull_submssions
#   - grade_submissions
#   - publish_grades
#   * record the grades: "insert grades.<assignment>" into the master spreadsheet

# Assignment re-grading of single student process
#   - cd "<assignment-name>"
#   - source ../grade_start ..
#   - grade_start
#   - pull_submission "<account>"
#   - grade_submission "<account>"
#   - publish_grades "<account>"
#   * update the individual grade within the master spreadsheet
#
#############################################################

## Usage: 
##    source $path/bin/grade.bash CLASSROOM_DIR
##      - CLASSROOM_DIR is set as defined
##    source $path/bin/grade.bash
##      - If CLASSROOM_DIR is unset, then set it to $cwd/../..
##      - I.e., it assumed that the script was invoked in:
##        ${CLASSROOM_DIR}/assignment_grading/nn-assignment-name

# Normalize the file path
if [[ -n $1 ]] ; then
  [[ -d $1 ]] && CLASSROOM_DIR=$( cd $1 ; pwd )
fi
[[ -z ${CLASSROOM_DIR} ]] && CLASSROOM_DIR=$( cd ../.. ; pwd )

ASSIGNMENT_GRADING_DIR=${CLASSROOM_DIR}/assignment-grading
GRADING_SCRIPT="${ASSIGNMENT_GRADING_DIR}/bin/grade.bash"  # This is the name of this particular script 
GRADING_ENV="${ASSIGNMENT_GRADING_DIR}/.grading.env"
source ${GRADING_ENV}

# grade_start must be called at the top-level directory of a particular assignment
function grade_start () {
  # CLASSROOM_DIR="${PWD}/../.."
  # GRADING_SCRIPT="${CLASSROOM_DIR}/bin/grade.bash" 
  # source ${GRADING_SCRIPT}
  source ${GRADING_ENV}

  # By virtual of sourcing the GRADING_ENV, the ASSIGNMENT_DIR is defined
  echo "Starting the grading for:" ${ASSIGNMENT_NAME}
  # If there is a per-assignment grading.env file, override the class defaults
  if [[ -f "${ASSIGNMENT_DIR}/grading.env" ]] ; then
    ASSIGNMENT_ENV="${ASSIGNMENT_DIR}/grading.env"
    source ${ASSIGNMENT_ENV}
  fi

  GITHUB_PREFIX="git@github.com:${GITHUB_ORG}"
  STUDENT_BASE_URL=${GITHUB_PREFIX}/${ASSIGNMENT_NAME}
  CLASS_ROSTER="${ASSIGNMENT_GRADING_DIR}/roster"                  # List of github usernames of each student
  CLASS_MAKEFILE="${ASSIGNMENT_GRADING_DIR}/makefile"

  # Assignment Based Files
  LOCAL_GRADE_REPORT="${ASSIGNMENT_DIR}/grades.${ASSIGNMENT_NAME}"
  CLASS_GRADE_REPORT="${ASSIGNMENT_GRADING_DIR}/grades.${ASSIGNMENT_NAME}"
  SUBMISSION_DIR="${ASSIGNMENT_DIR}/submissions"
  ANSWER_FILE="${ASSIGNMENT_DIR}/key/answers.md"        # To be added to the student's repo
  RUBRIC_FILE="${ASSIGNMENT_DIR}/key/grading_rubric"    
  MAKEFILE="${ASSIGNMENT_DIR}/key/makefile"

  SUBMISSION_LOG=${ASSIGNMENT_DIR}/grading.log
  SUBMISSION_ROSTER=${ASSIGNMENT_DIR}/roster.submissions
  NON_SUBMISSION_ROSTER=${ASSIGNMENT_DIR}/roster.non_submissions
}

# Student Related Files
ASSIGNMENT_FILE="assignment.md"                   # Contained within the student's repo
SUBMISSION_FILE="submission.md"                   # Contained within the student's repo
STUDENT_ANSWER_KEY="answers.md"
STUDENT_GRADE_REPORT="grade.report"               # To be added to the student's repo


# Define the name of the terminal for interactive input and output
terminal=$(tty)

# Grading Method: 
#   1. Paper Based:  visual review of a .md file
#   2. Code Based:  use of assignment-based makefile

#   - for each line in the grading_rubric file
#     - the prof is prompted for a score followed by an optional comment
#   - a grade report is created, with the total points tallied
#   - summary information is provided   
function grade_submission () {
  _user=${1}
  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_user}"

  if [[ ! -f ${RUBRIC_FILE} ]] ; then
     echo "Rubric File Not Found: \"${RUBRIC_FILE}\""
     return 1
  fi
  (
    echo "--------------" > $terminal
    echo "Grading $_user" > $terminal
    if [[ ! -d $_dir ]] ; then
      echo "No submission for the user"
      printf "$_user: 0\n" >>${CLASS_GRADE_REPORT}
      return
    fi

    cd $_dir
    if [[ -f ${MAKEFILE} ]] ; then
       make -f ${MAKEFILE}
    else
       if [[ ! -f ${SUBMISSION_FILE} ]] ; then
         echo "No submission for the user"
         printf "$_user: 0\n" >>${CLASS_GRADE_REPORT}
         return
       else
         make -f ${CLASS_MAKEFILE} paper_grade
       fi
    fi

    # Prompt the Professor for the stuff required for the grading rubric
    rm -f ${STUDENT_GRADE_REPORT}
    _score=0
    # Add the grad.report prologue
    echo "Grading $_user" > $terminal
    { 
      echo "# Grading summary for \"${ASSIGNMENT_NAME}\" assignment"
      echo 
    }  >> ${STUDENT_GRADE_REPORT}
  
    # For each line in the rubric
    while read _line ; do
      echo $_line          > $terminal
      read _value _comment < $terminal
      printf "  $_value Points:\t\t$_line: $_comment\n"
      (( _score += _value ))
    done < ${RUBRIC_FILE} >> ${STUDENT_GRADE_REPORT}

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
function grade_submissions () {
  touch ${CLASS_GRADE_REPORT}
  ln -s ${CLASS_GRADE_REPORT} ${LOCAL_GRADE_REPORT} 
  while read _user ; do
    grade_submission ${_user}
  done < ${SUBMISSION_ROSTER}
}


function reset_grading () {
  [[ -f "${CLASS_GRADE_REPORT}" ]] && 
    mv ${CLASS_GRADE_REPORT} ${CLASS_GRADE_REPORT}.$(date "+%Y:%m:%d:%H:%M")
  find ${SUBMISSION_DIR} -name ${STUDENT_GRADE_REPORT} -exec git rm -f {} \;
}


function clone_submission () {
   _dir="${SUBMISSION_DIR}"
   _student="${1}"

   mkdir -p "$_dir"
   git -C ${_dir} clone ${STUDENT_BASE_URL}-${_student}.git >> ${SUBMISSION_LOG} 2>&1
   if [ $? == 0 ] ; then
      echo "Cloned: ${_student}"
      echo ${_student} >> ${SUBMISSION_ROSTER}
   else
      echo "No Submission: ${_student}" 1>&2
      echo ${_student} >> ${NON_SUBMISSION_ROSTER}
   fi
   # Note that if there is no submission for a student,
   # Subsequent operations that create files are in error
}
function clone_submissions () {
  while read _user ; do
    clone_submission ${_user}
  done < ${CLASS_ROSTER}
}  


function pull_submission () {
   _student=${1}
   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/

   if [[ -d $_dir ]] ; then 
     git -C ${_dir} pull >> ${SUBMISSION_LOG} 2>&1
     if [ $? == 0 ] ; then
       echo "Pulled: ${_student}"
     else
       echo "Error Pulling: ${_student}" 1>&2
     fi 
   fi
}
function pull_submissions () {
  while read _user ; do
    pull_submission $_user
  done < ${SUBMISSION_ROSTER}
}  

function publish_grade () {
  _student=${1}
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/

  if [[ -d ${_dir} ]] ; then
    if [[ -f ${ANSWER_FILE} ]] ; then
      {
        cp ${ANSWER_FILE} ${_dir}/.
        git -C ${_dir} add ${STUDENT_ANSWER_KEY}
        git -C ${_dir} commit -m 'Added Answers File' ${STUDENT_ANSWER_KEY}
      } >> ${SUBMISSION_LOG} 2>&1
    fi
    {
      git -C ${_dir} add ${STUDENT_GRADE_REPORT}
      git -C ${_dir} commit -m 'Added Student Grade Report' ${STUDENT_GRADE_REPORT}
    } >> ${SUBMISSION_LOG} 2>&1

    git -C ${_dir} push >> ${SUBMISSION_LOG} 2>&1
    if [ $? == 0 ] ; then
       echo "Published: ${_student}"
    else
       echo "Error Pushing: ${_student}" 1>&2
    fi 
  fi
}
function publish_grades () {
  while read _user  ; do
    publish_grade $_user
  done < ${SUBMISSION_ROSTER}
}  

function update_all () {
  CMD="$*"
  while read _student  ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    pushd ${_dir} 2>/dev/null
    eval $CMD
    popd 2>/dev/null
  done < ${SUBMISSION_ROSTER}
} 

