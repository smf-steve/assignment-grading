#! /bin/bash

# This script files defines a number of functions to facilitate
# the grading of student assignments submitted via GitHub Classroom.

# These assignments are presumed to include paper-like assignments within a text file.
# Hence, a visual review of each STUDENT_SUBMISSION_FILE is needed.  It is also presumed that
# each line that contains an answer includes the RESPONSE_TAG that allows for
# the collection of just the answers via a simple 'grep' of the STUDENT_SUBMISSION_FILE.

# The appropriate file is opened for visual review, and then, via the CLI, the 
# professor is prompted for a score for each individual element within a defined 
# scoring guide (rubric).

# Alternatively, a makefile can be provided to test the student submission.
# After the makefile is executied, the provessor is prompted for a score for each 
# individual element within a defined scoring guide (rubric).


################################################################################################
# Process:
#
#   Prerequisites:  (See the process.md file)
#     mkdir $HOME/bin
#     cp grade.bash git.statistics.bash $HOME/bash
#     Add the following line to (e.g.,) $HOME/.profile
#       - bin/grade.bash
#     For each class:
#       - create a github classroom
#       - cd to the parent directory for the classroom
#       - run the command `create_assignments_dir <classroom>` 
#     For each assignment
#       - create an assignment template repository
#       - create an assignment solution repository
#       - cd to the classroom assignment_grading directory:
#       - run the command `create_assignment <classroom> <assignment>` 
#
#
#   Setup Processes
#   #- cd ${CLASSROOM_DIR}/assignment_grading
#   #- make a directory for the assignment :  cd nn-assignment-name
#   - clone the assignment-solution repository into the ``key`` directory
#
#   Grading Process
#   #- source ../bin/grade.bash ${CLASSROOM_DIR}
#   - create_assignment "<nn-assignment-name>"
#   - cd <nn-assignment-name>
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
#   - grade_start
#   - pull_submission "<account>"
#   - grade_submission "<account>" [ commit ]
#   - regrade_submission "<account>" [ commit ]
#   - publish_grades "<account>"
#   * update the individual grade within the master spreadsheet
#
#############################################################
export GRADING_SCRIPT="${HOME}/bin/grade.bash"  # This is the name of this particular script 
export GIT_STATISTICS_BASH="${HOME}/bin/git.statistics.bash"


## Usage: 
##    source $path/bin/grade.bash CLASSROOM_DIR
##      - CLASSROOM_DIR is set as defined
##    source $path/bin/grade.bash
##      - If CLASSROOM_DIR is unset, then set it to $cwd/../..
##      - I.e., it assumed that the script was invoked in:
##        ${CLASSROOM_DIR}/assignment_grading/nn-assignment-name

# Normalize the file path
# if [[ -n $1 ]] ; then
#   [[ -d $1 ]] && CLASSROOM_DIR=$( cd $1 ; pwd )
# fi
# [[ -z ${CLASSROOM_DIR} ]] && CLASSROOM_DIR=$( cd ../.. ; pwd )
# 



# This function creates a template .env file for the assignment-grading process.
# The template .env file is used to create individual assignment .env
#   - to make a global change for all assignment-grading process
#     - modify either this function, or the resulting .env
#   - to make a local change for just one assignment, modify the assignment.env
#     within the individul assignment director
function create_grading_env () {
  CLASSROOM="${1}"
  cat <<EOF

##################################
## GLOBAL ENV VARIABLES for the Assignment-Grading system

export GITHUB_CLASSROOM="${GITHUB_CLASSROOM}"
export GITHUB_PREFIX="git@github.com:\${GITHUB_CLASSROOM}"

export ASSIGNMENT_GRADING_DIR="${ASSIGNMENT_GRADING_DIR}"
export GRADING_ENV="${GRADING_ENV}"

LAUNCH_COMMAND="open -a"       # MacOS
# LAUNCH_COMMAND="start"       # WINDOWS 10

export GITHUB_ROSTER="\${ASSIGNMENT_GRADING_DIR}/classroom_roster.csv"
export CLASS_ROSTER="\${ASSIGNMENT_GRADING_DIR}/roster"                  
  # Sorted List of github usernames of each student

export CLASS_MAKEFILE="\${ASSIGNMENT_GRADING_DIR}/makefile"
export CLASS_GRADE_REPORT="\${ASSIGNMENT_GRADING_DIR}/grades.\${ASSIGNMENT_NAME}.txt"



##################################
## RELATIVE ENV VARIABLES
# Student Related Files

STUDENT_ASSIGNMENT_FILE="assignment.md"           # Contained within the student's repo
STUDENT_SUBMISSION_FILE="submission.md"           # Contained within the student's repo

STUDENT_ANSWER_KEY="answers.md"                   # To be added to the student's repo
STUDENT_GRADE_REPORT="grade.report"               # To be added to the student's repo
STUDENT_STAT_REPORT="statistics.report"           # To be added to the student's repo
STUDENT_GRADE_CHECKOUT="grade.checkout"           # The git commit line associated with the graded checkout


## GRADING RELATED VARIABLES
GRADED_TAG="graded"                               # Tag to identify version graded
GRADING_BRANCH="grading"

GRADING_EDITOR="subl"
#GRADING_EDITOR="${LAUNCH_COMMAND} /Applications/Sublime Text.app"

RESPONSE_TAG='<!-- response -->'
  # The standardize tag to "grep" for within the student's submission to locate just the responses to review


EOF

}



function create_assignment_env () {

cat ${GRADING_ENV} 
cat  <<EOF

##################################
## ASSIGNMENT BASED ENV VARIABLES
  # The name of the template repository must match the name of the assignment
  # The name of the assignment must match the name of the directory
export ASSIGNMENT_DIR="\${PWD}"       
export ASSIGNMENT_NAME="\$(basename \$PWD)"
export ASSIGNMENT_ID=\$( sed 's/^\(..\).*$/\1/' <<< \${ASSIGNMENT_NAME})


# Assignment Specific Information
########################################################
RELEASE_DATE_FILE="\${ASSIGNMENT_DIR}/release_date"
DUE_DATE_FILE="\${ASSIGNMENT_DIR}/due_date"
TIME_LIMIT_FILE="\${ASSIGNMENT_DIR}/time_limit"
GRACE_PERIOD_FILE="\${ASSIGNMENT_DIR}/grace_period"

# The following environment variables need to be set somewhere
  STUDENT_BASE_URL=\${GITHUB_PREFIX}/\${ASSIGNMENT_NAME}

  # Assignment Based Files
  LOCAL_GRADE_REPORT="\${ASSIGNMENT_DIR}/grades.\${ASSIGNMENT_NAME}.txt"
  SUBMISSION_DIR="\${ASSIGNMENT_DIR}/submissions"
  
  KEY_DIR="\${ASSIGNMENT_DIR}/key"
  KEY_ANSWER_FILE="\${KEY_DIR}/answers.md"        # To be added to the student's repo
  KEY_RUBRIC_FILE="\${KEY_DIR}/grading_rubric"    
  KEY_MAKEFILE="\${KEY_DIR}/makefile"

  ASSIGNMENT_MAKEFILE="\${ASSIGNMENT_DIR}/makefile"     # Should the be such a thing

  GRADED_DATE_FILE=\${ASSIGNMENT_DIR}/graded.date

  GRADING_LOG=\${ASSIGNMENT_DIR}/grading.log
  SUBMISSION_ROSTER=\${ASSIGNMENT_DIR}/roster.submissions
  NON_SUBMISSION_ROSTER=\${ASSIGNMENT_DIR}/roster.non_submissions

EOF

}

# Process..
# - cd to the assignment-grading directory
# - execute the command `create_assignment assignment_dir`
# 
function create_grading_dir () {
  GITHUB_CLASSROOM=${1}
  ASSIGNMENT_GRADING_DIR="${PWD}/assignment-grading"
  GRADING_ENV=${ASSIGNMENT_GRADING_DIR}/grading.env

  if [[ -z ${GITHUB_CLASSROOM} ]] ; then 
    echo "Usage:"
    echo "   cd <class directory>" 
    echo "   create_assignments_dir github_classroom"
    echo "     where github_classroom is the GITHUB Tag for the classroom"
    return 1;
  fi

  if [[ -e "${ASSIGNMENT_GRADING_DIR}" ]] ; then
    echo "\"Assignment Grading\" directory already exists"
    return 2;
  fi

  mkdir ${ASSIGNMENT_GRADING_DIR}
  create_grading_env ${GITHUB_CLASSROOM} > ${GRADING_ENV}
}

# This function presumes that you location is
#  $HOME/.../<class>/assignment-grading/.
function create_assignment () {
  ASSIGNMENT_DIR="${1}"
  ASSIGNMENT_GRADING_DIR="${PWD}"
  
  if [[ "assignment-grading" != "$(basename ${PWD})" ]] ; then
    echo "Usage:"
    echo "   cd <assignment grading directory>"
    echo "   create_assignment  xx-assignment-name"
    echo "     where xx-assignment is the GITHUB name for the assignment"
    return 1;
  fi

  if [[ -z "${ASSIGNMENT_DIR}" ]] ; then 
    echo "Usage:"
    echo "   cd <assignment grading directory>"
    echo "   create_assignment  xx-assignment-name"
    echo "     where xx-assignment is the GITHUB name for the assignment"
    return 1;
  fi

  if [[ -e "${ASSIGNMENT_DIR}" ]] ; then
    echo "Assignment Directory already exists"
    return 2;
  fi

  # Where does the following file come from
  # What is in the file

  mkdir ${ASSIGNMENT_DIR}
  ASSIGNMENT_ENV="assignment.env"
  create_assignment_env > ${ASSIGNMENT_DIR}/${ASSIGNMENT_ENV}
    {
      cd ${ASSIGNMENT_DIR};
      source ${ASSIGNMENT_ENV}  # source the default environment file
      cd ..
    }

  mkdir ${KEY_DIR}
  mkdir ${SUBMISSION_DIR}
  touch ${LOCAL_GRADE_REPORT}
  ln -s ${CLASS_GRADE_REPORT} ${LOCAL_GRADE_REPORT} 2>/dev/null
  touch ${RELEASE_DATE_FILE}
  touch ${DUE_DATE_FILE}
  touch ${TIME_LIMIT_FILE}
  touch ${GRACE_PERIOD_FILE}
  touch ${ASSIGNMENT_MAKEFILE}
}


# The following function is called by all subsequent functions to ensure
# environment variables are consistent with our current grading location
function grade_start () {

  # 1. check our that we are in the correct location
  # 2. check our environment location
  # 3. if different, then resource the correct enviornment

  if [[ "${PWD}" != "${ASSIGNMENT_DIR}" ]] ; then
    if [[ ! -f "${ASSIGNMENT_ENV}" ]] ; then
      echo "Usage:  cd <assignment_dir> ; grade_start"
      return 1
    fi
    source ${ASSIGNMENT_ENV}
    terminal=$(tty)
  fi

  # Rerun these commands, in case of any updates after the initial `grade_start` is executed
  RELEASE_DATE="Not Defined"
  ACCEPT_DATE="Not Defined"
  DUE_DATE="Not Defined"
  TIME_LIMIT=
  GRACE_PERIOD=
  [[ -s "${RELEASE_DATE_FILE}" ]] && RELEASE_DATE="$(cat_nocomment RELEASE_DATE_FILE})"
  [[ -s "${DUE_DATE_FILE}" ]]     && DUE_DATE="$(cat_nocomment ${DUE_DATE_FILE})"
  [[ -s "${GRACE_PERIOD_FILE}" ]] && GRACE_PERIOD="$(cat_nocomment ${GRACE_PERIOD_FILE})" 
  [[ -s "${TIME_LIMIT_FILE}" ]]   && TIME_LIMIT_FILE="$(cat_nocomment ${TIME_LIMIT_FILE})" 

  echo "Starting the grading for:" ${ASSIGNMENT_NAME}
  [[ -n ${RELEASE_DATE} ]] && echo "Release Date: ${RELEASE_DATE}"
  [[ -n ${DUE_DATE} ]]     && echo "Due Date: ${DUE_DATE}"
  [[ -n ${TIME_LIMIT} ]]   && echo "Time Limit: ${TIME_LIMIT}"
  [[ -n ${GRACE_PERIOD} ]] && echo "Grace Period: ${GRACE_PERIOD})"

  # Check for key files
  [[ ! -f ${KEY_RUBRIC_FILE} ]] && {
     _l=$(sed "s|${ASSIGNMENT_GRADING_DIR}/||" <<< ${KEY_RUBRIC_FILE} )
     echo 
     echo "Warning: Rubric File Not Found: \"${_l}\"" ;  
  }

}




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

  {
    echo "# Regrade: ${ASSIGNMENT_NAME} $(date)"
  } >> ${CLASS_GRADE_REPORT}

  grade_submission "$_student" "$_commit"
}


function grade_submission () {
  _student=${1}
  _commit=${2}

  source ${ASSIGNMENT_ENV}

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

    git branch ${GRADED}

    ## But if there is a KEY_MAKEFILE and NO submission file... then there is a problem.
    ## The problem is that the grade report
    ### it is presumed that if there is KEY_MAKEFILE, it is NOT a paper report
    
    if [[ -f ${KEY_MAKEFILE} ]] ; then
       make -f ${KEY_MAKEFILE}
    else

      ##### PAPER SUBMISSION
      if [[ ! -f ${STUDENT_SUBMISSION_FILE} ]] ; then
        # Nothing Submitted

        printf "\t No submission for the user\n\n"
        printf "$_student: 0\n" >>${CLASS_GRADE_REPORT}
        { 
          echo "# Grading Report"
          echo "# Github Account: ${_student}"
          echo "# Assignment: \"${ASSIGNMENT_NAME}\""
          echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
          echo "# --- Submission date: \"${SUBMISSSION_DATE}\""
          echo "# --- Submission tag : \"${GRADED_TAG}.start (${SUBMISSION_HASH})\""
          echo 
          echo "Missing submission file: ${STUDENT_SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"0\""
        }  >> ${STUDENT_GRADE_REPORT}
        return
      fi

      diff ${STUDENT_SUBMISSION_FILE} ${STUDENT_ASSIGNMENT_FILE} >/dev/null 2>&1
      if (( $? == 0 )) ; then
        #  The Submission File is effectively Blank

        printf "\t ${STUDENT_SUBMISSION_FILE} is identical to ${STUDENT_ASSIGNMENT_FILE}\n"
        printf "$_student: 0\n" >>${CLASS_GRADE_REPORT}
        { 
          echo "# Grading Report"
          echo "# Github Account: ${_student}"
          echo "# Assignment: \"${ASSIGNMENT_NAME}\""
          echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
          echo "# --- Submission date: \"${SUBMISSSION_DATE}\""
          echo "# --- Submission tag : \"${GRADED_TAG}.start (${SUBMISSION_HASH})\""
          echo 
          echo "Submission file has not been updated: ${STUDENT_SUBMISSION_FILE}"
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
      echo "# --- Submission tag : \"${GRADED_TAG}.start (${SUBMISSION_HASH})\""
      echo

    }  >> ${STUDENT_GRADE_REPORT}
  
    # For each line in the rubric
    while read _line ; do
      echo $_line          > $terminal
      read _value _comment < $terminal
      printf "  %2d Points:\t\t$_line: $_comment\n" $_value
      (( _score += _value ))
    done < ${KEY_RUBRIC_FILE} >> ${STUDENT_GRADE_REPORT}

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
      if [[ -f ${KEY_ANSWER_FILE} ]] ; then
        cp ${KEY_ANSWER_FILE} ${_dir}/.
        git add ${STUDENT_ANSWER_KEY}
        git commit -m 'Added Answers File' ${STUDENT_ANSWER_KEY}
      fi
      git add ${STUDENT_GRADE_REPORT} ${STUDENT_STATS_REPORT}
      git commit -m 'Added Student Grade and Stats Report' ${STUDENT_GRADE_REPORT} ${STUDENT_STATS_REPORT}
      git checkout main
      git pull
      git merge ${GRADE_TAG}
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


function cat_nocomment () {

  sed -e '/^ *#/d' "$@"
}
