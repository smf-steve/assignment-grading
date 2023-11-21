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
#     - reset_grading       [ file | account ... ]
#     - clone_submissions   [ file | account ... ]
#     - pull_submissions    [ file | account ... ]
#     - checkout_due_date   [ date ]
#     - meets_criteria  "command" [ | account ... ]
#     - pregrade_submissions [--<commit> ] [ file | account ... ]  
#       - runs the grading process but returns after the special cases have been evaluated
#       - this effectively removes all of the students who did not "sufficiently" submit anything
#     - grade_submissions   [--<commit> ] [ file | account ... ]   
#       - Note: performs its own checkout of version
#       - Note: use the --<commit> option to override    
#     - regrade_submissions [--<commit> ] [ file | account ... ]
#     - commit_grades       [ file | args... ]
#     - publish_grades      [ file | args... ]
#          - zero args: operate on all students in the class_roster
#          - one arg that is a file: operate on each students enumerated in the file
#          - one or more args:  operate on each argument which is a student account
#          * The --<commit>, indicates what version of the software should be checked out
#             **  -- indicates use the current version
#             **  --hash indicates use the hash/tag version
#             **  otherwise, use the hash associated with the due.date, etc.
#
#     - plot_grades
#     - recreate_class_grade_report
#
# ###  ag_ is the prefix for AssignmentGrading
# #   For re/grade a single student
# #     - cd "<xx-assignment>"
# #     - grade_start
# #     - ag_pull_submission "<account>"
# #     - ag_grade_submission "<account>"  [ <commit> ] 
# #     - ag_regrade_submission "<account>" [ <commit> ]  
# #     - publish_grades "<account>"
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


###########################################################################
# The next two functions create the grading.env and assignment.env files.
# These files assign all the relative defaults for each assignment.
#
# To make global changes to these defaults,
#   - update the "here-documents" within these functions.
#
# To make local changes to these defaults,
#   - update the special "grading.env" and/or "assignment.env"
###########################################################################

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

export STUDENT_ASSIGNMENT_FILE="assignment.md"           # Contained within the student's repo
export STUDENT_SUBMISSION_FILE="submission.md"           # Contained within the student's repo

export STUDENT_ANSWER_KEY="answers.md"                   # To be added to the student's repo
export STUDENT_GRADE_REPORT_TMP="grade.report.tmp"           
export STUDENT_GRADE_REPORT="grade.report"               # To be added to the student's repo

export STUDENT_ACTIVITY_REPORT="activity.report"         # IF a call is made to checkout_date, this file contains the git log before this date
                                                  # Otherwise the file is empty

## GRADING RELATED VARIABLES
export SUBMISSION_TAG="graded_version"                   # Tag to identify the version of the repo that is graded
export GRADING_BRANCH="grading_information"

export GRADING_EDITOR="subl"
#GRADING_EDITOR="\${LAUNCH_COMMAND} /Applications/Sublime Text.app"

export RESPONSE_TAG='<!-- response -->'
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
export RELEASE_DATE_FILE="\${ASSIGNMENT_DIR}/release_date"
export DUE_DATE_FILE="\${ASSIGNMENT_DIR}/due_date"
export TIME_LIMIT_FILE="\${ASSIGNMENT_DIR}/time_limit"
export GRACE_PERIOD_FILE="\${ASSIGNMENT_DIR}/grace_period"

  export STUDENT_BASE_URL=\${GITHUB_PREFIX}/\${ASSIGNMENT_NAME}

  # Assignment Based Files
  export LOCAL_GRADE_REPORT="\${ASSIGNMENT_DIR}/grades.txt"
  export SUBMISSION_DIR="\${ASSIGNMENT_DIR}/submissions"
  
  export KEY_DIR="\${ASSIGNMENT_DIR}/key"
  export KEY_ANSWER_FILE="\${KEY_DIR}/answers.md"        # To be added to the student's repo
  export KEY_RUBRIC_FILE="\${KEY_DIR}/grading_rubric"    
  export KEY_MAKEFILE="\${KEY_DIR}/makefile"

  export ASSIGNMENT_MAKEFILE="\${ASSIGNMENT_DIR}/makefile"     # Should the be such a thing

  export GRADED_DATE_FILE=\${ASSIGNMENT_DIR}/graded.date

  export GRADING_LOG=\${ASSIGNMENT_DIR}/grading.log

  # Now Defunct
  # SUBMISSION_ROSTER=\${ASSIGNMENT_DIR}/roster.submissions
  # NON_SUBMISSION_ROSTER=\${ASSIGNMENT_DIR}/roster.non_submissions

EOF

}


#############################################################
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
    echo "\"${ASSIGNMENT_GRADING_DIR}\" directory already exists"
    return 2;
  fi

  mkdir ${ASSIGNMENT_GRADING_DIR}
  create_grading_env ${GITHUB_CLASSROOM} > ${GRADING_ENV}
  ( cd ${ASSIGNMENT_GRADING_DIR} ; create_assignment xx-sample-assignment >/dev/null ) 
}



#############################################################
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
  #ASSIGNMENT_ENV="assignment.env"  
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


#############################################################
function grade_start () {
  # 1. Validate we are in an assignment-directory
  # 2. Source the assignment.env
  # 3. Startup for grading
  if [[ ! -f ${ASSIGNMENT_ENV} ]] ; then
    echo "Usage:  cd <${ASSIGNMENT_GRADING_BASENAME}> ; grade_start"
    return 1
  fi
  source ${ASSIGNMENT_ENV}
  PS1="(grading:$ASSIGNMENT_ID- \W)$ "

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

function pregrade_submissions () {

    PREGRADE="TRUE"
    grade_submissions "$@"
    PREGRADE="FALSE"
}

function regrade_submissions () {
  _grading_count=0
  _commit_provided="$1"

  if [[ "${_commit_provided:0:2}"  == "--" ]] ; then
    shift
  else
    _commit_provided=
  fi

  assert_class_roster || return $?

  { 
    echo "Regrading Submissions:" $(date)
  } >> ${GRADING_LOG}

  {
    echo "# Regrade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${CLASS_GRADE_REPORT}"


  for _student in $(input_list "$@") ; do
    ag_regrade_submission ${_student} "$_commit_provided"
  done

  {
    echo "# -------------------------------------"
    echo
  } >> "${CLASS_GRADE_REPORT}"
}

function ag_regrade_submission () {
  _student=${1}
  _commit=${2}

  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}"
  if [[ -d ${_dir} ]] ; then 
    (
      cd $_dir 
      git checkout main >/dev/null 2>&1
      git branch -D ${GRADING_BRANCH}
      git tag -d ${SUBMISSION_TAG}
      if [[ -n $(git ls-files ${STUDENT_GRADE_REPORT}) ]] ; then 
        # We are tracking a previous grade_report, so move the old grade report
        git mv ${STUDENT_GRADE_REPORT} ${STUDENT_GRADE_REPORT}.$(date '+%m-%d-%T')
        git commit -m 'Regrading'
      fi
    ) > /dev/null 2>> ${GRADING_LOG}
  fi

  ag_grade_submission "$_student" "$_commit"
}


function grade_submissions () {
  _grading_count=0
  _commit_provided="$1"

  if [[ "${_commit_provided:0:2}"  == "--" ]] ; then
    shift
  else
    _commit_provided=
  fi

  assert_class_roster || return $?

  { 
    echo "Grading Submissions:" $(date)
  } >> ${GRADING_LOG}
  {
    echo "# Grade Report: ${ASSIGNMENT_NAME} $(date)"
  } >> "${CLASS_GRADE_REPORT}"

  for _student in $(input_list "$@") ; do
    ag_grade_submission ${_student} "$_commit_provided"
  done

  {
    echo "# -------------------------------------"
    echo
  } >> "${CLASS_GRADE_REPORT}"
}

function ag_grade_submission () {
  _not_accepted=-5
  _only_accepted=-5
  _no_work=-5
  _student=${1}
  _commit_provided=${2:0:2}
  _commit=${2:2}

  source ${ASSIGNMENT_ENV}
  _dir="${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}"

  echo "--------------" > $terminal
  (( _grading_count ++ ))
  echo "Grading Count: $_grading_count" > $terminal
  echo "Grading $_student" > $terminal

  if [[ ! -d $_dir ]] ; then
    printf "\tStudent did not accept assignment.\n" > $terminal
    printf "%-20s: %3d\t# Did not ACCEPT assignment.\n"  "${_student}" "${_not_accepted}" >>${CLASS_GRADE_REPORT}
    # Note that multiple lines could appear in the CLASS_GRADE_REPORT for such students
    return
  fi

  (
    cd $_dir

    git branch ${GRADING_BRANCH} >/dev/null 2>&1
    if (( $? != 0 )) ; then
      printf "\tStudent's repository has already been graded.\n"
      return
    fi

    # Use the script to determine which commit version to grade by due_date
    source "${GIT_STATISTICS_BASH}"

    if [[ "${_commit_provided}" == "--" && -z "${_commit}" ]] ; then 
      : # Use the current checkout version
    else
      # Set the _commit to be the SUBMISSION_HASH, if a _commit was not provided
      [[ -n "${_commit}" ]] && _commit=${SUBMISSION_HASH}
    fi

    if [[ -n "${_commit}" ]] ; then 
      git checkout ${_commit} >/dev/null 2>&1
      SUBMISSION_HASH=$(git log --format="%h" --date="format:%b %d %T" -1)
      SUBMISSION_DATE=$(git log --format="%cd" --date="format:%b %d %T" -1)
      git tag ${SUBMISSION_TAG}
    else
      : # There is nothing to grade
    fi

    {
      echo
      ag_show_commit_log "${DUE_DATE}"
      echo
    } > $terminal

    _score=0

     # Grade Report Prologue
    rm -f ${STUDENT_GRADE_REPORT_TMP}
    { 
       echo "# Grading Report"
       echo "# Github Account: ${_student}"
       echo "# Assignment:    \"${ASSIGNMENT_NAME}\""

       if [[ -z "${TIME_LIMIT}" ]] ; then
         echo "# --- Due Date:        \"${DUE_DATE}\""
       else
         echo "# --- Accept Date:     \"${ACCEPT_DATE}\""
         echo "# --- Due Date:        \"${DUE_DATE}\" (time limit: ${TIME_LIMIT})"
         echo "# --- Cutoff Date:     \"${CUTOFF_DATE}\"" 
       fi
       if [[ -n "${SUBMISSION_HASH}" ]] ; then
         echo "# --- Version Graded:  \"${SUBMISSION_TAG} (${SUBMISSION_HASH})\""
         echo "# --- Version Date:    \"${SUBMISSION_DATE}\""
       fi
       echo "# --- Status:          \"${STATUS}\""
       if [[ -n ${MINUTES_LATE} ]] ; then
         echo "# --- Last Commit late by: $MINUTES_LATE minutes"
       fi 
       echo
    } > ${STUDENT_GRADE_REPORT_TMP}



    ##### Handle Special Cases

    #######################################################
    ## Special Cases -- to short circuit grading
    ##
    ## 1. Student accepted the assignment AFTER the due date
    ##    I.e., no work was done by the student
    ##      - $SUBMISSION_HASH = ""
    ## 1. Student accepted the assignment BEFORE the due date
    ##    but no additional commits were performed
    ##    I.e., no work was done by the student
    ##      - ACCEPT_HASH == SUBMISSION_HASH
    ## 1. There is no Submission File to be graded
    ##    I.e., no work was done by the student
    ##      - if Paper Assignment - no Submission file
    ##      - Submission_File could be: foo.java, etc, 
    ## 1. Effectively no work done by the student
    ##    - if Paper Assignment-- Submission file ~=== Assignment File
    ##    - number of commit

    #######################################################

    # Set the value of when the student accepted the assignment -- 
    #   -- this value is now added to the grade report for further analysis
    _accepted="$(date -r ${ACCEPT_TS} '+%Y%m%d%H%M')"

    if [[ -z "${SUBMISSION_HASH}" ]] ; then
      # student did not accept the assignment prior to the due-date
      _score=0
      printf "\t Student accepted the assignment AFTER the due date\n\n"
      printf "%-20s: %3d\t# %s %s\n" "${_student}" "${_only_accepted}" "${_accepted}" "Accepted AFTER due date" >>${CLASS_GRADE_REPORT}
      { 
        echo "Student accepted the assignment AFTER the due date"
        echo
        echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"        # ${_student}"
        echo

        ag_show_commit_log "${DUE_DATE}"
      }  >> ${STUDENT_GRADE_REPORT_TMP}
      git checkout main >/dev/null 2>&1
      return
    fi


    if [[ ${ACCEPT_HASH} == ${SUBMISSION_HASH} ]] ; then
      # no work was done by the student.
      _score=0
      printf "\t No activity by the student\n\n"
      printf "%-20s: %3d\t# %s %s\n" "${_student}" "${_only_accepted}" "${_accepted}" "Student only accepted the assignment" >>${CLASS_GRADE_REPORT}
      { 
        echo "Student only accepted the assignment."
        echo
        echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"        # ${_student}"
        echo

        ag_show_commit_log "${DUE_DATE}"
      }  >> ${STUDENT_GRADE_REPORT_TMP}
      git checkout main >/dev/null 2>&1
      return
    fi

    if [[  -f ${STUDENT_ASSIGNMENT_FILE} ]] ; then
      # This is a paper submission, 
      # Note that if a student creates the assignment.md file -- JUST because
      #   and this is NOT a paper submission -- this breaks.

      if [[ ! -f ${STUDENT_SUBMISSION_FILE} ]] ; then
        # Nothing Submitted
        _score=0
        { 
          printf "\t Missing submission file\n\n"
          printf "\nFinal Score $_student: $_score\n\n" ;
        } > $terminal

        printf "%-20s: %3d\t# %s %s\n" "${_student}" "${_no_work}" "${_accepted}" "Missing ${STUDENT_SUBMISSION_FILE}" >>${CLASS_GRADE_REPORT}
        { 
          echo "Missing submission file: ${STUDENT_SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"        # ${_student}"
          echo

          ag_show_commit_log "${DUE_DATE}"

        }  >> ${STUDENT_GRADE_REPORT_TMP}
        git checkout main >/dev/null 2>&1
        return
      fi

      diff ${STUDENT_SUBMISSION_FILE} ${STUDENT_ASSIGNMENT_FILE} >/dev/null 2>&1
      if (( $? == 0 )) ; then
        #  The Submission File is effectively Blank

        _score=0
        printf "\t No updates to ${STUDENT_SUBMISSION_FILE}\n"
        printf "%-20s: %3d\t# %s %s\n" "${_student}" "${_no_work}" "${_accepted}" "No updates to ${STUDENT_SUBMISSION_FILE}" >>${CLASS_GRADE_REPORT}
        { 
          echo "Submission file has not been updated: ${STUDENT_SUBMISSION_FILE}"
          echo
          echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"         # ${_student}"
          echo

          ag_show_commit_log "${DUE_DATE}"

        }  >> ${STUDENT_GRADE_REPORT_TMP} 
        git checkout main  >/dev/null 2>&1
        return
      fi
      #######################################################
      ## Special Cases
      #######################################################
    fi
    # Note there is a return in the code block above.
    # Hence, flow might not get here

    if [[ ${PREGRADE} == "TRUE" ]]; then 
      reset_grading "$_student"
      return
    fi

    # Determine which MAKEFILE to use
    MAKE_FILE=${KEY_MAKEFILE}
    [[ ! -f ${MAKE_FILE} ]] && MAKE_FILE=${ASSIGNMENT_MAKEFILE}
    [[ ! -s ${MAKE_FILE} ]] && MAKE_FILE=${CLASS_MAKEFILE}
    
    make -f ${MAKE_FILE} grade

    # Prompt the Professor for items related to the rubric
    {
      # For each line in the rubric
      while read _line ; do
        if [[ "$_line" == \#* ]] ; then
          echo $_line
        else
          echo $_line          > $terminal
          read _value _comment < $terminal
          printf "  %2d Points:  $_line: $_comment\n" $_value
          (( _score += _value ))
        fi
      done < ${KEY_RUBRIC_FILE} >> ${STUDENT_GRADE_REPORT_TMP}
    }

    # Add the grade.report epilogue
    {
      echo "----"
      printf " %3d Points:  Total\n" ${_score}
      echo
      echo "ASSIGNMENT_${ASSIGNMENT_ID}_total=\"$_score\"        # ${_student}"
      echo

      ag_show_commit_log "${DUE_DATE}"

    } >> ${STUDENT_GRADE_REPORT_TMP}


    # Print out final score
    { 
      printf "\nFinal Score ${_student}: ${_score}\n\n" ;
    } > $terminal


    {
      printf "%-20s: %3d\t# %s" ${_student} ${_score} ${_accepted}
      if [[ -z ${MINUTES_LATE} ]] ; then
        printf "\n" 
      else 
        printf " On-time Version behind by: ${MINUTES_LATE} minutes\n"
      fi
    } >>${CLASS_GRADE_REPORT}

    # Go back to the Canonical HEAD
    git checkout main  >/dev/null 2>&1
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


function reset_grading () {

  assert_class_roster || return $?

  {
    echo "# Resetting grading: $(date)"
  } >> "${GRADING_LOG}"

  for _student in $(input_list "$@") ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    if [[ -d "$_dir" ]] ; then 
      git -C ${_dir} checkout main
      git -C ${_dir} branch -d ${GRADING_BRANCH}
      git -C ${_dir} tag -d ${SUBMISSION_TAG}
    fi
  done > /dev/null  2>&1
}


function ag_clone_submission () {
  _student="${1}"

  if [[ -d ${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student} ]] ; then
    echo "Previously Cloned -- pulling: ${_student}"
    ag_pull_submission $_student
  else 
    git -C ${SUBMISSION_DIR} clone ${STUDENT_BASE_URL}-${_student}.git >> ${GRADING_LOG} 2>/dev/null
    if [ $? == 0 ] ; then
      echo "Cloned: ${_student}"
    else
      echo "Did Not Accept Assignment: ${_student}"
    fi
  fi
  [[ -n ${ON_CAMPUS} ]] && sleep 4
}
function clone_submissions () {

  assert_class_roster || return $?

  { 
    echo "Cloning Submissions:" $(date)
  } >> ${GRADING_LOG}

  for _student in $(input_list "$@") ; do
    ag_clone_submission ${_student}
  done 2> /dev/null
}  


function ag_pull_submission () {
   _student=${1}

   _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
   if [[ -d "${_dir}" ]] ; then 
     ( 
       cd "${_dir}"
       git checkout main >/dev/null 2>&1
       git pull --no-edit
       git pull --force --tags
       if [ $? == 0 ] ; then
         echo "Pulled: ${_student}" 
       else
         echo "Error Pulling: ${_student}" 
       fi > $terminal
     ) >/dev/null 2>> ${GRADING_LOG}
   fi
}
function pull_submissions () {

  assert_class_roster || return $?

  { 
    echo "Pulling submissions: $(date)"
  } >> ${GRADING_LOG}

  for _student in $(input_list "$@") ; do
    ag_pull_submission ${_student}
  done 
}  

function commit_grade () {
  set -x
  _student=${1}
  _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}

  if [[ -d "${_dir}" ]] ; then
    ( 
      cd ${_dir} 
      git checkout ${GRADING_BRANCH} >/dev/null 2>&1
      if [[ -f ${KEY_ANSWER_FILE} ]] ; then
        cp ${KEY_ANSWER_FILE} .
        git add ${STUDENT_ANSWER_KEY}
        git commit -m 'Added Answers File' ${STUDENT_ANSWER_KEY}
      fi
      mv ${STUDENT_GRADE_REPORT_TMP} ${STUDENT_GRADE_REPORT}
      git add ${STUDENT_GRADE_REPORT}
      git commit -m 'Added Student Grade Report' ${STUDENT_GRADE_REPORT} 
      git checkout main >/dev/null 2>&1
      git pull
      git merge --no-ff -m 'merging grading information' ${GRADING_BRANCH}
      if [[ $? != 0 ]] ; then
        echo "Merge conflict: ${_student}" > $terminal
      fi
    ) 2>> ${GRADING_LOG}
    echo "Grade Committed: ${_student}"
  fi
}
function commit_grades () {
  assert_class_roster || return $?

  { 
    echo "Committing grades: $(date)"
  } >> ${GRADING_LOG}

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
      else
        echo "Error Pushing: ${_student}"  >$terminal
        echo "Error Pushing: ${_student}"
      fi 
    ) >> ${GRADING_LOG} 2>&1
  fi
}
function publish_grades () {

 assert_class_roster || return $?

  {
    echo "# Publishing Grades: ${ASSIGNMENT_NAME} $(date)"
  } >> "${GRADING_LOG}" 2>&1


  for _student in $(input_list "$@") ; do
    publish_grade ${_student}
  done
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
      echo "$_student, -1, #no grade"
    fi
  done < $_roster
}

# Designed to be rerun at the end of the semester
#  - it will remove anyone who has dropped
#  - it will add appropriate zero scores to folks that skipped an assignment
# Process a grade.*.log file
# removing comment lines
# removing blank lines
# removing tabs
# convert  "student: grade" --> "student, grade"
# sort in case insensitive the resulting file
# if no dups, then join with class roster to ensure all have a recorded grade.
function grades2csv () {
   _file="$1"
   _base=$(basename -s .txt $_file )
   sed -e  '/^#/d' -e '/^ *$/d' -e 's/\t//g' -e 's/:/,/g' -e 's/#/, #/' $_file |\
     sort -u -f  > $_base.prep
   awk '{ print $1}' $_base.prep | sort -u -f --check=quiet >/dev/null
   if [[ $? != 0 ]] ; then
     echo "$_file: Multiple grades for some students" 1>&2
   else
     #  The "join" utility seems to be broken on MacOS
     #  The "join" on RedHat does not allow hyphens in the key 
     grade_join ${CLASS_ROSTER} $_base.prep >$_base.csv
   fi
   rm $_base.prep
}


# ls grades.*.txt | all_grades2csv 
function all_grades2csv () {
  while read _file ; do
     grades2csv $_file
  done 
}


# generate_excel_cell grades.10-quiz-models.csv

# ls grades.*.csv | generate_excel_cells
function generate_excel_cells () {
    while read _file ; do
      _basename=$(basename -s .csv $_file)
      echo "='[$_file]$_basename'!B1"
   done  
}

## Following is now defunct due to timeline due.date information

function ag_checkout_date () {
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
        git checkout ${_hash}  >/dev/null 2>&1
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


# criteria must resolve to True==0, or not True
function meets_criteria  () {
  criteria="$1"
  shift

  assert_class_roster || return $?

  for _student in $(input_list "$@") ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    if [[ -d "$_dir" ]] ; then 
      (
        cd ${_dir}
        eval "$criteria"  >/dev/null 2>&1
        if [[ $? ==  0 ]] ; then
          echo ${_student}
        fi
      ) 
    fi 
  done 
} 



## Following is now defunct due to timeline due.date information
function checkout_due_date () {
  _date=${1}

  assert_class_roster || return $?

  [[ -z ${_date} ]] && [[ -f due_date ]] && _date="$(cat_nocomments due_date)"
  [[ -z ${_date} ]] && return
  
  { 
    echo "Checkout by date (${_date}):" $(date)
  } >> ${GRADING_LOG} 2>&1

  for _student in $(input_list "$@") ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    if [[ -d "$_dir" ]] ; then 
      ag_checkout_date "${_date}" ${_student} 
    fi
  done 
}  


function assert_class_roster () {
  if [[ ! -f ${CLASS_ROSTER} ]] ; then 
     _l=$(relative_filename "${CLASS_ROSTER}" )
     echo "Error: Grading Roster \"../$_l\" not found."
     return 1
  fi
  return 0
}

function apply_all () {
  _CMD="$1"
  shift

  assert_class_roster || return $?

  { 
    echo "Apply_all (\"$_CMD\"): $(date)"
  } >> ${GRADING_LOG}

  for _student in $(input_list "$@") ; do
    _dir=${SUBMISSION_DIR}/${ASSIGNMENT_NAME}-${_student}/
    if [[ -d "$_dir" ]] ; then 
      (
        cd ${_dir}
        basename ${PWD}
        eval ${_CMD}
      ) 
    fi 
  done 
} 

function ag_show_commit_log () {
  DUE_DATE="$1"

  if [[ -z "$DUE_DATE" ]] ; then
    DUE_DATE="$(date '+%b %d %T')"
  fi
  
  echo "STUDENT COMMIT HISTORY:"
  echo
  git log --format=" %h %%%an%% %cd %d"  --date="format-local: %b %d %H:%M %z" \
          --graph  --after "${DUE_DATE}" origin/main |
     grep -v "%${GITHUB_PROF_NAME}%" | sed 's/ %.*%//'

  if [[ -z ${DUE_DATE} ]] ; then
    echo "* Now:      $(date '+%b %d %T')  ---------------"
  else
    echo "* Due Date: ${DUE_DATE}  -----------------"
  fi
  git log --format=" %h %%%an%% %cd %d"  --date="format-local: %b %d %H:%M %z" \
          --graph  --before "${DUE_DATE}" origin/main |
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

function average () {
  local sum=0 count=0
  while read _score ; do 
    if (( _score > 0 )) ; then 
      (( count++ ))
      (( sum+= _score ))
    fi
  done < data_grades
  echo $(( sum / count  ))
}

function create_data_grades () {
    cat grades.txt | sed -e 's/ *#.*$//' -e '/^ *$/d' | awk -F: '{ print $2}' | sort -n >data_grades
}

function create_accept_grades () {

  cat grades.txt | sed -e '/^$/d' -e '/^#/d' -e '/Did not ACCEPT/d' -e 's/^.*://' |\
    awk '{ print $3, $1}' | sort -n >accept_grades
}

function plot_grades () {

  create_data_grades
  local average=$(average <data_grades)
gnuplot <<EOF
set term png
set output "${ASSIGNMENT_NAME}-scores.png"
set title "Scores: ${ASSIGNMENT_NAME}"
set xlabel "Individual Student Submission"
set ylabel "Assigned Grade"
set xrange [0:105]
set format x ""
set xtics 1,1
set key fixed left top
set key outside right top title "Legend"
plot [0:80][-10:105] 0 notitle, ${average} title "average (>0)", "data_grades" with linespoints title "score"
EOF

}

function plot_grades_accept () {

  create_data_grades
  create_accept_grades

  local due_date=$(date -j -f '%b %d %T' "${DUE_DATE}" '+%Y%m%d%H%M')
  local average=$(average <data_grades)

gnuplot <<EOF
set term png
set output "${ASSIGNMENT_NAME}-scores_by_accept.png"
set title "Scores: ${ASSIGNMENT_NAME}"
set xlabel "Individual Student Submission"
set ylabel "Assigned Grade"
set xrange [0:105]
set format x ""
set xtics 1,1
set key fixed left top
set key outside right top title "Legend"
set arrow from ${due_date}, 0  to ${due_date}, 90 nohead
plot [0:80][-10:105] 0 notitle, ${average} title "average", "accept_grades" with linespoints title "score"
EOF


}
