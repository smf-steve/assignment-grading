LAUNCH=open -a
	# The command used to launch the GRADING_EDITOR
	# On MacOS, the command is "open -a"
	# On Windows 10, the command is "start" 
	# For a binary (launched via the CLI), the command is ""

EDITOR="subl"
	# The default tool to open the students submission
	# since this program is an application bundle, make sure to provide the -a option to the LAUNCH_COMMAND

RESPONSE_TAG='<!-- response -->'
	# The standardize tag to "grep" for within the student's submission to locate just the responses to review

STUDENT_GRADE_REPORT="grade.report"
DUE_DATE=Mar 12 23:59:59


paper_grade: log_info submission.md 
	@ # $(LAUNCH) $(EDITOR) submission.md submission.stripped.md
	$(EDITOR) submission.md submission.stripped.md

submission.stripped.md: submission.md
	 egrep "(^#|$(RESPONSE_TAG))" submission.md | sed "s/^ *\(.* *\)$(RESPONSE_TAG)/\1 /" > submission.stripped.md
	@echo

log_info:
	@ git log -1 --decorate       # Show if they are one HEAD -> main
	@ git log --format="%h %cn %b %at" 
	@ bash -lc "ag_show_commit_log '$(DUE_DATE)'"