#! /bin/bash

# This script files defines a number of functions to facilitate
# the grading of student assignments submitted via GitHub Classroom.

# These assignments are presumed to include paper-like assignments within a text file.
# Hence, a visual review of each STUDENT_SUBMISSION_FILE is needed.  It is also presumed that
# each line that contains an answer also includes the RESPONSE_TAG that allows for
# the collection of just the answers via a simple 'grep' of the STUDENT_SUBMISSION_FILE.

# The appropriate file is opened for visual review, and then, via the CLI, the 
# professor is prompted for a score for each individual element within a defined 
# scoring guide (rubric).

# Alternatively, a makefile can be provided to test the student submission.
# After the makefile is executed, the professor is prompted for a score for each 
# individual element within a defined scoring guide (rubric).


################################################################################################
# Process:
#
#   Prerequisites:  (See the process.md file)
#     - mkdir $HOME/bin
#     - cp grade.bash git.statistics.bash $HOME/bin
#     - Add the following line to (e.g.,) $HOME/.profile
#       * source $HOME/bin/grade.bash
#
#   For each class:
#     - create a github classroom
#     - create a directory for the class
#     - cd to the class directory
#     - run the command `create_grading_dir <github classroom>` 
#
#   For each assignment
#     - create a template repository containing the Professors version of an assignment
#         This version may contain the answer key, grading rubric, etc.
#         Recommend that this version:  github.com:${PROF}/ASSIGNMENT_NAME
#     - create a template repository assignment template repository
#         This version don't not contain grading information
#         Recommend that this version:  github.com:${CLASS}/ASSIGNMENT_NAME
#     - cd to the classroom assignment_grading directory:
#     - run the command `create_assignment <xx-assignment>` 
#
#       Repository Names:
#          Prof:      ${PROF}/assignment    (No XX because assignment might be used in future)
#          Class:     ${CLASS}/xx-assignment
#          Student:   ${CLASS}/xx-assignment-${student}
#
#   To initiate the grading of an assignment
#     - cd <xx-assignment>
#     - grade_start
#
#   To perform various grading steps
#     - reset_grading       [ | file | args... ]
#     - clone_submissions   [ | file | args... ]
#     - pull_submissions    [ | file | args... ]
#     - grade_submissions   [ | file | args... ]
#     - regrade_submissions [ | file | args... ]
#     - commit_grades       [ | file | args... ]
#     - publish_grades      [ | file | args... ]
#          - zero args: operate on all students in the class_roster
#          - one arg that is a file: operate on each students enumerated in the file
#          - one or more args:  operate on each argument
#
#     - recreate_class_grade_report
#
#   For re/grade a single student
#     - cd "<xx-assignment>"
#     - grade_start
#     - pull_submissions "<account>"
#     - grade_submission "<account>" [ commit | -- ]
#     - regrade_submission "<account>" [ commit | -- ]
#     - publish_grades "<account>"
#
#   Aux commands, meant to be called internally
#     - ag_show_commit_log 
#
#   For grade incorporation
#     - review/update the grades in grades.<xx-assignment>.txt, e.g., regrades
#     - cd <assignment-grading> grades_log2csv 
#       - convert the log file into a .csv file for integration
#     * record the grades: "insert grades.<assignment>.csv" into the master spreadsheet
#############################################################

ASSIGNMENT_GRADING_BASENAME="assignment-grading"
ASSIGNMENT_ENV="assignment.env"
export GRADING_SCRIPT="${HOME}/bin/grade.bash"  # This is the name of this particular script 
export GIT_STATISTICS_BASH="${HOME}/bin/git.statistics.bash"


#############################################################
# The next two functions create the grading.env and assignment.env files.
# These files assign all the relative defaults for each assignment.
#
# To make global changes to these defaults,
#   - update the "here-documents" within these functions.
#
# To make local changes to these defaults,
#   - update the special "grading.env" and/or "assignment.env"
#############################################################

function create_grading_env () {
  GITHUB_CLASSROOM="${1}"

  if [[ -z "${GITHUB_CLASSROOM}" ]] ; then 
    echo "Usage:"
    echo "    create_grading_env <github classroom>"
    echo ""
    return 1
  fi

  if [[ -z "${ASSIGNMENT_GRADING_DIR}" || -z "${GRADING_ENV}" ]] ; then
    echo "Error: Key environments are not set"
    return 2
  fi

  cat <<EOF

##################################
## GLOBAL ENV VARIABLES for the Assignment-Grading system
export GITHUB_PROF_NAME="\$(git config --get user.name)"
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

STUDENT_ACTIVITY_REPORT="activity.report"         # IF a call is made to checkout_date, this file contains the git log before this date
                                                  # Otherwise the file is empty

## GRADING RELATED VARIABLES
SUBMISSION_TAG="submission"                       # Tag to identify the start of the grading branch
GRADED_TAG="graded"                               # Tag to identify version graded
GRADING_BRANCH="grading"

GRADING_EDITOR="subl"
#GRADING_EDITOR="\${LAUNCH_COMMAND} /Applications/Sublime Text.app"

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

  STUDENT_BASE_URL=\${GITHUB_PREFIX}/\${ASSIGNMENT_NAME}

  # Assignment Based Files
  LOCAL_GRADE_REPORT="\${ASSIGNMENT_DIR}/grades.txt"
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
# - execute the command `create_grading_dir  GITHUB_classroom`
# 
function create_grading_dir () {
  GITHUB_CLASSROOM=${1}
  ASSIGNMENT_GRADING_DIR="${PWD}/${ASSIGNMENT_GRADING_BASENAME}"
  GRADING_ENV=${ASSIGNMENT_GRADING_DIR}/grading.env

  if [[ -z ${GITHUB_CLASSROOM} ]] ; then 
    echo "Usage:"
    echo "   cd <class directory>" 
    echo "   create_grading_dir github_classroom"
    echo "     where github_classroom is the GITHUB Tag for the classroom"
    return 1;
  fi

  if [[ -e "${ASSIGNMENT_GRADING_DIR}" ]] ; then
    echo "\"Assignment Grading\" directory already exists"
    return 2;
  fi

  mkdir ${ASSIGNMENT_GRADING_DIR}
  create_grading_env ${GITHUB_CLASSROOM} > ${GRADING_ENV}
  ( cd ${ASSIGNMENT_GRADING_DIR} ; create_assignment xx-sample-assignment )
}

# This function presumes that you location is
#  $HOME/.../<class>/assignment-grading/.
function create_assignment () {
  if [[ -z "${1}" ]] ; then 
    echo "Usage: create_assignment xx-assignment-name"
    echo "   cd <${ASSIGNMENT_GRADING_BASENAME}>"
    echo "   create_assignment xx-assignment-name"
    echo "     where xx-assignment is the GITHUB name for the assignment"
    return 1;
  fi

  ASSIGNMENT_NAME="${1}"

  ASSIGNMENT_GRADING_DIR="${PWD}"

  if [[ "${ASSIGNMENT_GRADING_BASENAME}" != "$(basename ${PWD})" ]] ; then
    echo "Error: The working directory is not ${ASSIGNMENT_GRADING_BASENAME}"
    echo "Usage: create_assignment  xx-assignment-name"
    echo "   cd <${ASSIGNMENT_GRADING_BASENAME}>"
    echo "   create_assignment  xx-assignment-name"
    return 1;
  fi

  GRADING_ENV="${ASSIGNMENT_GRADING_DIR}/grading.env"
  if [[ ! -f ${GRADING_ENV} ]] ; then
    echo "File does not exist: ${GRADING_ENV}"
    return 2;
  fi

  if [[ -e "${ASSIGNMENT_NAME}" ]] ; then
    echo "Directory already exists: ${ASSIGNMENT_NAME}"
    return 2;
  fi


  mkdir ${ASSIGNMENT_NAME}
  ASSIGNMENT_ENV="assignment.env"  
  create_assignment_env > ${ASSIGNMENT_NAME}/${ASSIGNMENT_ENV}
    {
      cd ${ASSIGNMENT_NAME};
      source ${ASSIGNMENT_ENV}  # source the default environment file
      cd ..
    }

  mkdir ${KEY_DIR}

  # Clone the template directory if it exists
  git clone ${STUDENT_BASE_URL}.git ${KEY_DIR} >/dev/null 2>&1 
  if ((  $? != 0 )) ; then
    echo "Warning: Template Assignment does not exists."
    echo "   ${STUDENT_BASE_URL}.git"
  fi

  mkdir ${SUBMISSION_DIR}
  touch ${LOCAL_GRADE_REPORT}
  ln    ${LOCAL_GRADE_REPORT} ${CLASS_GRADE_REPORT}
  touch ${RELEASE_DATE_FILE}
  touch ${DUE_DATE_FILE}
  touch ${TIME_LIMIT_FILE}
  touch ${GRACE_PERIOD_FILE}
  touch ${ASSIGNMENT_MAKEFILE}
}


function grade_start () {
  # 1. Validate we are in an assignment-directory
  # 2. Source the assignment.env
  # 3. Startup for grading
  if [[ ! -f assignment.env ]] ; then
    echo "Usage:  cd <${ASSIGNMENT_GRADING_BASENAME}> ; grade_start"
    return 1
  fi
  source assignment.env
  terminal=$(tty)

  # Rerun these commands, in case of any updates after the initial `grade_start` is executed
  RELEASE_DATE="Not Defined"
  ACCEPT_DATE="Not Defined"
  DUE_DATE="Not Defined"
  TIME_LIMIT=
  GRACE_PERIOD=
  [[ -s "${RELEASE_DATE_FILE}" ]] && RELEASE_DATE="$(cat_nocomments RELEASE_DATE_FILE})"
  [[ -s "${DUE_DATE_FILE}" ]]     && DUE_DATE="$(cat_nocomments ${DUE_DATE_FILE})"
  [[ -s "${GRACE_PERIOD_FILE}" ]] && GRACE_PERIOD="$(cat_nocomments ${GRACE_PERIOD_FILE})" 
  [[ -s "${TIME_LIMIT_FILE}" ]]   && TIME_LIMIT_FILE="$(cat_nocomments ${TIME_LIMIT_FILE})" 

  echo "Starting the grading for:" ${ASSIGNMENT_NAME}
  [[ -n ${RELEASE_DATE} ]] && echo "Release Date: ${RELEASE_DATE}"
  [[ -n ${DUE_DATE} ]]     && echo "Due Date: ${DUE_DATE}"
  [[ -n ${TIME_LIMIT} ]]   && echo "Time Limit: ${TIME_LIMIT}"
  [[ -n ${GRACE_PERIOD} ]] && echo "Grace Period: ${GRACE_PERIOD}"

  # Check for key files
  [[ ! -f ${KEY_RUBRIC_FILE} ]] && {
     _l=$(relative_filename "${KEY_RUBRIC_FILE}" )
     echo "Warning: Rubric File Not Found: \"${_l}\"" ;  
  }
  # Check for grading roster
  assert_class_roster || return $?


  _grading_count=0

}

function relative_filename() {
  _base=${ASSIGNMENT_GRADING_DIR}
  sed "s|${_base}/||" <<< ${1}
}


# Grading Method: 
#   1. Paper Based:  visual review of a .md file
#   2. Code Based:  use of assignment-based makefile

#   - for each line in the grading_rubric file
#     - the prof is prompted for a score followed by an optional comment
#   - a grade report is created, with the total points tallied
#   - summary information is provided  



function regrade_submissions () {
  _grading_count=0

  assert_submission_roster || return $?

  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${CLASS_GRADE_REPORT}"


  for _student in $(input_list "$@") ; do
    regrade_submission ${_student}
  done

  {
    echo "# -------------------------------------"
    echo
  } >> "${CLASS_GRADE_REPORT}"
}

function regrade_submission () {
  _student=${1}
  _commit=${2}
  # remove tag and branch
  
  # Here we presume that we have not merged the branch

  # if we have truely finished grading then, we want a secondary branch
  # if it was an error to start the grading, and we want to cleanup 
  #  then simply remove the branch 

  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}"
  ( 
    cd $_dir 
    git checkout main
    git branch -D ${GRADING_BRANCH}
    git tag -d ${SUBMISSION_TAG}
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

  echo "--------------" > $terminal
  echo "Grading $_student" > $terminal
  if [[ ! -d $_dir ]] ; then
    printf "Error student did not accept assignment\n" > $terminal
    printf "$_student: -1\t\t# Did not ACCEPT assignment\n" >>${CLASS_GRADE_REPORT}
    return
  fi

  (
    echo "# Count: $_grading_count" > $terminal
    (( _grading_count ++ ))

    cd $_dir
    source "${GIT_STATISTICS_BASH}"

    if [[ "${_commit}" != "--" ]] ; then 
      # Checkout the version to be graded.  Either
      #  - they did not effectively submit something
      #  - they have a submission based upon due_date, etc
      #  - a specific commit hash was provided.
      git checkout ${ACCEPT_HASH} >/dev/null 2>&1
      [[ -n "${SUBMISSION_HASH}" ]] && git checkout ${SUBMISSION_HASH} >/dev/null 2>&1
      [[ -n "${_commit}" ]] && get checkout ${_commit} >/dev/null 2>&1
    fi


    git branch ${GRADING_BRANCH} >/dev/null 2>&1
    if (( $? != 0 )) ; then
      echo "Error: This repo has already been graded"
      return
    fi
    git tag ${SUBMISSION_TAG}
    # git checkout ${GRADING_BRANCH} >/dev/null 2>&1
    # You only need to checkout the grading branch when you perform
    # The git add, commit steps.

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
          echo "# Assignment:    \"${ASSIGNMENT_NAME}\""
          echo "# --- Due Date:        \"${DUE_DATE}\""
          echo "# --- Submission Date: \"${SUBMISSION_DATE}\""
          echo "# --- Tag & Hash:      \"${SUBMISSION_TAG} (${SUBMISSION_HASH})\""
          echo 
          echo "Missing submission file: ${STUDENT_SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"0\"        # ${_student}"
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
          echo "# --- Due Date:        \"${DUE_DATE}\""
          echo "# --- Submission Date: \"${SUBMISSION_DATE}\""
          echo "# --- Tag & Hash:      \"${SUBMISSION_TAG} (${SUBMISSION_HASH})\""
          echo 
          echo "Submission file has not been updated: ${STUDENT_SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"0\"         # ${_student}"
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
    {
      echo "Grading $_student" 
      echo 
      ag_show_commit_log ${DUE_DATE}
      echo
    } > $terminal

    { 
      echo "# Grading Report"
      echo "# Github Account: ${_student}"
      echo "# Assignment: \"${ASSIGNMENT_NAME}\""
      echo "# Assignment ID: \"${ASSIGNMENT_ID}\""
      echo "# --- Due Date:        \"${DUE_DATE}\""
      echo "# --- Submission Date: \"${SUBMISSION_DATE}\""
      echo "# --- Tag & Hash:      \"${SUBMISSION_TAG} (${SUBMISSION_HASH})\""
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
      echo "----"
      printf " %3d Points:\t\tTotal\n" $_score
      echo
      echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"        # ${_student}"
      echo

      ag_show_commit_log "${DUE_DATE}"

    } >> ${STUDENT_GRADE_REPORT}



    # Print out final score
    { echo ; 
      printf "$_student: $_score\n" ;
      echo ; 
    } > $terminal

    if [[ -z ${MINUTES_LATE} ]] ; then
      printf "$_student: $_score\n" >>${CLASS_GRADE_REPORT}
    else 
      printf "$_student: $_score\t\t# MINUTES_LATE=${MINUTES_LATE}\n"
    fi >>${CLASS_GRADE_REPORT}

    git checkout main    # force to go to the Canonical branch
  ) 
}

function input_list () {
   case  $# in
      0 )
            cat ${CLASS_ROSTER} 
            ;;
      1 )
       if [[ -f $1 ]]  ; then
          cat ${1} 
       else
              echo ${1}
       fi
       ;;
      * )
        for i in "$@" ; do
          echo $i
        done
       ;;
   esac | grep -v "^$"  # skip over blank lines
}


function grade_submissions () {
  _grading_count=0

  assert_submission_roster || return $?

  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${CLASS_GRADE_REPORT}"


  for _student in $(input_list "$@") ; do
    grade_submission ${_student}
  done

  {
    echo "# -------------------------------------"
    echo
  } >> "${CLASS_GRADE_REPORT}"
}


function reset_grading () {

  assert_submission_roster || return $?

  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${GRADING_LOG}" 2>&1


  for _student in $(input_list "$@") ; do
    (
      cd ${SUBMISSION_DIR}/$i
        # [[ -f "${CLASS_GRADE_REPORT}" ]] && {
        #   mv ${CLASS_GRADE_REPORT} ${CLASS_GRADE_REPORT}.$(date "+%Y:%m:%d:%H:%M")
        #   mv ${SUBMISSION_ROSTER} ${SUBMISSION_ROSTER}.$(date "+%Y:%m:%d:%H:%M")
        #   mv ${NON_SUBMISSION_ROSTER} ${NON_SUBMISSION_ROSTER}.$(date "+%Y:%m:%d:%H:%M")
        #}
      git -C ${SUBMISSION_DIR}/$i branch -d ${GRADING_BRANCH}
      git -C ${SUBMISSION_DIR}/$i tag -d ${SUBMISSION_TAG}
    )
  done 2> /dev/null

  {
    echo "# -------------------------------------"
    echo
  } >> "${GRADING_LOG}" 2>&1

}


function clone_submission () {
    
  if [[ -z "${1}" ]] ; then
    echo "Usage: clone_submission student"
    return 1
  fi 
  _student="${1}"

  if [[ -d ${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student} ]] ; then
    echo "Previously Cloned -- pulling: ${_student}"
    pull_submission $_student
  else 
    git -C ${SUBMISSION_DIR} clone ${STUDENT_BASE_URL}-${_student}.git >> ${GRADING_LOG} 2>/dev/null
    if [ $? == 0 ] ; then
      echo "Cloned: ${_student}"
      echo ${_student} >> ${SUBMISSION_ROSTER}
    else
      echo "Did Not Accept Assignment: ${_student}" 1>&2
      echo ${_student} >> ${NON_SUBMISSION_ROSTER}
    fi
  fi
}
function clone_submissions () {

 assert_submission_roster || return $?

 { 
    echo
    echo "---------------------"
    echo "Cloning Submissions:"
    echo "  Date:" $(date)
    echo
  } >> ${GRADING_LOG}

  for _student in $(input_list "$@") ; do
    clone_submission ${_student}
  done 2> /dev/null

  {
    echo "# -------------------------------------"
    echo
  } >> "${GRADING_LOG}" 2>&1
}  


function pull_submission () {
   if [[ -z "${1}" ]] ; then
    echo "Usage: pull_submission student"
    return 1
   fi 
   _student=${1}

   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/

   if [[ -d "${_dir}" ]] ; then 
     ( 
       git checkout main
       git pull --no-edit >> ${GRADING_LOG} 2>&1
       if [ $? == 0 ] ; then
         echo "Pulled: ${_student}"
       else
         echo "Error Pulling: ${_student}"
       fi 
     )
   fi
}
function pull_submissions () {

  assert_submission_roster || return $?

  { 
    echo "-------------------"
    echo "Pulling submissions: $(date)"
  } >> ${GRADING_LOG} 2>&1

  for _student in $(input_list "$@") ; do
    pull_submission ${_student}
  done 
}  

function commit_grade () {
  _student=${1}
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}

  if [[ -d "${_dir}" ]] ; then
    ( 
      cd ${_dir} 
      git checkout ${GRADING_BRANCH}
      if [[ -f ${KEY_ANSWER_FILE} ]] ; then
        cp ${KEY_ANSWER_FILE} .
        git add ${STUDENT_ANSWER_KEY}
        git commit -m 'Added Answers File' ${STUDENT_ANSWER_KEY}
      fi
      git add ${STUDENT_GRADE_REPORT} ${STUDENT_STAT_REPORT}
      git commit -m 'Added Student Grade Report' ${STUDENT_GRADE_REPORT} 
      git commit -m 'Added Statistics Report' ${STUDENT_STAT_REPORT}
      git checkout main
      git pull
      git merge --no-ff ${GRADING_BRANCH}
      if [[ $? != 0 ]] ; then
        echo "Merge conflict: ${_student}" > $terminal
      fi
    ) >> ${GRADING_LOG} 2>&1
    echo "Grade Committed: ${_student}"
  fi
}
function commit_grades () {
  assert_submission_roster || return $?

  { 
    echo "-------------------"
    echo "Committing grades: $(date)"
  } >> ${GRADING_LOG} 2>&1

  for _student in $(input_list "$@") ; do
    commit_grade ${_student}
  done
}  


function publish_grade () {
  _student=${1}
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}

  if [[ -d "${_dir}" ]] ; then
    ( 
      cd ${_dir} 
      git push --mirror
      return_value="$?"
      if [[ ${return_value} == 0 ]] ; then
        echo "Published (pushed): ${_student}" >$terminal
        echo "Published (pushed): ${_student}"
      else
        echo "Error Pushing: ${_student}"  >$terminal
        echo "Error Pushing: ${_student}"
      fi 
    ) >> ${GRADING_LOG} 2>&1
  fi
}
function publish_grades () {

 assert_submission_roster || return $?

  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${GRADING_LOG}" 2>&1


  for _student in $(input_list "$@") ; do
    publish_grade ${_student}
  done

  {
    echo "# -------------------------------------"
    echo
  } >> "${GRADING_LOG}" 2>&1


}

####
# Following needs to be tested.
function recreate_class_grade_report () {
   grep "^ASSIGNMENT_.._total" ${SUBMISSION_DIR}/*/grade.report |\
   sed -e 's/^.*="\([0-9]*\)".*# \(.*\)/\2: \1/' |\
   sort -f
}


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
     rm $_base.prep
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
    _hash=$(git rev-list -1 --until="${_date}" main)
    if [[ -n ${_hash} ]] ; then
      {
        echo "# Activity Report"
        echo "# Github Account: ${_student}"
        echo "# Assignment:    \"${ASSIGNMENT_NAME}\""
        echo "# Checkout Date: ${_date}"
        echo "# Checkout Hash: ${_hash}"
        echo "# Log Entries before checkout date:"
        git checkout ${_hash}  1>/dev/null 2>&1
        echo                              

        git log --decorate=full --oneline
        # add the author to the top to get ride of the prof's updates if any
        # here we don't care if the author is the prof.  it is what is is on that particular date
        echo
      } > ${STUDENT_ACTIVITY_REPORT}
    else 
      # Student did not have any activity prior to the checkout date
      :  
    fi
  )
}


## Following is now defunct due to timeline due.date information
function checkout_due_date () {
  _date=${1}

  assert_submission_roster || return $?

  [[ -z ${_date} ]] && [[ -f due_date ]] && _date="$(cat_nocomments due_date)"

  [[ -z ${_date} ]] && return
  
  { 
    echo "-------------------"
    echo "Checking out Version based upon date: ${_date}"
  } >> ${GRADING_LOG} 2>&1

  while read _student ; do
    checkout_date "${_date}" ${_student} 
  done < "${SUBMISSION_ROSTER}"
}  


function assert_submission_roster () {
  if [[ ! -f "${SUBMISSION_ROSTER}" ]] ; then
    echo "Error: No Submission Roster" 
    return 2
  fi 
}

function assert_class_roster () {
  if [[ ! -f ${CLASS_ROSTER} ]] ; then 
     _l=$(relative_filename "${CLASS_ROSTER}" )
     echo "Error: Grading Roster \"../$_l\" not found."
     return 1
  fi
}

function apply_all () {
  _CMD="$*"

  assert_submission_roster || return $?

  { 
    echo
    echo "-------------------"
    echo "Applying the following command within each Student Repository"
    echo "  Command:" $CMD
    echo
  } >> ${GRADING_LOG}

  while read _student  ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    (
      cd ${_dir}
      basename ${PWD}
      eval ${_CMD}
    ) 
  done < "${SUBMISSION_ROSTER}"
} 

function ag_show_commit_log () {
  DUE_DATE="$1"

  
  echo "COMMIT LOG:"
  echo
  git log --format=" %h %%%an%% %cd %d"  --date="format: %b %d %H:%M %z" --graph  --after "${DUE_DATE}" |
     grep -v "%${GITHUB_PROF_NAME}%" | sed 's/ %.*%//'

  if [[ -z ${DUE_DATE} ]] ; then
    echo "* Now:      $(date '+%b %d %T')  ---------------"
  else
    echo "* Due Date: ${DUE_DATE}  -----------------"
  fi
  git log --format=" %h %%%an%% %cd %d"  --date="format: %b %d %H:%M %z" --graph  --before "${DUE_DATE}" |
     grep -v "%${GITHUB_PROF_NAME}%" | sed 's/ %.*%//'
  echo

  ## Two issues exist with the date formats.
  #  1. DUE_DATE is provided in the current timezone
  #     - the time is off by one hour if either DUE_DATE or log date is in Daylight savings
  #  2. the initial commit is in a different timezone
}


function relative_filename() {
  _base=${ASSIGNMENT_GRADING_DIR}
  sed "s|${_base}/||" <<< ${1}
}


function cat_nocomments () {

  sed -e 's/^ *#.*$//'  -e '/^ *$/d' "$@"
}


