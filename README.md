# Class Assignments and Grading Support

> See [Installation, Assignment, and Grading Process](https://github.com/smf-steve/assignment-grading/blob/main/process.md) for further instructions

## Summary:
Students within Computer Science and Computer Information Technology programs are better served if they learn and utilize source control systems early in their academic program. Learning various markdown languages, which are used to document they software projects, is also advantages.

A such, I decided to use GitHub Classrooms for all of my paper-like assignments, which includes quizzes and exams. While using a traditional LMS (Learning Management System) might be a better fit such activities, there is little long-term benefit to my students in become proficient users of an LMS. My approach to using [Github Classrooms](https://classroom.github.com) for paper-like submissions allows me to introduce git and the markdown format to the students early in their academic program. As they progress through the academic program, they can further enhance their knowledge of the utility of source control systems, etc.

Grading of these assignments, however, became a bit more tedious. As such, I created this repository to provide a set of tools to facilitate the review and grading of paper-like assignments. This grading process relies an a set of conventions. Student submit their assignment using Github Classroom with specific named files used using .md (markdown) format. (Although visual file format can be used, e.g., .pdf, .doc, and .txt.

As part this review process, the student's repository is modified to include the official answers to the assignment and a grade report. A summary file containing the scoring for all students is created. 

## Overarching Goal:
  1. To facilitate the review and grading process of student paper-like assignments submitted via GitHub Classroom 

## Additional Beneficial Goals:
  1. To engage the student in the use of git early in the academic process.
     * to make them aware of the utility of such source control systems.
     * to allow them to become more proficient in using git.
     * to prepare them to use git for further use in their academic careers.
  1. To have students learn and utilize a markdown language for documentation, etc.

## Assignment Repository Structure
For each assignment, a student will create a repository from a template repository using the standard GitHub Classroom process. The student's repository will contain, at least the following files:
  1. README.md: general instructions to the students on the "Assignment Submission Process"
  1. assignment.md: the original unmodified copy of the assignment to be completed by the student.
  1. submission.md: the modified copy of the assignment that incorporates the student's answers

As part of the grading process the following files will be added to the students repository:
  1. answers.md: a modified copy of the assignment that incorporates the professor's answers
  1. grade.report: a break down of the assigned grade based upon a grading rubric


## Class File Structure
As a consequence of installing and using this repository, the following file structure will be created:
  * assignment_grading: (this_directory)
    * ``sample_assignment``: 
      - a directory that contains a sample assignment
    * README.md: this file 
    * grade.bash: a bash script that supports grading of paper-like assignments
    * roster: a text file that contains a list of student's git accounts 
    * ``grades.01-assignment``
    * ``grades.02-assignment``
    * ...
    * ``grades.nn-assignment``
    * ``01-assignment``: directory for ``assignment``
      * ``README.md``: general instructions on the submission process
      * ``assignment.md``: the original assignment
      * ``answers.md``: the official answers to assignment
      * ``rubric.grading``: defined grading rubric
      * ``submissions``: directory for all student submissions
        * ``01-assignment-student-id``
          * README.md
          * assignment.md
          * submission.md
          * answers.md
          * grade.report
        * ``01-assignment-student-id2``
        * ...
        * ``01-assignment-student-idN``
    * ``02-assignment``
    * ...
    * ``nn-assignment``
