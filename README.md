# Class Assignments and Grading Support

## Summary:
This repository provides a set of tools used to review and to grade paper-like assignments.  Such assignments have been submitted by student via GitHub Classrooms. 

## Goals:
  1. To promote the use of GitHub Classroom for the use of student's submission
  1. To have students learn and utilize a markdown language for documentation, etc.
  1. To engage the student's usage of git early in the academic process
     * to make them aware of the utility of such source control systems
     * to allow them to become more proficient in using git
     * to prepare them to use git for further use in their academic careers
  1. To facilate the review and grading process of student assignments

## Description:
Github Classroom is an excellent tool to support the submission of student's homework assignments and projects.  Via the use of Github Classroom, students become increasing more proficient in the use of git for software projects.

This repository has been created to faciliate the review and grading of student assignments submitted via Github Classroom. It is envisioned that such assignments are traditional paper-based assignments that need to be reviewed by the professor.  As part this review process, the student's repository is modified to include the offical answers to the assignment and a grade report.  

Although any number of Learning Management Systems (LMS) can be used to support student homework submission and grading, the ongoing use of such systems after graduation is limited.  Their use of a source control system, like git, however, is an investment in their professional careers.

## Assignment Repository Structure
For each assignment, a student will create a repository from a template repository. The student's repository will contain, at least the following files:
  1. README.md: general instructions to the students on the Assignment Submission Process 
  1. assignment.md: the original unmodified copy of assignment to be completed by the student.
  1. submission.md: the modified copy of the assignment that incorporates the student's answers

As part of the grading process the following files will be added to the repository:
  1. answers.md: a modified copy of the assignment that incorporates the professor's answers
  1. grade.report: a break down of the assigned grade based upon a grading rubric


## Assignment and Review Process:
  1. Create the assignment via the normal Github / Github Classroom process
  1. Clone the template repository for the assignment, say ``assignment #1``
  1. Change your working directory to ``assignment #1``
  1. Create a grading rubric: ./``assignment #1``/grading_rubric
  1. Create the answer key:  ./``assignment #1``/answers.md
  1. Source the ../grade.bash script
     - Do I need to update an envirnonment Variables
  1. Execute various CLI commands within the ./assignment_1 directory
     1. clone_submissions
     1. grade_submissions
     1. publish_grades
  1. Review class grades contained within ./grades.``assignment #1``


## Installation Process and Defined File Structure
This software package and it's define file structure has been designed to support a single class.  As such, you need to download this package once for each class.  

The following example shows how I installed the software for my COMP122 class.
 1. Install this software package
    ```
    mkdir -p ~/comp122/private
    cd ~/comp122/private
    git clone <this_repository> assignments
    cd assignments
    ```
 1. Update the grade.env file to provide information about the GitHub Classroom 
    ```
    GITHUB_ORG="CIT384"
    CLASSROOM_URL="https://classroom.github.com/classrooms/89051846-cit384-f21"
    ROOT_DIR="~/comp122/private"
    ```
 1. Create a text file, called roster, that contains a list of all of the student's github accounts.

 1. Create a .env file that defines the following
 ```

 ```

The following directory structure depicts 
  * assignments: (this_directory)
    * README.md: this file 
    * grade.bash: a bash script that supports grading 
    * roster: a text file that contains a list of student's git accounts 
    * ``assignment #1``.grades: class grades for ``assignment #1``
    * ``assignment #2``.grades
    * ...
    * ``assignment #n``.grades
    * ``assignment #1``: directory for ``assignment #1``
      * README.md: 
      * assignment.md: the original assignment
      * answers.md: the official answers to assignment
      * rubric.grading: defined grading rubric
      * submissions: directory for all student submissios
        * ``student submission #1``: repo for student #1
          * README.md
          * assignment.md
          * submission.md
          * answers.md
          * grade.report
        * ``student submission #2``
        * ...
        * ``student submission #n``
    * ``assignment #2``
    * ...
    * ``assignment #n``          
