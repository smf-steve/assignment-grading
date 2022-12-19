#! /bin/bash 
# format: ct = committer timestamp

trap 'rm .$$_full.log' 0
# due_date="Nov 12 00:00:00"  # "+%b %d %T"
# timelimit="2H"  # 120M
# grace_period="2M"   # 2 minutes

RELEASE_DATE_FILE="${ASSIGNMENT_DIR}/release.date"
DUE_DATE_FILE="${ASSIGNMENT_DIR}/due.date"
TIME_LIMIT_FILE="${ASSIGNMENT_DIR}/timelimit"
GRACE_PERIOD_FILE="${ASSIGNMENT_DIR}/grace_period"

STUDENT_STAT_REPORT="statistics.report"

RELEASE_DATE="Not Defined"
ACCEPT_DATE="Not Defined"
DUE_DATE="Not Defined"
TIME_LIMIT="Not Defined"
GRACE_PERIOD=
TIMELIMIT_DUE_DATE=

# Algorithm:
#
# 1. Read git log: "hash (%h) commit TS (%ct)
# 2. Extract Info
#    - ACCEPT_INFO <-- last line
#    - LAST_COMMIT_INFO <-- first line
# 3. Determine version_TS
#    - If no set due-date nor timelimit, then LAST_COMMIT_INFO
#    - due_date_TS
#      * date -j -f "%b %d %T" "$(due_date)" "+%s"
#    - time_limit_TS = accept_date + timelimit
#      * date -r <ts> -v +"$timelimit"
#    - version_TS = min(due_date_TS, time_limit_TS)
# 4. Extract SUMBISSION INFO
# 5. Determine the number of commits
# 6. Output the information
if [[ -f "${RELEASE_DATE_FILE}" ]] ; then
   RELEASE_DATE="$(cat ${RELEASE_DATE_FILE})"
fi

GRACE_PERIOD="0S"
if [[ -f "${GRACE_PERIOD_FILE}" ]] ; then
   GRACE_PERIOD="$(cat ${GRACE_PERIOD_FILE})"
fi

# Read git log
git log --format='format:%h %ct' > .$$_full.log

# Extract Accept/Last Info
ACCEPT_INFO=( $(tail -1 .$$_full.log) )
LAST_COMMIT_INFO=( $(head -1 .$$_full.log) ) 


# Determine SUBMISSION INFO
# # presume no due date or timelimit
SUBMISSION_INFO=( ${LAST_COMMIT_INFO[@]} )

DUE_DATE_TS="${SUBMISSION_INFO[1]}"
TIME_LIMIT_TS="${SUBMISSION_INFO[1]}"

if [[ -f "${DUE_DATE_FILE}" ]] ; then
  DUE_DATE="$(cat ${DUE_DATE_FILE})"
  DUE_DATE_TS=$( date -j -f '%b %d %T' -v +${GRACE_PERIOD} "${DUE_DATE}" '+%s' )
fi

if [[ -f "${TIME_LIMIT_FILE}" ]] ; then
  TIME_LIMIT="$(cat ${TIME_LIMIT_FILE})"
  TIME_LIMIT_TS=$( date -r ${ACCEPT_INFO[1]} -v +${TIME_LIMIT} -v +${GRACE_PERIOD} '+%s' )
fi

if (( TIME_LIMIT_TS < DUE_DATE_TS )) ; then 
   SUBMISSION_TS=${TIME_LIMIT_TS}
else
   SUBMISSION_TS=${DUE_DATE_TS}
fi

TIMELIMIT_DUE_DATE_TS="${SUBMISSION_TS}"
TIMELIMIT_DUE_DATE="$(date -r ${SUBMISSION_TS} '+%b %d %T')"

# Determine the SUBMISSION INFORMATION
if (( SUBMISSION_TS < LAST_COMMIT_INFO[1] )) ; then
   SUBMISSION_INFO=( 
       $(git log --format='format:%h %ct' --before ${SUBMISSION_TS} -1) 
   )
fi


NUM_COMMITS="$(sed -n '$=' < .$$_full.log)"
if (( ${#SUBMISSION_INFO[@]} == 0 )) ; then
   SUBMISSION_HASH=""
   SUBMISSION_TS=""
   SUBMISSION_DATE=""

   NUM_COMMITS_POST_SUBMISSION="$NUM_COMMITS"
else
   SUBMISSION_HASH="${SUBMISSION_INFO[0]}"
   SUBMISSION_TS="${SUBMISSION_INFO[1]}"
   SUBMISSION_DATE="$(date -r ${SUBMISSION_INFO[1]} '+%b %d %T')"

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
if [[ -z "${SUBMISSION_DATE}" ]] ; then 
  STATUS="No Submission"
fi

### Final Information
MINUTES_LATE="$(( (${LAST_COMMIT_INFO[1]} - ${TIMELIMIT_DUE_DATE_TS}) / 60 ))"
   # Number of minutes the last commit was made after the final due date
if (( MINUTES_LATE <= 0 )) ; then
   MINUTES_LATE="Not applicable"
else
   MINUTES_LATE="${MINUTES_LATE} minutes late."
fi

cat > ${STUDENT_STAT_REPORT} <<EOF
# ASSIGNMENT STATISTICS REPORT

STATUS="${STATUS}"
MINUTES_LATE="${MINUTES_LATE}"

RELEASE_DATE="${RELEASE_DATE}"

ACCEPT_HASH="${ACCEPT_INFO[0]}"
ACCEPT_TS="${ACCEPT_INFO[1]}"
ACCEPT_DATE="$(date -r ${ACCEPT_INFO[1]} '+%b %d %T')"

GRACE_PERIOD="${GRACE_PERIOD}"
DUE_DATE="${DUE_DATE}"
TIME_LIMIT="${TIME_LIMIT}"

TIMELIMIT_DUE_DATE="${TIMELIMIT_DUE_DATE}"

SUBMISSION_HASH="${SUBMISSION_HASH}"
SUBMISSION_TS="${SUBMISSION_TS}"
SUBMISSION_DATE="${SUBMISSION_DATE}"

LAST_COMMIT_HASH="${LAST_COMMIT_INFO[0]}"
LAST_COMMIT_TS="${LAST_COMMIT_INFO[1]}"
LAST_COMMIT_DATE="$(date -r ${LAST_COMMIT_INFO[1]} '+%b %d %T')"

NUM_COMMITS="${NUM_COMMITS}"
NUM_COMMITS_POST_SUBMISSION="${NUM_COMMITS_POST_SUBMISSION}"
NUM_COMMITS_PRE_SUBMISSION="${NUM_COMMITS_PRE_SUBMISSION}"

TAGS=( $(git tag) )
EOF
 

