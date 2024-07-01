CREATE TABLE Students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone_number VARCHAR(16),
    address VARCHAR(120),
    enrollment_date DATE NOT NULL,
    gpa REAL
);

CREATE TABLE Courses (
	course_id SERIAL PRIMARY KEY,
	course_name VARCHAR(40) NOT NULL,
	description VARCHAR(300),
	credits int NOT NULL,
	department VARCHAR(50) NOT NULL
);

CREATE TABLE Enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES Students(student_id) ON DELETE CASCADE,
    course_id INT REFERENCES Courses(course_id),
    enrollment_date DATE NOT NULL,
    grade INT
);

INSERT INTO Students (first_name, last_name, date_of_birth, email, phone_number, address, enrollment_date, gpa)
VALUES
('John', 'Doe', '2000-01-15', 'john.doe@example.com', '1234567890', '123 Main St', '2024-06-01', 3.5),
('Jane', 'Smith', '2001-02-20', 'jane.smith@example.com', NULL, '456 Elm St', '2024-06-01', NULL),
('Alice', 'Johnson', '1999-03-25', 'alice.johnson@example.com', '0987654321', '789 Oak St', '2024-06-01', 3.8),
('Bob', 'Brown', '2002-04-10', 'bob.brown@example.com', NULL, NULL, '2024-06-01', 2.9),
('Charlie', 'Davis', '2000-05-05', 'charlie.davis@example.com', '5556667777', '321 Pine St', '2024-06-01', NULL);

INSERT INTO Courses (course_name, description, credits, department)
VALUES
('Mathematics', 'Advanced mathematics course', 3, 'Science'),
('History', 'World history overview', 4, 'Humanities'),
('Computer Science', 'Introduction to programming', 3, 'Technology');

INSERT INTO Enrollments (student_id, course_id, enrollment_date, grade)
VALUES
(1, 1, '2024-06-02', NULL),
(2, 2, '2024-06-02', 3),
(3, 3, '2024-06-02', 4),
(4, 1, '2024-06-02', NULL),
(5, 3, '2024-06-02', 2);

UPDATE Students SET address = 'new address', phone_number='1114567890'  WHERE student_id = 1;
UPDATE Courses SET description = 'new description' WHERE course_id = 1;
UPDATE Enrollments SET grade = '5' WHERE student_id = 1 AND course_id = 1;

DELETE FROM Students
WHERE student_id = 1;

DELETE FROM Courses
WHERE course_id NOT IN (
    SELECT DISTINCT course_id
    FROM Enrollments
);

---1
SELECT Students.student_id, Students.first_name, Students.last_name, Students.email, Students.phone_number
FROM Students 
JOIN Enrollments ON Students.student_id = Enrollments.student_id 
WHERE Enrollments.course_id = 1 
ORDER BY last_name;

---2
SELECT Courses.course_id, Courses.course_name, COUNT(Enrollments.student_id) as students 
FROM Courses 
LEFT JOIN Enrollments ON Courses.course_id = Enrollments.course_id
GROUP BY Courses.course_id, Courses.course_name
ORDER BY students DESC;

---3
SELECT Students.student_id, Students.first_name, Students.last_name, Students.gpa 
FROM Students
WHERE gpa > 2
ORDER BY gpa DESC;

---4
SELECT Students.first_name, Students.last_name, Courses.course_name, Enrollments.enrollment_date
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
JOIN Courses ON Enrollments.course_id = Courses.course_id
WHERE Enrollments.enrollment_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
AND Enrollments.enrollment_date < DATE_TRUNC('month', CURRENT_DATE)
ORDER BY Enrollments.enrollment_date DESC;

---5
SELECT Students.student_id, Students.first_name, Students.last_name, Students.email, Students.phone_number 
FROM Students 
LEFT JOIN Enrollments ON Students.student_id=Enrollments.student_id
WHERE phone_number IS NULL 
ORDER BY Enrollments.enrollment_date DESC;

---6
SELECT course_name, department, credits 
FROM Courses 
WHERE department = 'Science' 
ORDER BY credits DESC;

--7
SELECT Students.*, Enrollments.grade, Courses.course_name 
FROM Students 
INNER JOIN Enrollments ON Students.student_id = Enrollments.student_id  
INNER JOIN Courses ON Enrollments.course_id=Courses.course_id;

--8
SELECT Students.student_id, Students.first_name, Students.last_name, COUNT(Enrollments.student_id) as courses
FROM Students
INNER JOIN Enrollments ON Enrollments.student_id = Students.student_id
GROUP BY Students.student_id
HAVING COUNT(Enrollments.student_id) > 1;

--9
SELECT DISTINCT Students.student_id, Students.first_name, Students.last_name
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
JOIN Courses ON Enrollments.course_id = Courses.course_id
WHERE Students.student_id IN (
    SELECT student_id
    FROM (
        SELECT student_id, COUNT(DISTINCT Courses.department) AS dep_count
        FROM Enrollments
        JOIN Courses ON Enrollments.course_id = Courses.course_id
        GROUP BY student_id
        HAVING COUNT(DISTINCT Courses.department) > 1
    ) AS subquery
)
ORDER BY Students.student_id;

--10
SELECT Courses.course_id, Courses.course_name
FROM Courses
LEFT JOIN Enrollments ON Courses.course_id = Enrollments.course_id
WHERE Enrollments.course_id IS NULL
ORDER BY Courses.course_id;

--11
SELECT Students.student_id, Students.first_name, Students.last_name
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
JOIN Courses ON Enrollments.course_id = Courses.course_id
WHERE Courses.department = 'Science'
GROUP BY Students.student_id
HAVING COUNT(DISTINCT Courses.course_id) = (
    SELECT COUNT(*)
    FROM Courses
    WHERE department = 'Science'
);

--12
SELECT Students.student_id, Students.first_name, Students.last_name, Courses.course_name, Courses.credits
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
JOIN (
    SELECT course_id, course_name, credits
    FROM Courses
    WHERE credits = (
        SELECT MAX(credits)
        FROM Courses
    )
) Courses ON Enrollments.course_id = Courses.course_id
ORDER BY Courses.credits DESC, Students.student_id;

--13
SELECT Students.student_id, Students.first_name, Students.last_name, AVG(Enrollments.grade) AS avg_gpa
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
WHERE Enrollments.grade IS NOT NULL
GROUP BY Students.student_id
ORDER BY avg_gpa DESC;

--14
SELECT DISTINCT Students.student_id, Students.first_name, Students.last_name, Enrollments.enrollment_date
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
WHERE Enrollments.enrollment_date >= CURRENT_DATE - INTERVAL '1 year'
ORDER BY Students.student_id;

--15
SELECT Students.student_id, Students.first_name, Students.last_name, COUNT(Enrollments.course_id) AS num_courses
FROM Students
LEFT JOIN Enrollments ON Students.student_id = Enrollments.student_id
GROUP BY Students.student_id
ORDER BY num_courses DESC, Students.student_id;

--VIEW
CREATE VIEW StudentEnrollments AS
SELECT Students.*, Courses.course_name, Courses.department, Courses.description, Enrollments.grade
FROM Students
JOIN Enrollments ON Students.student_id = Enrollments.student_id
JOIN Courses ON Enrollments.course_id = Courses.course_id;

SELECT *
FROM StudentEnrollments;

--Procedure
CREATE OR REPLACE PROCEDURE AddnEnrollStudent(
    IN p_first_name VARCHAR(40),
    IN p_last_name VARCHAR(40),
    IN p_date_of_birth DATE,
    IN p_email VARCHAR(120),
    IN p_phone_number VARCHAR(16),
    IN p_address VARCHAR(120),
    IN p_course_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
 	p_student_id INT;
BEGIN
    INSERT INTO Students (first_name, last_name, date_of_birth, email, phone_number, address, enrollment_date)
    VALUES (p_first_name, p_last_name, p_date_of_birth, p_email, p_phone_number, p_address, CURRENT_DATE)
    RETURNING student_id INTO p_student_id;

    INSERT INTO Enrollments (student_id, course_id, enrollment_date)
    VALUES (p_student_id, p_course_id, CURRENT_DATE);

    COMMIT;
END $$;

CALL AddnEnrollStudent('Fname', 'Lname', '2000-01-01', 'fl@example.com', '+123456789', 'address', 1);