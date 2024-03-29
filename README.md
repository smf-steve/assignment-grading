# Class Assignments and Grading Support

> See [Installation, Assignment, and Grading Process](https://github.com/smf-steve/assignment-grading/blob/main/process.md) for further instructions

## Summary:
Students within Computer Science and Computer Information Technology programs are better served if they learn and utilize source control systems early in their academic program. Learning various markdown languages, which are used to document their software projects, is also advantages.

A such, I decided to use GitHub Classrooms for all of my paper-like assignments, which includes quizzes and exams. While using a traditional LMS (Learning Management System) might be a better fit such activities, there is little long-term benefit to my students in becoming proficient users of an LMS. My approach to using [Github Classrooms](https://classroom.github.com) for paper-like submissions allows me to introduce git and the markdown format to the students early in their academic program. As they progress through the academic program, they can further enhance their knowledge of and the utility of source control systems, etc.

Grading of these assignments, however, became a bit more tedious. As such, I created this repository to provide a set of tools to facilitate the review and grading of paper-like assignments. This grading process relies an a set of conventions. Students submit their assignment using Github Classroom with specific named files used using .md (markdown) format. (Although visual file format can be used, e.g., .pdf, .doc, and .txt.)

As part this review process, the student's repository is modified to include the official answers to the assignment and a grade report. A summary file containing the scoring for all student's assingments is created. 

## Overarching Goal:
To facilitate the review and grading process of student paper-like assignments submitted via GitHub Classroom 

## Additional Beneficial Goals:
  1. To engage the student in the use of git early in the academic process:
     * to make them aware of the utility of source control systems
     * to allow them to become more proficient in using git
     * to prepare them to use git for further use in their academic careers
  1. To have students learn and utilize a markdown language for documentation, etc.

---
## Overiew of Associated Repositories:
A number of different repositories are utilized by the grading process.  These repositories are:
  1. an assignment-template repository 
  1. an assignment-solution repository 
  1. a student's submission repository

The structure of these repositories are provided below.

### Assignment-Template Repository Structure:
For each assignment, the Professor creates a template repository.  This template repository is used by GitHub classroom to create a repository for each student.  This template repostory contains, at least the following files:
  * `README.md`: general instructions on the "Assignment Submission Process"
  * `assignment.md`: the original version of the assignment.


### Assignment-Solution Repository Stucture:
For each assignment, the Professor creates a repository that extends the template repostory by adding (at least) the following files:
  * `answers.md`: the assignment with the Professor's answers incorporated
  * `grading_rubric`: a list of individual items used to score the assignment
  * `rubric_description`: an optional description about the rubric
  * `makefile`: (optional) a file used to review and to evaluate a student submission

### Student's Assignment Repostory Structure:
For each assignment, each student is provided with a unique repository that extends the template repository.  Some of these files are added by the student, which is there submission, and Some of these files are added as part of the grading process.

These files include:
  * `README.md`: general instructions on the "Assignment Submission Process"
  * `assignment.md`: the original version of the assignment.
  * `submission.md`: the assignment with the student's answers incorporated
  * `answers.md`: the assignment with the Professor's answers incorporated
  * `grade.report`: the final grade with a break down of individual scores

---
## Assignment Grading File Structure:
To faciliate the grading process, a single directory (per class) is created.  As assignments are distributed, collected, and graded, additional files are added to this file structure.  This structure is defined as follows:
  * the directory structure for this class: *${CLASSROOM_DIR}*
  * `assignment_grading/`: (this directory)
    * `README.md`: this file 
    * `classroom_roster.csv`: the class roster downloaded from GitHub Classrooom
    * `roster`: a text file that contains a list of student's git accounts 
    * `grades.xx-sample-assignment.txt`: grades for sample assignment

    * `xx-sample-assignment/`: a sample assignment
      * `release_date`: the date in which the assignment was released
      * `due_date`: the date in which the assignment is due
      * `time_limit`: the amount of time after the student as accepted
      * `grace_period`: the amount of time for a grace period

      * `key/`: a directory to store the Professor's solution 
        * `README.md`: general instructions on the submission process
        * `assignment.md`: the original assignment
        * `answers.md`: the official answers to the assignment
        * `grading_rubric`: defined grading rubric
      * `submissions/`: a directory to store each of the student's submissions 


---
## Known Limitations and Bugs

   * A class is held within a calendar year (dates don't include the year)
