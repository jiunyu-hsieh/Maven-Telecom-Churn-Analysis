-- Data cleansing --
### Check duplicate values
SELECT Customer_ID, COUNT(Customer_ID) cnt FROM customer
GROUP BY Customer_ID
HAVING cnt>1;
## Check total amount
SELECT COUNT(Distinct Customer_ID) FROM customer;


-- Data Exploration--
###3.1 Key Performance Indicator###
## How many customers churn/stay/join last quarter and what is churn rate？
SELECT
	SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
    ROUND(SUM(IF(Customer_Status='Churned',1,0))/(SELECT COUNT(Distinct Customer_ID) FROM customer),2) AS churned_pct,
    SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
    ROUND(SUM(IF(Customer_Status='Stayed',1,0)) /(SELECT COUNT(Distinct Customer_ID) FROM customer),2) AS stayed_pct,
    SUM(IF(Customer_Status='Joined',1,0)) AS joined_num,
    ROUND(SUM(IF(Customer_Status='Joined',1,0))/(SELECT COUNT(Distinct Customer_ID) FROM customer),2) AS joined_pct
FROM customer;

## Total revenue of different types of customers
SELECT ROUND(SUM(Total_Revenue),2) AS total_renvenue,
	   (SELECT ROUND(SUM(Total_Revenue),2) FROM customer WHERE Customer_Status='Churned' ) AS total_revenue_churned,
       (SELECT ROUND(SUM(Total_Revenue),2) FROM customer WHERE Customer_Status='Stayed' ) AS total_revenue_stayed,
       (SELECT ROUND(SUM(Total_Revenue),2) FROM customer WHERE Customer_Status='Joined' ) AS total_revenue_joined
FROM customer;


###3.2 What are main reasons for churn?###
## General reason for churn
SELECT Churn_Category, ROUND(COUNT(Churn_Category)/(SELECT COUNT(*) FROM customer WHERE Customer_Status='Churned'),2) AS percentage
FROM customer
WHERE Customer_Status='Churned'
GROUP BY Churn_Category
ORDER BY percentage DESC;

## Specific reason for churn
SELECT Churn_Reason, ROUND(COUNT(Churn_Reason)/(SELECT COUNT(*) FROM customer WHERE Customer_Status='Churned'),2) AS percentage
FROM customer
WHERE Customer_Status='Churned'
GROUP BY Churn_Reason
ORDER BY percentage DESC;


###3.3 Which cities have highest churn rate?###
## Top 10 cities have highest churn rate and lowest churn rate(>30 custoemrs) 
SELECT City, COUNT(Distinct Customer_ID) AS num ,ROUND(SUM(IF(Customer_Status='Churned',1,0))/COUNT(Distinct Customer_ID),2) AS churn_rate
FROM customer
GROUP BY City 
HAVING COUNT(Distinct Customer_ID)>30
ORDER BY churn_rate DESC;

## which cities have poor support service ##
SELECT City, Churn_Reason, COUNT(*) AS num
FROM customer
GROUP BY City,Churn_Reason
HAVING Churn_Reason = 'Attitude of support person'
ORDER BY num DESC;


###3.4 Key drivers of churn risk###
## 3.4.1 Custoemr ##
#1)Personal information
#Gender
SELECT Gender,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Gender
ORDER BY churned_num;

#Age
SELECT 
	   IF(Age>60,'senior citizen','young customer') AS Age_segment,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Age_segment
ORDER BY Age;

#Married
SELECT Married,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Married
ORDER BY churned_num;

#Denpendents
SELECT IF(Number_of_Dependents>0,'having dependent(s)','no dependent') AS Dependent,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Dependent
ORDER BY churned_num;

#2）Tenure and referrals
#Referral
SELECT 
	   (CASE
            WHEN Number_of_Referrals=0 THEN '0'
			WHEN Number_of_Referrals BETWEEN 1 AND 4 THEN '1-4'
			WHEN Number_of_Referrals BETWEEN 5 AND 8 THEN '5-8'
			ELSE '>8'
        END) AS Number_of_Referrals_segment,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Number_of_Referrals_segment
ORDER BY Number_of_Referrals;

#Tenture in Months
# Customer status of different tenture
SELECT 
	   (CASE
			WHEN Tenure_in_Months BETWEEN 0 AND 6 THEN '<0.5 year'
			WHEN Tenure_in_Months BETWEEN 7 AND 12 THEN '0.5-1 year'
            WHEN Tenure_in_Months BETWEEN 13 AND 24 THEN '1-2 years'
			ELSE '>2 years'
        END) AS Tenure_in_Months_segment,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Tenure_in_Months_segment
ORDER BY Tenure_in_Months;

# Average tenure of churned customers
SELECT AVG(Tenure_in_Months)
FROM customer
WHERE Customer_Status='Churned';

# Average and median value of customer lifespan 
SELECT AVG(Tenure_in_Months)
FROM customer;


## 3.4.2 Service ##
#1)Basic service 
# Add service column
#ALTER TABLE customer DROP column contactor;
ALTER TABLE customer ADD service varchar(255), ADD contact varchar(255);
UPDATE customer
SET service = IF(phone_service = 'Yes' AND internet_service = 'Yes', 'both', IF(phone_service = 'Yes' AND internet_service = 'No', 'phone servive', 'internet service')),
	contact = IF(Married = 'No' AND Number_of_Dependents = 0, 'no contact', 'contact');

#Phone service
SELECT Phone_Service,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Phone_Service
ORDER BY Phone_Service;

#Internet service/type
SELECT Internet_Service,
       Internet_Type,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Internet_Service,Internet_Type
ORDER BY Internet_Service,Internet_Type;

#Offer
SELECT Offer, COUNT(Offer)/(SELECT COUNT(*) FROM customer WHERE Customer_Status='Churned') AS percentage
FROM customer
WHERE Customer_Status='Churned'
GROUP BY Offer;

#Contract duration
SELECT Contract,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Contract;


#2)Add-on-service
# multiple lines
SELECT contact, Multiple_Lines, COUNT(IF(Age>=60,1,NULL)) AS senior_citizen, COUNT(IF(Age<60,1,NULL)) AS young_people
FROM customer
WHERE Phone_Service = 'Yes'
GROUP BY contact, Multiple_Lines;

# Why does Fiber Optic have such a high churn rate? #
#Churn reason of thoes customers
SELECT Churn_Category,Churn_Reason,COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Customer_Status='Churned') AS percentage
FROM customer
WHERE Customer_Status='Churned' AND Internet_Type = 'Fiber Optic'
GROUP BY Churn_Category,Churn_Reason;

#What add-on services that customers with different internet type would choose?
SELECT 
	   SUM(IF(Online_Security='Yes',1,0))/COUNT(*) AS Online_Security,
	   SUM(IF(Online_Backup='Yes',1,0))/COUNT(*) AS Online_Backup,
	   SUM(IF(Device_Protection_Plan='Yes',1,0))/COUNT(*) AS Device_Protection_Plan,
       SUM(IF(Premium_Tech_Support='Yes',1,0))/COUNT(*) AS Premium_Tech_Support,
       SUM(IF(Streaming_TV='Yes',1,0))/COUNT(*) AS Streaming_TV,
       SUM(IF(Streaming_Movies='Yes',1,0))/COUNT(*) AS Streaming_Movies,
       SUM(IF(Streaming_Music='Yes',1,0))/COUNT(*) AS Streaming_Music,
       SUM(IF(Unlimited_Data='Yes',1,0))/COUNT(*) AS Unlimited_Data
FROM customer
WHERE Internet_Type='Fiber Optic'

UNION

SELECT 
	   SUM(IF(Online_Security='Yes',1,0))/COUNT(*) AS Online_Security,
	   SUM(IF(Online_Backup='Yes',1,0))/COUNT(*) AS Online_Backup,
	   SUM(IF(Device_Protection_Plan='Yes',1,0))/COUNT(*) AS Device_Protection_Plan,
       SUM(IF(Premium_Tech_Support='Yes',1,0))/COUNT(*) AS Premium_Tech_Support,
       SUM(IF(Streaming_TV='Yes',1,0))/COUNT(*) AS Streaming_TV,
       SUM(IF(Streaming_Movies='Yes',1,0))/COUNT(*) AS Streaming_Movies,
       SUM(IF(Streaming_Music='Yes',1,0))/COUNT(*) AS Streaming_Music,
       SUM(IF(Unlimited_Data='Yes',1,0))/COUNT(*) AS Unlimited_Data
FROM customer
WHERE Internet_Type='DSL'

UNION

SELECT 
	   SUM(IF(Online_Security='Yes',1,0))/COUNT(*) AS Online_Security,
	   SUM(IF(Online_Backup='Yes',1,0))/COUNT(*) AS Online_Backup,
	   SUM(IF(Device_Protection_Plan='Yes',1,0))/COUNT(*) AS Device_Protection_Plan,
       SUM(IF(Premium_Tech_Support='Yes',1,0))/COUNT(*) AS Premium_Tech_Support,
       SUM(IF(Streaming_TV='Yes',1,0))/COUNT(*) AS Streaming_TV,
       SUM(IF(Streaming_Movies='Yes',1,0))/COUNT(*) AS Streaming_Movies,
       SUM(IF(Streaming_Music='Yes',1,0))/COUNT(*) AS Streaming_Music,
       SUM(IF(Unlimited_Data='Yes',1,0))/COUNT(*) AS Unlimited_Data
FROM customer
WHERE Internet_Type='Cable';

#Online security
SELECT Online_Security,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Online_Security
ORDER BY Online_Security;

#Online backup
SELECT Online_Backup,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Online_Backup
ORDER BY Online_Backup;

#Device Protection Plan
SELECT Device_Protection_Plan,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Device_Protection_Plan
ORDER BY Device_Protection_Plan;

#Premium Tech Support
SELECT Premium_Tech_Support,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Premium_Tech_Support
ORDER BY Premium_Tech_Support;

#Streaming tv
SELECT Streaming_TV,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Streaming_TV
ORDER BY Streaming_TV;

#Streaming movies
SELECT Streaming_Movies,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Streaming_Movies
ORDER BY Streaming_Movies;

#Streaming music
SELECT Streaming_Music,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Streaming_Music
ORDER BY Streaming_Music;

#Unlimited data
SELECT Unlimited_Data,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Unlimited_Data
ORDER BY Unlimited_Data;


## 3.4.3 Payment ##
#1) Payment method and billing type
# Paperless billing
SELECT Paperless_Billing,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Paperless_Billing;

# Payment method
SELECT Payment_Method,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customer
GROUP BY Payment_Method;	


### 3.5 Are high value customers at risk of churning? ###
# Quartile of Monthly_Charge 
CREATE TABLE customervalue AS
(
	WITH 
	chargescore AS
	(
		SELECT Customer_ID,
			   (CASE 
					WHEN PERCENT_RANK()OVER(ORDER BY Monthly_Charge) <0.25 Then 0
					WHEN PERCENT_RANK()OVER(ORDER BY Monthly_Charge) BETWEEN 0.25 AND 0.5 Then 1
					WHEN PERCENT_RANK()OVER(ORDER BY Monthly_Charge) BETWEEN 0.5 AND 0.75 Then 2
					ELSE 3
				END
				) AS Monthly_Charge_score
		FROM customer
	),

	# Quartile of Tenure
	tenurescore AS
	(
		SELECT Customer_ID,
			   (CASE 
					WHEN PERCENT_RANK()OVER(ORDER BY Tenure_in_Months) <0.25 Then 0
					WHEN PERCENT_RANK()OVER(ORDER BY Tenure_in_Months) BETWEEN 0.25 AND 0.5 Then 1
					WHEN PERCENT_RANK()OVER(ORDER BY Tenure_in_Months) BETWEEN 0.5 AND 0.75 Then 2
					ELSE 3
				END
				) AS Tenure_in_Months_score
		FROM customer
	),

	# Quartile of referrals
	referralscore AS
	(
		SELECT Customer_ID,
			   (CASE 
					WHEN PERCENT_RANK()OVER(ORDER BY Number_of_Referrals) <0.25 Then 0
					WHEN PERCENT_RANK()OVER(ORDER BY Number_of_Referrals) BETWEEN 0.25 AND 0.5 Then 1
					WHEN PERCENT_RANK()OVER(ORDER BY Number_of_Referrals) BETWEEN 0.5 AND 0.75 Then 2
					ELSE 3
				END
				) AS Number_of_Referrals_score
		FROM customer
	)

	# Total score and customers value
	SELECT *
	FROM
	(
		SELECT c.Customer_ID, 
			   (0.6*Monthly_Charge_score+0.2*Tenure_in_Months_score+0.2*Number_of_Referrals_score) AS total_score
		FROM chargescore c
		JOIN tenurescore t USING(Customer_ID)
		JOIN referralscore r USING(Customer_ID)
	) temp
);


# How many high-value customers are in churned/stayed/joined customers?
SELECT IF(total_score>=2,'high value','low value') AS customers_value,
	   SUM(IF(Customer_Status='Churned',1,0)) AS churned_num,
       SUM(IF(Customer_Status='Stayed',1,0)) AS stayed_num,
       SUM(IF(Customer_Status='Joined',1,0)) AS joined_num
FROM customervalue
JOIN customer 
USING(Customer_ID)
GROUP BY customers_value;

# What's the percentage of churned risk in stayed and joined customers?
/*
High risk: having >4 risk factors among top 10 risk indicators
Middle risk: having 3-4 risk factors among top 10 risk indicators
Low risk: having <=2 risk factors among top 10 risk indicators
top 10 risk indicators: 
referral(0-4),contract(month-to-month),onlinesecurity(no),
premium tech support(no),online backup(no),device protection plan(no),
internet type(Fiber Optic),offer(None),tenture(<6months),Streaming service(0)
*/

SELECT  Customer_Status,customers_value,
	   (CASE
			WHEN num_risk_factors>4 Then 'High risk'
			WHEN num_risk_factors<3 Then 'Low risk'
			ELSE 'Middle risk'
        END) AS churned_risk,
        COUNT(*) AS num_of_churned_risk_customers
FROM
(
SELECT 
	IF(total_score>=2,'high value','low value') AS customers_value,
    Customer_Status,
	(IF(Age>=60,1,0)+
     IF(contact='no contact',1,0)+
     IF(Number_of_Referrals<=4,1,0)+
     IF(Tenure_in_Months<6,1,0)+
     IF(Internet_Type = 'Fiber Optic',1,0)+
	 IF(OFFER = 'Offer E',1,0)+
	 IF(Contract = 'Month-to-Month',1,0)+
	 IF(Online_Security = 'No',1,0)+
	 IF(Online_Backup = 'No',1,0)+
	 IF(Device_Protection_Plan = 'No',1,0)+
	 IF(Premium_Tech_Support='No',1,0)+
     IF(Unlimited_Data = 'Yes',1,0)+
	 IF(Paperless_Billing = 'Yes',1,0)
     ) AS num_risk_factors
FROM customervalue
JOIN customer 
USING(Customer_ID)
WHERE Customer_Status='Stayed' OR Customer_Status='Joined'
) temp
GROUP BY Customer_Status,customers_value, churned_risk
ORDER BY Customer_Status,customers_value, churned_risk;


# risk factor
CREATE TABLE riskfactor AS
(
	SELECT 'senior ctizen' AS factor, COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Age>=60) AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Age>=60 
	UNION
	SELECT contact, COUNT(*)/(SELECT COUNT(*) FROM customer WHERE contact='no contact') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  contact='no contact'
	UNION
	SELECT '<=0.5 year tenure', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Tenure_in_Months<=6) AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Tenure_in_Months<=6
	UNION
	SELECT '<=4 referrals', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Number_of_Referrals<=4) AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Number_of_Referrals<=4
	UNION
	SELECT 'OFFer E', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Offer='Offer E') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Offer='Offer E'
	UNION
	SELECT 'Online_Security NO', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Online_Security='No') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Online_Security='No'
	UNION
	SELECT 'Premium_Tech_Support NO', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Premium_Tech_Support='No') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Premium_Tech_Support='No'
	UNION
	SELECT 'Paperless billing', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Paperless_Billing='Yes') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Paperless_Billing='Yes'
	UNION
	SELECT 'Bank Withdrawal', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Payment_Method='Bank Withdrawal') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Payment_Method='Bank Withdrawal'
	UNION
	SELECT 'Mailed Check', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Payment_Method='Mailed Check') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Payment_Method='Mailed Check'
	UNION
	SELECT '80-100 Monthly Payment', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Monthly_Charge BETWEEN 80 AND 100) AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Monthly_Charge BETWEEN 80 AND 100
    UNION
	SELECT 'Online_Backup No', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Online_Backup='No') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Online_Backup='No'
     UNION
	SELECT 'Device_Protection_Plan No', COUNT(*)/(SELECT COUNT(*) FROM customer WHERE Device_Protection_Plan='No') AS churn_rate
	FROM customer
	WHERE Customer_Status='Churned' AND  Device_Protection_Plan='No'
);
