# Class Assignments and Grading Support

## Summary:
Students within Computer Science and Computer Information Technology programs are better served if they learn and utilize source control systems early in their academic program. Learning various markdown lanagues, which are used to document they software projects, is also advantages.

A such, I decided to use GitHub Classrooms for all of my paper-like assignments, which includes quizzes and exams.  While using a traditional LMS (Learning Managment System) might be a better fit such assignment, there is little long-term benefit to my students. My approach allows me to introduce git and the markdown format to the students early in their academic program. As they progress through the academic program, they can further enhance their knowledge of the utility of source control systems, etc.


Grading of these assignments, however, became a bit more tedious. As such, I created this repository to  provide a set of tools to facilate the review and grading of paper-like assignments. This grading process relies an a set of conventions. Student submit their assignment using github classroom with specific named files used using .md (markdown) format.  (Although visual file format can be used, e.g., .pdf, .doc, and .txt.

As part this review process, the student's repository is modified to include the offical answers to the assignment and a grade report.


## Overarching Goal:
  1. To facilate the review and grading process of student paper-like assignments submitted via GitHub Classroom 

## Additional Beeficial Goals:
  1. To engage the student's usage of git early in the academic process
     * to make them aware of the utility of such source control systems
     * to allow them to become more proficient in using git
     * to prepare them to use git for further use in their academic careers
  1. To have students learn and utilize a markdown language for documentation, etc.


## Assignment Repository Structure
For each assignment, a student will create a repository from a template repository using the standard GitHub Classroom process. The student's repository will contain, at least the following files:
  1. README.md: general instructions to the students on the Assignment Submission Process 
  1. assignment.md: the original unmodified copy of assignment to be completed by the student.
  1. submission.md: the modified copy of the assignment that incorporates the student's answers

As part of the grading process the following files will be added to the students repository:
  1. answers.md: a modified copy of the assignment that incorporates the professor's answers
  1. grade.report: a break down of the assigned grade based upon a grading rubric


## Assignment and Review Process:
  1. Create the assignment via the normal GitHub / Github Classroom process
  1. Clone the template repository for the assignment, say ``assignment #1``
  1. Create a grading rubric: ./``assignment #1``/grading_rubric
  1. Create the answer key:  ./``assignment #1``/answers.md
  1. Modify the assignment.env to override any defaults (optional)
  1. Source the ../grade.bash script
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
     git clone <this_repository>
     cd assignment-grading
     ```
  1. Update the grade.env file to provide information about the GitHub Classroom 
     ```
     GITHUB_ORG="CIT384"
     CLASSROOM_URL="https://classroom.github.com/classrooms/89051846-cit384-f21"
     ROOT_DIR="~/comp122/private"
     ```
  1. Create a text file, called roster, that contains a list of all of the student's github accounts.

  1. Modify the classroom.env file that defines the following
     ```
     CLASSROOM_URL="https://classroom.github.com/classrooms/89051846-cit122-f21"

     ```
  1. Review the sample_assignment directory for additional information on 

### File Structure
The following directory structure depicts 
  * assignment_grading: (this_directory)
    * README.md: this file 
    * grade.bash: a bash script that supports grading of paper-like assignments
    * roster: a text file that contains a list of student's git accounts 
    * grades.``assignment #1``
    * grades.``assignment #2``
    * ...
    * grades.``assignment #n``
    * ``assignment #1``: directory for ``assignment #1``
      * README.md: 
      * assignment.md: the original assignment
      * answers.md: the official answers to assignment
      * rubric.grading: defined grading rubric
      * submissions: directory for all student submissios
        * ``student submission #1``
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
