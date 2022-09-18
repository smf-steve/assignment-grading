# Installation, Assignment, and Grading Process

## Prerequisites:
   - Establish a Github Account (with ssh-key authentication)
   - Create a Github Organization for a GitHub Classroom: *${GITHUB_ORG}*
   - Enroll in Github Classroom
   - Create a Github Classroom and identify it's URL: *${CLASSROOM_URL}*
   - Upload a class roster, which students will use to link to their GitHub accounts.

## Installation Process for a Single Class (*${CLASSROOM_DIR}*)
This software package and it's define file structure has been designed to support a single class. As such, you need to download this package once for each class.  

The following example shows how I installed the software for my COMP122 class.
  1. Install this software package.
     ```
     mkdir -p ~/comp122
     cd ~/comp122            # ${CLASSROOM_DIR}
     git clone git@github.com:smf-steve/assignment-grading.git
     cd assignment-grading
     ```
  1. Update the .grading.env file to provide information about the GitHub Classroom.
     ```
     GITHUB_ORG="CIT122"
     ```
  1. Create a text file, called roster, that contains a list of all of the student's Github Accounts.
     ```
     # download the classroom roster from github: classroom_roster.csv
     awk -F, '{print $2}' classroom_roster.csv | sed -e '1d' -e 's/"//g' > roster
     ```

## Assignment Creation Process:
  * Create an Assignment-Template Repository
     1. Create an repository with your GitHub Organization.
     1. Add, at least, the following files to that repository:
        - README.md
        - assignment.md
     1. Modify this assignment to be a template repository.
     1. Create the assignment in GitHub Classroom.
        - I recommend using a two-digit naming scheme for the assignment prefix
        - For example,
          * 42: denotes the 2nd assignment in the 4th section of the class
          * 40: denotes the exam/quiz for the 4th section of the class
          * \<assignment_name\>: the name of the GitHub assignment
          * 42-<assignment_name>: the name of the GitHub assignment prefix
          * 42-<assignment_name>-<student>: the repository for \<student\>
     1. Distribute the assignment invitation to your students.
  * Create an Assignment-Solution Repository
     1. Create an private repository based upon the assignment template.
     2. Add, at least, the following files to that repository:
        - ``answers.md``
        - ``grading.rubric``
        - ``makefile``: (optional): to address non-paper submissions
        - ``grading.env``: (optional) to override defaults


## Assignment Setup Process:
 1. Create a directory for the assignment within the ``assignment_grading/`` directory.  The name of the directory must match the GitHub Classroom assignment prefix. For example:

    ```
    cd ~/comp122/assignment_grading
    mkdir nn-assignment-name
    ```

 1. Clone the assignment-solution repository into the ``key`` directory
     ```
     cd nn-assignment-name
     git clone git@github.com:COMP122/assignment-name.git key
     cd 01-assignment
     ```
    - A directory called submissions is created that contains all of the student submissions, and
      * submissions.log: a log of all git commands performed during the grading process.
      * roster: a list of students that have accepted the assignment
      * non_submission.roster: a list of students that have accepted the assignment


## Grading and Review Process
  1. Change your current working directory to be the assignment directory
     ```
     cd ~/comp122/assigment_grading
     cd nn-assignment-name
     ```

  1. Source the grade.bash file:
     - ``source ../bin/grade.bash``  

  1. Execute various CLI commands within the assignment directory
     1. ``grade_start``: to start the grading process, which reasserts the environment variables
     1. ``clone_submissions``: to obtain a copy of all the student's files
     1. ``pull_submissions``: to obtain a fresh copy of all the student's files
     1. ``grade_submissions``: to grade all the student's submissions
     1. ``publish_grades``: to publish the grades for all students
  1. Review class grades contained within ``../grades.nn-assignment``
  1. Update the master grade spreadsheet for all students

## Regrading a Single Student's Submission
  1. ``cd ~/comp122/assignment_grading/nn-assignment``
  1. ``grade_start``: to start the grading process, which reasserts the environment variables
  1. ``clone_submission student``: to obtain a copy of the student's files
  1. ``pull_submission student``: to pull the student's repo for possible updates
  1. ``grade_submission student``: to grade student's submission
  1. ``publish_grade student``: to publish the student's grad
  1. Review updated grades append to ``../grades.nn-assignment``
  1. Update the individual grade within the master grade spreadsheet

