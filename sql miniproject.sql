-- 1. CREATE DATABASE
CREATE DATABASE FacultyProfileDB;
USE FacultyProfileDB;

-- 2. CREATE TABLES
-- Main Faculty table: Core profiles
CREATE TABLE Faculty (
    Faculty_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Phone VARCHAR(15),
    Hire_Date DATE NOT NULL,
    Bio TEXT  -- Long description
);

-- Publications table: Research papers/books
CREATE TABLE Publications (
    Pub_ID INT PRIMARY KEY AUTO_INCREMENT,
    Faculty_ID INT NOT NULL,
    Title VARCHAR(200) NOT NULL,
    Journal_Or_Publisher VARCHAR(100),
    Year INT NOT NULL CHECK (Year >= 1900 AND Year <= 2030),  -- Future-proof
    DOI VARCHAR(100),  -- Digital Object Identifier
    FOREIGN KEY (Faculty_ID) REFERENCES Faculty(Faculty_ID) ON DELETE CASCADE
);

-- Teaching Assignments table: Courses taught (FIXED: Semester VARCHAR(20))
CREATE TABLE Assignments (
    Assignment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Faculty_ID INT NOT NULL,
    Course_Code VARCHAR(20) NOT NULL,
    Course_Name VARCHAR(100) NOT NULL,
    Semester VARCHAR(20) NOT NULL,  -- FIXED: Bigger for 'Spring 2025' (11 chars) + more
    Credits INT DEFAULT 3,
    FOREIGN KEY (Faculty_ID) REFERENCES Faculty(Faculty_ID) ON DELETE CASCADE
);

-- Departments table: For better organization
CREATE TABLE Departments (
    Dept_ID INT PRIMARY KEY AUTO_INCREMENT,
    Dept_Name VARCHAR(50) UNIQUE NOT NULL,
    Head_Faculty_ID INT,
    FOREIGN KEY (Head_Faculty_ID) REFERENCES Faculty(Faculty_ID)
);

-- 3. INSERT SAMPLE DATA
-- Insert Departments first
INSERT INTO Departments (Dept_Name) VALUES
('Computer Science'),
('Mathematics'),
('Physics');

-- Insert Faculty
INSERT INTO Faculty (First_Name, Last_Name, Email, Department, Phone, Hire_Date, Bio) VALUES
('Alice', 'Johnson', 'alice.j@uni.edu', 'Computer Science', '555-0101', '2015-09-01', 'Expert in AI and machine learning. Published 20+ papers.'),
('Bob', 'Smith', 'bob.s@uni.edu', 'Mathematics', '555-0102', '2018-01-15', 'Specializes in algebra and geometry.'),
('Carol', 'Davis', 'carol.d@uni.edu', 'Physics', '555-0103', '2020-03-10', 'Quantum mechanics researcher.'),
('David', 'Wilson', 'david.w@uni.edu', 'Computer Science', '555-0104', '2017-07-20', 'Database systems and SQL guru.');

-- Update Dept Head (Alice heads CS)
UPDATE Departments SET Head_Faculty_ID = 1 WHERE Dept_Name = 'Computer Science';

-- Insert Publications
INSERT INTO Publications (Faculty_ID, Title, Journal_Or_Publisher, Year, DOI) VALUES
(1, 'AI in Education', 'IEEE Journal', 2023, '10.1109/AI.2023.123'),
(1, 'Neural Networks Basics', 'MIT Press', 2022, '10.7551/NN.2022.456'),
(2, 'Advanced Algebra Theorems', 'Math Review', 2021, '10.1000/MA.2021.789'),
(3, 'Quantum Entanglement', 'Physics Today', 2024, '10.1021/QE.2024.101'),
(4, 'Optimizing SQL Queries', 'DB Magazine', 2023, '10.1145/SQL.2023.202');

-- Insert Assignments (Now error-free!)
INSERT INTO Assignments (Faculty_ID, Course_Code, Course_Name, Semester, Credits) VALUES
(1, 'CS101', 'Intro to Programming', 'Fall 2025', 3),
(1, 'CS501', 'Machine Learning', 'Spring 2025', 4),  -- This one was too long—fixed!
(2, 'MATH201', 'Linear Algebra', 'Fall 2025', 3),
(3, 'PHYS301', 'Quantum Mechanics', 'Fall 2025', 4),
(4, 'CS401', 'Database Design', 'Fall 2025', 3);

-- 4. VIEW ALL DATA (Basic SELECTs)
-- View all Faculty
SELECT * FROM Faculty ORDER BY Last_Name;

-- View all Publications
SELECT * FROM Publications ORDER BY Year DESC;

-- View all Assignments (Should show 5 rows now!)
SELECT * FROM Assignments ORDER BY Semester;

-- View all Departments
SELECT * FROM Departments;

-- 5. ADD NEW DATA (INSERT Examples)
-- Add a new Faculty member
INSERT INTO Faculty (First_Name, Last_Name, Email, Department, Phone, Hire_Date, Bio) 
VALUES ('Eve', 'Brown', 'eve.b@uni.edu', 'Mathematics', '555-0105', '2025-09-01', 'New hire in statistics.');

-- Add a Publication for the new Faculty (ID=5)
INSERT INTO Publications (Faculty_ID, Title, Journal_Or_Publisher, Year, DOI) 
VALUES (5, 'Stats in Data Science', 'Journal of Stats', 2025, '10.9999/DS.2025.303');

-- Add an Assignment for Faculty ID 5
INSERT INTO Assignments (Faculty_ID, Course_Code, Course_Name, Semester, Credits) 
VALUES (5, 'MATH301', 'Statistics 101', 'Fall 2025', 3);

-- 6. UPDATE DATA (Example)
-- Update a Faculty's bio and phone
UPDATE Faculty 
SET Bio = 'Updated: Now focusing on deep learning.', Phone = '555-0106' 
WHERE Faculty_ID = 1;

-- Update a Publication's year (if correction needed)
UPDATE Publications 
SET Year = 2024 
WHERE Pub_ID = 1 AND Year < 2024;

-- 7. DELETE DATA (Example)
-- Delete a specific Publication (by ID)
DELETE FROM Publications WHERE Pub_ID = 2;

-- Delete an Assignment (by ID) - Now safe with existing IDs
DELETE FROM Assignments WHERE Assignment_ID = 6;  -- Deletes Eve's if run after INSERT

-- 8. ADVANCED QUERIES (Reports)
-- Report 1: All Faculty with their Publications (JOIN)
SELECT 
    f.First_Name, f.Last_Name, f.Department, f.Hire_Date,
    p.Title, p.Year, p.Journal_Or_Publisher
FROM Faculty f
LEFT JOIN Publications p ON f.Faculty_ID = p.Faculty_ID
ORDER BY f.Last_Name, p.Year DESC;

-- Report 2: Faculty with Teaching Assignments
SELECT 
    f.First_Name, f.Last_Name, f.Email,
    a.Course_Code, a.Course_Name, a.Semester
FROM Faculty f
INNER JOIN Assignments a ON f.Faculty_ID = a.Faculty_ID
ORDER BY f.Department, a.Semester;

-- Report 3: Publications by Department (Grouped)
SELECT 
    f.Department,
    COUNT(p.Pub_ID) AS Total_Pubs,
    AVG(p.Year) AS Avg_Year
FROM Faculty f
LEFT JOIN Publications p ON f.Faculty_ID = p.Faculty_ID
GROUP BY f.Department
HAVING Total_Pubs > 0
ORDER BY Total_Pubs DESC;

-- Report 4: Faculty Hired After 2018 with No Publications
SELECT 
    First_Name, Last_Name, Department, Hire_Date
FROM Faculty
WHERE Hire_Date > '2018-12-31'
AND Faculty_ID NOT IN (SELECT DISTINCT Faculty_ID FROM Publications)
ORDER BY Hire_Date;

-- 9. BONUS: STORED PROCEDURE (Simple Report)
DELIMITER //
CREATE PROCEDURE GetFacultyWithPubCount(IN dept_filter VARCHAR(50))
BEGIN
    SELECT 
        f.First_Name, f.Last_Name, f.Department,
        COUNT(p.Pub_ID) AS Num_Publications
    FROM Faculty f
    LEFT JOIN Publications p ON f.Faculty_ID = p.Faculty_ID
    WHERE dept_filter = '' OR f.Department = dept_filter
    GROUP BY f.Faculty_ID, f.First_Name, f.Last_Name, f.Department
    ORDER BY Num_Publications DESC, f.Last_Name;
END //
DELIMITER ;

-- Call the Procedure (e.g., for Computer Science)
CALL GetFacultyWithPubCount('Computer Science');

-- Call for All Departments
CALL GetFacultyWithPubCount('');