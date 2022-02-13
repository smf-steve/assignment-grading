LAUNCH=open -a
  # The command used to launch the GRADING_EDITOR
  # On MacOS, the command is "open -a"
  # On Windows 10, the command is "start" 
  # For a binary (launched via the CLI), the command is ""

EDITOR="/Applications/Sublime Text.app"
  # The default tool to open the students submission
  # since this program is an application bundle, make sure to provide the -a option to the LAUNCH_COMMAND

RESPONSE_TAG='<!-- response -->'
  # The standardize tag to "grep" for within the student's submission to locate just the responses to review


paper_grade: submission.md submission.md.txt
	echo rm -f $(STUDENT_GRADE_REPORT)
	$(LAUNCH) $(EDITOR) submission.md submission.md.txt

submission.md.txt: submission.md
	 grep -e $(RESPONSE_TAG) submission.md > submission.md.txt

