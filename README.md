# 🎓 Kindergarten Student Learning Progress System for Keedflix Centre

> A web-based management and progress tracking system designed for **Keedflix Centre** to streamline student enrollment, track weekly learning progress, and facilitate parent-teacher interaction.


## 📌 Project Overview

**Keedflix Centre System** is built to solve the inefficiencies of manual student record-keeping and progress reporting. By digitizing student profile management, class management, and learning achievements (Reading, Writing, and Counting), this system provides real-time insights for teachers and administrators while keeping parents informed.

### Key Features

* **Centralized Dashboard**: High-level overview of student enrollment metrics, class progress averages, and activity logs.
* **Student & Parent Enrollment**: Multi-step registration portal for linking parent credentials with student profiles.
* **Student Directory**: Quick search, filtering by class, and printable student rosters.
* **Learning Progress Tracking**: Detailed evaluation metrics for early learning skills including Phonics, Reading Levels, Letter Tracing, and Shape/Number Recognition.
* **User Profile Management**: Self-service profile updates with role-based accessibility for Admin, Teachers, and Parents.


## 🛠️ Tech Stack & Architecture

* **Backend**: Java Servlets, JSP (JavaServer Pages)
* **Database**: Oracle Database (DBMS)
* **Frontend**: HTML5, CSS3 (*Neobrutalism UI style*), JavaScript
* **Web Server**: Apache Tomcat
* **IDE / Tools**: Eclipse IDE, Git


## 🗄️ Database Schema Summary

The system database runs on **Oracle DBMS** and consists of 11 normalized tables:

1. **Teacher**: Admin and teacher credentials, contact info, and role access.
2. **Parent**: Contact details and personal profiles of parents.
3. **Student**: Student profiles, age, class assignments, and parent linkages.
4. **Class**: Classroom details and academic year allocations.
5. **Chat**: Communication logs between parents and teachers.
6. **News**: Announcements and weekly news posts.
7. **LearningProgress**: Achievement metrics, status logs, and percentages.
8. **Learning**: Master categories for curriculum fields.
9. **Reading**: Phonics status and reading level evaluations.
10. **Writing**: Letter tracing and writing exercise metrics.
11. **Counting**: Number ranges, object counting, and shape recognition records.

## 👤 Author

* **Farahanis Suraya Binti Ahmad Kamal** - *Information System Engineering*
