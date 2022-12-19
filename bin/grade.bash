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
#   - pull_submissions
#   - grade_submissions
#   - publish_grades
#   * record the grades: "insert grades.<assignment>.csv" into the master spreadsheet
#   - grades_log2csv: convert the log file into a .csv file for integration

# Assignment re-grading of single student process
#   - cd "<assignment-name>"
#   - source ../bin/grade.bash
#   - grade_start
#   - pull_submission "<account>"
#   - grade_submission "<account>" [ commit ]
#   - regrade_submission "<account>" [ commit ]
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

export ASSIGNMENT_GRADING_DIR=${CLASSROOM_DIR}/assignment-grading
export GRADING_SCRIPT="${ASSIGNMENT_GRADING_DIR}/bin/grade.bash"  # This is the name of this particular script 
export GRADING_ENV="${ASSIGNMENT_GRADING_DIR}/.grading.env"
export GIT_STATISTICS_BASH="${ASSIGNMENT_GRADING_DIR}/bin/git.statistics.bash"

source ${GRADING_ENV}


function cat_nocomment () {

  sed -e '/^ *#/d' "$@"
}


# grade_start must be called at the top-level directory of a particular assignment
# If not started then the error miessage is
# -bash: ${SUBMISSION_ROSTER}: ambiguous redirect

function grade_start () {

  # CLASSROOM_DIR="${PWD}/../.."
  # GRADING_SCRIPT="${CLASSROOM_DIR}/bin/grade.bash" 
  # source ${GRADING_SCRIPT}
  source ${GRADING_ENV}

  # By virtual of sourcing the GRADING_ENV, the ASSIGNMENT_DIR is defined
  # If there is a per-assignment grading.env file, override the class defaults
  if [[ -f "${ASSIGNMENT_DIR}/grading.env" ]] ; then
    ASSIGNMENT_ENV="${ASSIGNMENT_DIR}/grading.env"
    source ${ASSIGNMENT_ENV}
  fi

  GITHUB_PREFIX="git@github.com:${GITHUB_ORG}"
  STUDENT_BASE_URL=${GITHUB_PREFIX}/${ASSIGNMENT_NAME}
  CLASS_ROSTER="${ASSIGNMENT_GRADING_DIR}/roster"                  # Sorted List of github usernames of each student
  CLASS_MAKEFILE="${ASSIGNMENT_GRADING_DIR}/makefile"

  # Assignment Based Files
  LOCAL_GRADE_REPORT="${ASSIGNMENT_DIR}/grades.${ASSIGNMENT_NAME}.txt"
  CLASS_GRADE_REPORT="${ASSIGNMENT_GRADING_DIR}/grades.${ASSIGNMENT_NAME}.txt"
  SUBMISSION_DIR="${ASSIGNMENT_DIR}/submissions"
  ANSWER_FILE="${ASSIGNMENT_DIR}/key/answers.md"        # To be added to the student's repo
  RUBRIC_FILE="${ASSIGNMENT_DIR}/key/grading_rubric"    
  MAKEFILE="${ASSIGNMENT_DIR}/key/makefile"

  DUE_DATE_FILE=${ASSIGNMENT_DIR}/due.date
  GRADED_DATE_FILE=${ASSIGNMENT_DIR}/graded.date

  GRADING_LOG=${ASSIGNMENT_DIR}/grading.log
  SUBMISSION_ROSTER=${ASSIGNMENT_DIR}/roster.submissions
  NON_SUBMISSION_ROSTER=${ASSIGNMENT_DIR}/roster.non_submissions

  # Check for key files

  [[ ! -f ${RUBRIC_FILE} ]] && 
     { echo "Warning: Rubric File Not Found: \"${RUBRIC_FILE}\"" ;  }

  [[ ! -f ${DUE_DATE_FILE} ]] &&
     { echo "Warning: Due-date File Not Found: \"${DUE_DATE_FILE}\"" ; }

  echo "Starting the grading for:" ${ASSIGNMENT_NAME}
  { 
    echo
    echo "-------------------"
    echo "Starting the Grading Process:"
    echo "  Assignment:" ${ASSIGNMENT_NAME}
    echo "  Date:" $(date)
    echo
  } >> ${GRADING_LOG}

}

# Student Related Files
ASSIGNMENT_FILE="assignment.md"                   # Contained within the student's repo
SUBMISSION_FILE="submission.md"                   # Contained within the student's repo
STUDENT_ANSWER_KEY="answers.md"
STUDENT_GRADE_REPORT="grade.report"               # To be added to the student's repo
STUDENT_STAT_REPORT="statistics.report"           # To be added to the student's repo
STUDENT_GRADE_CHECKOUT="grade.checkout"           # The git commit line associated with the graded checkout
GRADED_TAG="graded"                               # Tag to identify version graded

# Define the name of the terminal for interactive input and output
terminal=$(tty)

# Grading Method: 
#   1. Paper Based:  visual review of a .md file
#   2. Code Based:  use of assignment-based makefile

#   - for each line in the grading_rubric file
#     - the prof is prompted for a score followed by an optional comment
#   - a grade report is created, with the total points tallied
#   - summary information is provided   
function regrade_submission () {
  _student=${1}
  _commit=${2}

  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}"
  ( 
    cd $_dir  
    mv ${CLASS_GRADE_REPORT} ${CLASS_GRADE_REPORT}.$(date "+%Y:%m:%d:%H:%M")
  )
  grade_submission "$_student" "$_commit"
}


function grade_submission () {
  _student=${1}
  _commit=${2}

  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}"

  (
    echo "--------------" > $terminal
    echo "Grading $_student" > $terminal
    echo "# $_grading_count" > $terminal
    (( _grading_count ++ ))
    if [[ ! -d $_dir ]] ; then
      printf "\tStudent did not accept assignment\n"
      printf "$_student: -1\n" >>${CLASS_GRADE_REPORT}
      return
    fi

    cd $_dir
    source "${GIT_STATISTICS_BASH}"

    # Checkout the version to be graded.  Either
    #  - they did not effectively submit something
    #  - they have a submission based upon due_date, etc
    #  - a specific commit hash was provided.
    git checkout ${ACCEPT_HASH}
    [[ -n "${SUBMISSION_HASH}" ]] && git checkout ${SUBMISSION_HASH}
    [[ -n "${_commit}" ]] && get checkout ${_commit}

    git tag -f ${GRADED_TAG}

    ## But if there is a MAKEFILE and NO submission file... then there is a problem.
    ## The problem is that the grade report
    ### it is presumed that if there is Makefile, it is NOT a paper report
    
    if [[ -f ${MAKEFILE} ]] ; then
       make -f ${MAKEFILE}
    else

      ##### PAPER SUBMISSION
      if [[ ! -f ${SUBMISSION_FILE} ]] ; then
        # Nothing Submitted

        printf "\t No submission for the user\n\n"
        printf "$_student: 0\n" >>${CLASS_GRADE_REPORT}
        { 
          echo "# Grading Report"
          echo "# Github Account: ${_student}"
          echo "# Assignment: \"${ASSIGNMENT_NAME}\""
          echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
          echo "# --- Submission date: \"${SUBMISSSION_DATE}\""
          echo "# --- Submission tag : \"${GRADED_TAG} (${SUBMISSION_HASH})\""
          echo 
          echo "Missing submission file: ${SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"0\""
        }  >> ${STUDENT_GRADE_REPORT}
        return
      fi

      diff ${SUBMISSION_FILE} ${ASSIGNMENT_FILE} >/dev/null 2>&1
      if (( $? == 0 )) ; then
        #  The Submission File is effectively Blank

        printf "\t ${SUBMISSION_FILE} is identical to ${ASSIGNMENT_FILE}\n"
        printf "$_student: 0\n" >>${CLASS_GRADE_REPORT}
        { 
          echo "# Grading Report"
          echo "# Github Account: ${_student}"
          echo "# Assignment: \"${ASSIGNMENT_NAME}\""
          echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
          echo "# --- Submission date: \"${SUBMISSSION_DATE}\""
          echo "# --- Submission tag : \"${GRADED_TAG} (${SUBMISSION_HASH})\""
          echo 
          echo "Submission file has not been updated: ${SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"0\""
        }  >> ${STUDENT_GRADE_REPORT} 
        return
      fi
      
      # Prep process the paper_grade.
      make -f ${CLASS_MAKEFILE} paper_grade
    fi
    # Note there is a return in the code block above.
    # Hence, flow might not get here


    # The following only performs the process to prompt the prof for scores related to the rubric
    # Prompt the Professor for the stuff required for the grading rubric
    rm -f ${STUDENT_GRADE_REPORT}
    _score=0
    # Add the grade.report prologue
    echo "Grading $_student" > $terminal
    { 
      echo "# Grading Report"
      echo "# Github Account: ${_student}"
      echo "# Assignment: \"${ASSIGNMENT_NAME}\""
      echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
      echo "# --- Submission date: \"${SUBMISSSION_DATE}\""
      echo "# --- Submission tag : \"${GRADED_TAG} (${SUBMISSION_HASH})\""
      echo

    }  >> ${STUDENT_GRADE_REPORT}
  
    # For each line in the rubric
    while read _line ; do
      echo $_line          > $terminal
      read _value _comment < $terminal
      printf "  %2d Points:\t\t$_line: $_comment\n" $_value
      (( _score += _value ))
    done < ${RUBRIC_FILE} >> ${STUDENT_GRADE_REPORT}

    # Add the grade.report epilogue
    {
      echo "---"
      printf "%3d Points:\t\tTotal\n" $_score
      echo
      echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\""
    } >> ${STUDENT_GRADE_REPORT}

    # Print out final score
    { echo ; 
      printf "$_student: $_score\n" ;
      echo ; 
    } > $terminal
    printf "$_student: $_score\n" >>${CLASS_GRADE_REPORT}
  )
}
function grade_submissions () {
  _grading_count=0
  touch ${CLASS_GRADE_REPORT}
  ln -s ${CLASS_GRADE_REPORT} ${LOCAL_GRADE_REPORT} 2>/dev/null

  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
    echo
  } >> ${CLASS_GRADE_REPORT}

  while read _student ; do
    grade_submission ${_student}
  done < ${SUBMISSION_ROSTER}

  {
    echo "# -------------------------------------"
    echo
  } >> ${CLASS_GRADE_REPORT}
}


function reset_grading () {
  [[ -f "${CLASS_GRADE_REPORT}" ]] && {
    mv ${CLASS_GRADE_REPORT} ${CLASS_GRADE_REPORT}.$(date "+%Y:%m:%d:%H:%M")
    mv ${SUBMISSION_ROSTER} ${SUBMISSION_ROSTER}.$(date "+%Y:%m:%d:%H:%M")
    mv ${NON_SUBMISSION_ROSTER} ${NON_SUBMISSION_ROSTER}.$(date "+%Y:%m:%d:%H:%M")
  }
  find ${SUBMISSION_DIR} -name ${STUDENT_GRADE_REPORT} -exec git rm -f {} \;
}


function clone_submission () {
   _student="${1}"

   if [[ -d ${ASSIGNMENT_NAME}-${_student} ]] ; then
      echo "Previously Cloned -- pulling: ${_student}"
      pull_submission $_student
   else 
     git clone ${STUDENT_BASE_URL}-${_student}.git >> ${GRADING_LOG} 2>/dev/null
     if [ $? == 0 ] ; then
        echo "Cloned: ${_student}"
        echo ${_student} >> ${SUBMISSION_ROSTER}
     else
        echo "Did Not Accept Assignment: ${_student}" 1>&2
        echo ${_student} >> ${NON_SUBMISSION_ROSTER}
     fi
   fi
   # Note that if there is no submission for a student,
   # Subsequent operations that create files are in error
}
function clone_submissions () {
  _dir="${SUBMISSION_DIR}"
  mkdir -p "$_dir"

  ( cd $_dir
    { 
      echo
      echo "-------------------"
      echo "Cloning Submissions:"
      echo "  Date:" $(date)
      echo
    } >> ${GRADING_LOG}

    while read _student ; do
      clone_submission ${_student}
    done < ${CLASS_ROSTER}
  )
}  


function pull_submission () {
   _student=${1}
   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/

   if [[ -d $_dir ]] ; then 
     git -C ${_dir} pull --no-edit >> ${GRADING_LOG} 2>&1
     if [ $? == 0 ] ; then
       echo "Pulled: ${_student}"
     else
       echo "Error Pulling: ${_student}"
     fi 
   fi
}
function pull_submissions () {
  { 
    echo "-------------------"
    echo "Pulling submissions: $(date)"
  } >> ${GRADING_LOG} 2>&1

  while read _student ; do
    pull_submission ${_student}
  done < ${SUBMISSION_ROSTER}
}  

function publish_grade () {
  _student=${1}
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}

  if [[ -d ${_dir} ]] ; then
    ( cd ${_dir} 
      git checkout main
      if [[ -f ${ANSWER_FILE} ]] ; then
        cp ${ANSWER_FILE} ${_dir}/.
        git add ${STUDENT_ANSWER_KEY}
        git commit -m 'Added Answers File' ${STUDENT_ANSWER_KEY}
      fi
      git add ${STUDENT_GRADE_REPORT} ${STUDENT_STATS_REPORT}
      git commit -m 'Added Student Grade and Stats Report' ${STUDENT_GRADE_REPORT} ${STUDENT_STATS_REPORT}
      git push --mirror
      return_value="$?"
      if [[ ${return_value} == 0 ]] ; then
        echo "Published (pushed): ${_student}" >$terminal
      else
        echo "Error Pushing: ${_student}"  >$terminal
      fi 
    ) >> ${GRADING_LOG} 2>&1
  fi
}
function publish_grades () {
  { 
    echo "-------------------"
    echo "Publishing grades: $(date)"
  } >> ${GRADING_LOG} 2>&1

  while read _student  ; do
    publish_grade ${_student}
  done < ${SUBMISSION_ROSTER}
}  


####
function grade_join () {
  _roster=$1
  _grades=$2

  while read _student ; do 
    grep $_student $_grades
    if [[ $? != 0 ]] ; then
      echo "$_student, , no grade"
    fi
  done < $_roster
}

# Designed to be rerun at the end of the semester
#  - it will remove anyone who has dropped
#  - it will add appropriate zero scores to folks that skipped an assignment
# Process a grade.*.log file
# removing comments
# removing blank lines
# convert  "student: grade" --> "student, grade"
# sort the resulting file
# if no dups, then join with class roster to ensure all have a recorded grade.
function grades2csv () {
   _file="$1"
     _base=$(basename -s .txt $_file )
     sed -e  '/^#/d' -e '/^ *$/d' -e 's/:/,/g' $_file | sort -u -f  > $_base.prep
     awk '{ print $1}' $_base.prep | sort -u -f --check=quiet >/dev/null
     if [[ $? != 0 ]] ; then
       echo "$_file: Multiple grades for some students" 1>&2
     else
       #  The "join" utility seems to be broken on MacOS
       #  The "join" on RedHat does not allow hypens in the key 
       grade_join ${CLASS_ROSTER} $_base.prep >$_base.csv
     fi
     #rm $_base.prep
}



function all_grades2csv () {
  while read _file ; do
     grades2csv $_file
  done 
}


## Following is now defunct due to timelime due.date information

function checkout_date () {
  _date=${1}
  _student=${2}

  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
  (
    cd $_dir
    { 
      _hash=$(git rev-list -1 --until="${_date}" main)
      echo "Grade as of Date: ${_date}"
      echo
      git checkout ${_hash}  2>&1
      echo                              
      git log --decorate=full -1 $_hash 
    } > ${STUDENT_GRADE_CHECKOUT}
  )
}


## Following is now defunct due to timelime due.date information
function checkout_due_date () {
  _date=${1}
  [[ -z ${_date} ]] && [[ -f due.date ]] && _date="$(cat_nocomment due.date)"

  [[ -z ${_date} ]] && return
  
  { 
    echo "-------------------"
    echo "Checking out Version based upon date: ${_date}"
  } >> ${GRADING_LOG} 2>&1

  while read _student ; do
    checkout_date "${_date}" ${_student} 
  done < ${SUBMISSION_ROSTER}
}  



function apply_all () {
  CMD="$*"
  { 
    echo
    echo "-------------------"
    echo "Apply the following command within each Student Repo"
    echo "  Command:" $CMD
    echo
  } >> ${GRADING_LOG}

  while read _student  ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    (
      cd ${_dir}
      basename $(pwd)
      eval $CMD
    ) 
  done < ${SUBMISSION_ROSTER}
} 

