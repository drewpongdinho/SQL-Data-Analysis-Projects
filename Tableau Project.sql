-- This data was acquired from a well-known GitHub respository.
-- Original data created by Fusheng Wang and Carlo Zaniolo:
-- http://www.cs.aau.dk/TimeCenter/software.htm
-- http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- This data is fabricated and does not correspond to any real data.
-- Create a visualisation that provides a breakdown between the male and female employees
-- working in the company each year, starting from 1990.

SELECT 
    YEAR(t_dept_emp.from_date) AS Year,
    t_employees.gender,
    COUNT(t_employees.emp_no) AS Num_Of_Employees
FROM
    t_employees
        INNER JOIN
    t_dept_emp ON t_dept_emp.emp_no = t_employees.emp_no
GROUP BY Year , t_employees.gender
HAVING Year >= 1990;

-- Compare the number of male managers to number of female managers from different 
-- departments for each year starting from 1990
    
SELECT
		t_departments.dept_name,
        t_employees.gender,
        t_dept_manager.emp_no,
        t_dept_manager.from_date,
        t_dept_manager.to_date,
        CY.calendar_year,
        CASE
			WHEN YEAR(t_dept_manager.to_date) >= CY.Calendar_Year AND YEAR(t_dept_manager.from_date) <= CY.Calendar_Year THEN 1
            ELSE 0
		END AS Active
FROM
	(SELECT
		YEAR(hire_date) AS Calendar_Year 
	FROM 
		t_employees
	GROUP BY Calendar_Year) AS CY
		CROSS JOIN
	t_dept_manager
		INNER JOIN
	t_departments ON t_dept_manager.dept_no = t_departments.dept_no
		INNER JOIN
	t_employees ON t_dept_manager.emp_no = t_employees.emp_no
ORDER BY t_dept_manager.emp_no, Calendar_Year;

-- Compare the average salary of female vs male employees in the entire company until Year 2002.
-- Add a filter allowing you to see the breakdown for each department 
	
SELECT 
    t_employees.gender AS Gender,
    t_departments.dept_name AS Department,
    ROUND(AVG(t_salaries.salary), 2) AS Salary,
    YEAR(t_employees.hire_date) AS Calendar_Year
FROM
    t_employees
        INNER JOIN
    t_salaries ON t_salaries.emp_no = t_employees.emp_no
        INNER JOIN
    t_dept_emp ON t_dept_emp.emp_no = t_employees.emp_no
        INNER JOIN
    t_departments ON t_departments.dept_no = t_dept_emp.dept_no 
GROUP BY Department, Gender, Calendar_Year
HAVING Calendar_Year <= 2002
ORDER BY Department;








