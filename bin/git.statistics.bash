#! /bin/bash 
# format: ct = committer timestamp

## the `date` command on MacOS is different then Linux


trap 'rm .$$_full.log' 0
# due_date="Nov 12 00:00:00 PDT"  # "+%b %d %T %Z"   
# time_limit="2H"                 # 2 hours == 120 minutes
# grace_period="2M"               # 2 minutes

### The following appear to be the variables that are used in grade.bash
##
# STATUS
# SUBMISSION_HASH
# SUBMISSION_DATE
# ACCEPT_HASH
# ACCEPT_DATE

RELEASE_DATE_FILE="${ASSIGNMENT_DIR}/release_date"
DUE_DATE_FILE="${ASSIGNMENT_DIR}/due_date"
TIME_LIMIT_FILE="${ASSIGNMENT_DIR}/time_limit"
GRACE_PERIOD_FILE="${ASSIGNMENT_DIR}/grace_period"

STUDENT_STAT_REPORT="statistics.report"

RELEASE_DATE="Not Defined"
ACCEPT_DATE="Not Defined"
DUE_DATE="Not Defined"
TIME_LIMIT=
GRACE_PERIOD="0S"
TIMELIMIT_DUE_DATE=


# Algorithm:
#
# 1. Read git log: "hash (%h) commit TS (%ct)
# 2. Extract Info
#    - ACCEPT_INFO          <-- last line
#    - LAST_COMMIT_INFO     <-- first line
# 3. Determine version_TS
#    - If no set due_date nor time_limit, then LAST_COMMIT_INFO
#    - due_date_TS
#      * date -j -f "${AG_DATE_FORMAT}" "$(due_date)" "+%s"
#    - time_limit_TS = accept_date + time_limit
#      * date -r <ts> -v +"$time_limit"
#    - version_TS = min(due_date_TS, time_limit_TS)
# 4. Extract SUBMISSION INFO
# 5. Determine the number of commits
# 6. Output the information

# Read git log
 git log --format="format:%h %ct %%%an%%" |
     grep -v "%${GITHUB_PROF_NAME}%"      |
     sed -e 's/ %.*%//'                   \
     > .$$_full.log
     # this strips out any commits done by the Prof.

# Because github classroom forks from the repo now,
# the first commit is when the original repo was built
# We now don't have a way to determine when the student
# has accepted the assignment.
#
# The best we can do--at this time--is to use the first
# student commit.  
#
# This is problematic for timed events -- the students
# can game the system.

# Extract Accept/Last Info
_number_commits=$(cat .$$_full.log | wc -l )
if [[ $_number_commits == 1 ]] ; then
   echo NO COMMITS
   ACCEPT_INFO=( $(tail -1 .$$_full.log) )
else
   ACCEPT_INFO=( $(tail -2 .$$_full.log | head -1) )
fi
LAST_COMMIT_INFO=( $(head -1 .$$_full.log) ) 


# Determine SUBMISSION INFO
# # presume no due date or time_limit
SUBMISSION_INFO=( ${LAST_COMMIT_INFO[@]} )

DUE_DATE_TS="${SUBMISSION_INFO[1]}"
TIME_LIMIT_TS="${SUBMISSION_INFO[1]}"


### These values are set via grade.bash
if [[ -s "${RELEASE_DATE_FILE}" ]] ; then
   RELEASE_DATE="$(cat_nocomments ${RELEASE_DATE_FILE})"
fi

if [[ -s "${GRACE_PERIOD_FILE}" ]] ; then
   GRACE_PERIOD="$(cat_nocomments ${GRACE_PERIOD_FILE})"
fi

if [[ -s "${DUE_DATE_FILE}" ]] ; then
  DUE_DATE="$(cat_nocomments ${DUE_DATE_FILE})"
  DUE_DATE_TS=$( date -j -f "${AG_DATE_FORMAT}" -v +${GRACE_PERIOD} "${DUE_DATE}" '+%s' )
fi

if [[ -s "${TIME_LIMIT_FILE}" ]] ; then
  TIME_LIMIT="$(cat_nocomments ${TIME_LIMIT_FILE})"
  if [[ -n "${TIME_LIMIT}" ]] ; then
    TIME_LIMIT_TS=$( date -r ${ACCEPT_INFO[1]} -v +${TIME_LIMIT} -v +${GRACE_PERIOD} '+%s' )
  fi
fi

if (( TIME_LIMIT_TS < DUE_DATE_TS )) ; then 
   SUBMISSION_TS=${TIME_LIMIT_TS}
else
   SUBMISSION_TS=${DUE_DATE_TS}
fi

TIMELIMIT_DUE_DATE_TS="${SUBMISSION_TS}"
TIMELIMIT_DUE_DATE="$(date -r ${SUBMISSION_TS} "+${AG_DATE_FORMAT}")"

# Determine the SUBMISSION INFORMATION
if (( SUBMISSION_TS < LAST_COMMIT_INFO[1] )) ; then
   { 
      read _hash _ts 
      while [[ $SUBMISSION_TS < $_ts ]] ; do
         read _hash _ts 
      done
   } < .$$_full.log
   SUBMISSION_INFO=( $_hash $_ts )

   #SUBMISSION_INFO=( 
   ##    $(git log --format='format:%h %ct' --before ${SUBMISSION_TS} -1) 
   #)
fi


NUM_COMMITS="$(sed -n '$=' < .$$_full.log)"
if (( ${#SUBMISSION_INFO[@]} == 0 )) ; then
   SUBMISSION_HASH="${ACCEPT_HASH}"
   SUBMISSION_TS="${SUBMISSION_TS}"
   SUBMISSION_DATE="${SUBMISSION_DATE}"

   NUM_COMMITS_POST_SUBMISSION="$NUM_COMMITS"
else
   SUBMISSION_HASH="${SUBMISSION_INFO[0]}"
   SUBMISSION_TS="${SUBMISSION_INFO[1]}"
   SUBMISSION_DATE="$(date -r ${SUBMISSION_INFO[1]} "+${AG_DATE_FORMAT}")"

   NUM_COMMITS_POST_SUBMISSION="$(( $(sed -n /${SUBMISSION_HASH}/= .$$_full.log) - 1))"
fi
NUM_COMMITS_PRE_SUBMISSION="$(( NUM_COMMITS - NUM_COMMITS_POST_SUBMISSION ))"


if [[ "${GRACE_PERIOD}" == "0S" ]] ; then
   GRACE_PERIOD="None Given"
fi


# Determine the Status
STATUS="Submission On Time"
if (( ${NUM_COMMITS_POST_SUBMISSION} > 0 )) ; then
  STATUS="Post Due Date Commits Ignored"
fi
if [[ -z "${SUBMISSION_HASH}" ]] ; then 
  SUBMISSION_DATE=""
  STATUS="No Submission"
fi

### Final Information
MINUTES_LATE="$(( (${LAST_COMMIT_INFO[1]} - ${TIMELIMIT_DUE_DATE_TS}) / 60 ))"
   # Number of minutes the last commit was made after the final due date
if (( MINUTES_LATE <= 0 )) ; then
   MINUTES_LATE=""
else
   MINUTES_LATE="${MINUTES_LATE}"
fi

# DAYS_LATE="$(( MINUTES_LATE / (24 * 60)))"
# REMAINDER="$(( MINUTES_LATE % (24 * 60)))"
# HOURS_LATE=$(( REMAINDER / 60 ))
# MIN_LATE=$(( REMAINDER % 60 ))
# TIME_LATE="${DAYS_LATE}D${HOURS_LATE}H${MIN_LATE}M"

if [[ -z "${TIME_LIMIT}" ]] ; then
  DUE_DATE="${DUE_DATE}"
else
  ACCEPT_DATE="$(date -r ${ACCEPT_INFO[1]} "+${AG_DATE_FORMAT}")"
  CUTOFF_DATE="${DUE_DATE}"
  DUE_DATE="${TIMELIMIT_DUE_DATE}"
fi

ACEPT_HASH="${ACCEPT_INFO[0]}"
ACCEPT_TS="${ACCEPT_INFO[1]}"
ACCEPT_DATE="$(date -r ${ACCEPT_TS} "+${AG_DATE_FORMAT}")"


#cat > ${STUDENT_STAT_REPORT} <<EOF
#  # Git Statistics Report
#  # Github Account: ${_student}
#  # Assignment: "${ASSIGNMENT_NAME}"
#  # Assignment ID: "${ASSIGNMENT_ID}"
#  # --- Due Date:        "${DUE_DATE}"
#  # --- Submission Date: "${SUBMISSION_DATE}"
#  # --- Tag & Hash:      "${SUBMISSION_TAG} (${SUBMISSION_HASH})"
#  
#  STATUS="${STATUS}"
#  EOF
#  if [[ ${STATUS} != "Submission On Time" ]] ; then
#    echo MINUTES_LATE=\"${MINUTES_LATE}\"
#  fi >> ${STUDENT_STAT_REPORT} 
#  if [[ "${GRACE_PERIOD}" != "None Given" ]] ; then
#   echo "GRACE_PERIOD=\"${GRACE_PERIOD}\""
#  fi >> ${STUDENT_STAT_REPORT}
#  
#  
#  if [[ -z "${TIME_LIMIT}" ]] ; then
#    echo
#    echo "DUE_DATE=\"${DUE_DATE}\""
#  else
#    echo
#    echo "ACCEPT_DATE=\"${ACCEPT_DATE}\""
#    echo " TIME_LIMIT=\"${TIME_LIMIT}\""
#    echo "   DUE_DATE=\"${DUE_DATE}\""
#    echo "CUTOFF_DATE=\"${CUTOFF_DATE}\""
#  fi >> ${STUDENT_STAT_REPORT} 
#  
#  
#  cat >> ${STUDENT_STAT_REPORT} <<EOF
#  
#  TAGS=(
#  $(git tag)
#  )
#  
#  NUM_COMMITS="${NUM_COMMITS}"
#  NUM_COMMITS_POST_SUBMISSION="${NUM_COMMITS_POST_SUBMISSION}"
#  NUM_COMMITS_PRE_SUBMISSION="${NUM_COMMITS_PRE_SUBMISSION}"
#  
#  LAST_COMMIT_HASH="${LAST_COMMIT_INFO[0]}"
#  LAST_COMMIT_TS="${LAST_COMMIT_INFO[1]}"
#  LAST_COMMIT_DATE="$(date -r ${LAST_COMMIT_INFO[1]} "+${AG_DATE_FORMAT})"
#  
#  SUBMISSION_HASH="${SUBMISSION_HASH}"
#  SUBMISSION_TS="${SUBMISSION_TS}"
#  SUBMISSION_DATE="${SUBMISSION_DATE}"
#  
#  ACCEPT_HASH="${ACCEPT_INFO[0]}"
#  ACCEPT_TS="${ACCEPT_INFO[1]}"
#  ACCEPT_DATE="$(date -r ${ACCEPT_INFO[1]} "+${AG_DATE_FORMAT}")"
#  
#  EOF
#  
#  
#  source ${STUDENT_STAT_REPORT}
#   

