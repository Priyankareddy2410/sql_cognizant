CREATE DATABASE Healthcare;

USE Healthcare;

SELECT * FROM healthcare;

DESC Healthcare;

SELECT COUNT(*) FROM Healthcare;		

SELECT MAX(age) AS Maximum_Age FROM Healthcare;

SELECT ROUND(AVG(age), 0) AS Average_Age FROM Healthcare;	

SELECT AGE, COUNT(AGE) AS Total
FROM Healthcare
GROUP BY age
ORDER BY AGE DESC;

SELECT AGE, COUNT(AGE) AS Total
FROM Healthcare
GROUP BY age
ORDER BY Total DESC, age DESC;

SELECT AGE, COUNT(AGE) AS Total, DENSE_RANK() OVER(ORDER BY COUNT(AGE) DESC, age DESC) AS Ranking_Admitted 
FROM Healthcare
GROUP BY age
HAVING Total > AVG(age);

SELECT Medical_Condition, COUNT(Medical_Condition) AS Total_Patients 
FROM healthcare
GROUP BY Medical_Condition
ORDER BY Total_Patients DESC;

SELECT Medical_Condition, Medication, COUNT(medication) AS Total_Medications_to_Patients, RANK() OVER(PARTITION BY Medical_Condition ORDER BY COUNT(medication) DESC) AS Rank_Medicine
FROM Healthcare
GROUP BY 1, 2
ORDER BY 1; 

SELECT Insurance_Provider, COUNT(Insurance_Provider) AS Total 
FROM Healthcare
GROUP BY Insurance_Provider
ORDER BY Total DESC;

SELECT Hospital, COUNT(hospital) AS Total 
FROM Healthcare
GROUP BY Hospital
ORDER BY Total DESC;

SELECT Medical_Condition, ROUND(AVG(Billing_Amount), 2) AS Avg_Billing_Amount
FROM Healthcare
GROUP BY Medical_Condition;

SELECT Medical_Condition, Name, Hospital, DATEDIFF(Discharge_date, Date_of_Admission) AS Number_of_Days, 
SUM(ROUND(Billing_Amount, 2)) OVER(PARTITION BY Hospital ORDER BY Hospital DESC) AS Total_Amount
FROM Healthcare
ORDER BY Medical_Condition;

SELECT Name, Medical_Condition, ROUND(Billing_Amount, 2) AS Billing_Amount, Hospital, DATEDIFF(Discharge_Date, Date_of_Admission) AS Total_Hospitalized_days
FROM Healthcare;

SELECT Medical_Condition, Hospital, DATEDIFF(Discharge_Date, Date_of_Admission) AS Total_Hospitalized_days, Test_results
FROM Healthcare
WHERE Test_results LIKE 'Normal'
ORDER BY Medical_Condition, Hospital;

SELECT Age, Blood_type, COUNT(Blood_Type) AS Count_Blood_Type
FROM Healthcare
WHERE AGE BETWEEN 20 AND 45
GROUP BY 1, 2
ORDER BY Blood_Type DESC;

SELECT DISTINCT (SELECT COUNT(Blood_Type) FROM healthcare WHERE Blood_Type IN ('O-')) AS Universal_Blood_Donor, 
(SELECT COUNT(Blood_Type) FROM healthcare WHERE Blood_Type IN ('AB+')) AS Universal_Blood_reciever
FROM healthcare;

DELIMITER $$

CREATE PROCEDURE Blood_Matcher(IN Name_of_patient VARCHAR(200))
BEGIN 
SELECT D.Name AS Donor_name, D.Age AS Donor_Age, D.Blood_Type AS Donors_Blood_type, D.Hospital AS Donors_Hospital, 
R.Name AS Reciever_name, R.Age AS Reciever_Age, R.Blood_Type AS Recievers_Blood_type, R.Hospital AS Receivers_hospital
FROM Healthcare D 
INNER JOIN Healthcare R ON (D.Blood_type = 'O-' AND R.Blood_type = 'AB+') AND ((D.Hospital = R.Hospital) OR (D.Hospital != R.Hospital))
WHERE (R.Name REGEXP Name_of_patient) AND (D.AGE BETWEEN 20 AND 40);
END $$

DELIMITER ;

CALL Blood_Matcher('Matthew Cruz');

SELECT DISTINCT Hospital, COUNT(*) AS Total_Admitted
FROM healthcare
WHERE YEAR(Date_of_Admission) IN (2024, 2025)
GROUP BY 1
ORDER BY Total_Admitted DESC; 

SELECT Insurance_Provider, ROUND(AVG(Billing_Amount), 0) AS Average_Amount, ROUND(MIN(Billing_Amount), 0) AS Minimum_Amount, ROUND(MAX(Billing_Amount), 0) AS Maximum_Amount
FROM healthcare
GROUP BY 1;

SELECT Name, Medical_Condition, Test_Results,
CASE 
    WHEN Test_Results = 'Inconclusive' THEN 'Need More Checks / CANNOT be Discharged'
    WHEN Test_Results = 'Normal' THEN 'Can take discharge, But need to follow Prescribed medications timely' 
    WHEN Test_Results = 'Abnormal' THEN 'Needs more attention and more tests'
END AS 'Status', Hospital, Doctor
FROM Healthcare;
