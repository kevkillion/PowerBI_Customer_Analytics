/* 

JOINING DATA

Version: F
Owner: KK

Account Column List 
    CUSTOMER_NUMBER, CUSTOMER_FIRST_NAME, CUSTOMER_LAST_NAME, DATE_OF_BIRTH, GENDER, STREET_ADDRESS,
	COUNTRY, COUNTRY_CODE, EMAIL, INTEREST_TYPE, INTEREST_RATE, GROSS_BALANCE, INTEREST_BALANCE, 
	PRINCIPLE_BALANCE, PROPERTY_OWNER, PROPERTY_VALUE, PROPERTY_YEAR,

Sales Column List
	CUSTOMER_NAME, SALE, SALES_SCHEME_CODE, SALES_STRATEGY_TYPE, MARITAL_STATUS, 
	DAYS_SINCE_CUSTOMER_ENGAGEMENT, REG_DATE, START_DATE, OCC_CODE, TOTAL_HOUSEHOLD_ANNUAL_EXPENDITURE,
	GROCERY_WEEKLY_SPENDING, TOTAL_EXPENDATURE_TO_DATE, NO_ITEMS_PURCHASED, WEEKLY_FUEL_EXPENDATURE,
	SALES_CALL_STATUS, STORES_VISITED, LOYALTY_CARD_STATUS, LOYALTY_GIFT_SENT,


*/
Drop Table dbo.Customer_Account

CREATE TABLE Customer_Account (
	CUSTOMER_NUMBER�Varchar(55) ,
	CUSTOMER_FIRST_NAME�Varchar(55)�,
	CUSTOMER_LAST_NAME�Varchar(55)�,
	DATE_OF_BIRTH�Date�,
	GENDER�Varchar(25) null�,
	STREET_ADDRESS�Varchar(55)�,
	COUNTRY�Varchar(55)�,
	COUNTRY_CODE�Varchar(55)�,
	EMAIL�Varchar(55) null�,
	INTEREST_TYPE�Varchar(55)�,
	INTEREST_RATE�Float�,
	GROSS_BALANCE�DECIMAL(30,2)�,
	INTEREST_BALANCE�DECIMAL(30,2)�,
	PRINCIPLE_BALANCE�DECIMAL(30,2)�,
	PROPERTY_OWNER�Varchar(25)�,
	PROPERTY_VALUE�DECIMAL(30,2) null�,
	PROPERTY_YEAR�INT�null,
	) ;

BULK INSERT Customer_Account
FROM "D:\USERS\kkillion\Documents\06. SQL\SQL Training\Stage 4\CUSTOMER_ACCOUNT.txt"
WITH (
	FIELDTERMINATOR = '|',
	ROWTERMINATOR = '0x0a',
	FIRSTROW = 2 
	) ;

SELECT * FROM Customer_Account;
--------------------------------------

Drop Table dbo.Customer_Sales

CREATE TABLE Customer_Sales (
	CUSTOMER_NAME Varchar(55) ,
	SALE INT ,
	SALES_SCHEME_CODE Varchar(2) ,
	SALES_STRATEGY_TYPE Varchar(15) ,
	MARITAL_STATUS Varchar(15) ,
	DAYS_SINCE_CUSTOMER_ENGAGEMENT INT ,
	REG_DATE DATE ,
	STA_DATE DATE ,
	OCC_CODE Varchar(2) ,
	TOTAL_HOUSEHOLD_ANNUAL_EXPENDITURE INT ,
	GROCERY_WEEKLY_SPENDING INT ,
	TOTAL_EXPENDATURE_TO_DATE INT ,
	NO_ITEMS_PURCHASED INT ,
	WEEKLY_FUEL_EXPENDATURE INT ,
	SALES_CALL_STATUS Varchar(15) ,
	STORES_VISITED INT ,
	LOYALTY_CARD_STATUS Varchar(15) ,
	LOYALTY_GIFT_SENT INT ,
	) ;

BULK INSERT Customer_Sales
FROM "D:\USERS\kkillion\Documents\06. SQL\SQL Training\Stage 4\CUSTOMER_SALES.csv"
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0A',
	FIRSTROW = 2 
	) ;

SELECT * FROM Customer_Sales ;

-----Create JOIN TABLE-----
CREATE TABLE Customer_Join (
	CUSTOMER_NUMBER�Varchar(55) ,
	CUSTOMER_FIRST_NAME�Varchar(55)�,
	CUSTOMER_LAST_NAME�Varchar(55)�,
	DATE_OF_BIRTH�Date�,
	GENDER�Varchar(25) null�,
	STREET_ADDRESS�Varchar(55)�,
	COUNTRY�Varchar(55)�,
	COUNTRY_CODE�Varchar(55)�,
	EMAIL�Varchar(35) null�,
	INTEREST_TYPE�Varchar(55)�,
	INTEREST_RATE�Float�,
	GROSS_BALANCE�DECIMAL(30,2)�,
	INTEREST_BALANCE�DECIMAL(30,2)�,
	PRINCIPLE_BALANCE�DECIMAL(30,2)�,
	PROPERTY_OWNER�Varchar(25)�,
	PROPERTY_VALUE�DECIMAL(30,2) null�,
	PROPERTY_YEAR�INT�null,
	 CUSTOMER_NAME Varchar(55) ,
	SALE INT ,
	SALES_SCHEME_CODE Varchar(2) ,
	SALES_STRATEGY_TYPE Varchar(15) ,
	MARITAL_STATUS Varchar(15) ,
	DAYS_SINCE_CUSTOMER_ENGAGEMENT INT ,
	REG_DATE DATE ,
	STA_DATE DATE ,
	OCC_CODE Varchar(2) ,
	TOTAL_HOUSEHOLD_ANNUAL_EXPENDITURE INT ,
	GROCERY_WEEKLY_SPENDING INT ,
	TOTAL_EXPENDATURE_TO_DATE INT ,
	NO_ITEMS_PURCHASED INT ,
	WEEKLY_FUEL_EXPENDATURE INT ,
	SALES_CALL_STATUS Varchar(15) ,
	STORES_VISITED INT ,
	LOYALTY_CARD_STATUS Varchar(15) ,
	LOYALTY_GIFT_SENT INT ,
	) ;


-----Concat NAMES in Account-----
ALTER TABLE Customer_Account
ADD CUSTOMER_NAME VARCHAR(55)

Update Customer_Account
SET CUSTOMER_NAME = (CUSTOMER_FIRST_NAME + ' ' + CUSTOMER_LAST_NAME)


SELECT CUSTOMER_NAME
FROM Customer_Account


-----Clean WHITESPACE-----
Update Customer_Sales
SET CUSTOMER_NAME = TRIM(CUSTOMER_NAME)

Update Customer_Account
SET CUSTOMER_NAME = TRIM(CUSTOMER_NAME)


-----Add CUSTOMER_NUMBER to Sales-----
ALTER TABLE Customer_Sales 
ADD CUSTOMER_NUMBER VARCHAR(55) ;

UPDATE Customer_Sales
SET Customer_Sales.CUSTOMER_NUMBER = (
SELECT CUSTOMER_NUMBER
FROM Customer_Account AS CA
WHERE CA.CUSTOMER_NAME = Customer_Sales.CUSTOMER_NAME )
WHERE EXISTS ( SELECT CUSTOMER_NUMBER FROM Customer_Account AS CA
WHERE CA.CUSTOMER_NAME = Customer_Sales.CUSTOMER_NAME) ;

Update Customer_Sales
SET CUSTOMER_NUMBER = null ;
 
-----CREATE LEVENSCHTEIN FUNCTION-----


CREATE function LEVENSHTEIN ( @SourceString nvarchar(100), @TargetString nvarchar(100) ) 
--Returns the Levenshtein Distance between @SourceString string and @TargetString
--Translated to TSQL by Joseph Gama
--Updated slightly by Phil Factor
returns int
as
BEGIN
DECLARE @Matrix Nvarchar(4000), @LD int, @TargetStringLength int, @SourceStringLength int,
@ii int, @jj int, @CurrentSourceChar nchar(1), @CurrentTargetChar nchar(1),@Cost int, 
@Above int,@AboveAndToLeft int,@ToTheLeft int, @MinimumValueOfCells int
-- Step 1: Set n to be the length of s. Set m to be the length of t. 
--                    If n = 0, return m and exit.
--    If m = 0, return n and exit.
--    Construct a matrix containing 0..m rows and 0..n columns.
if @SourceString is null or @TargetString is null return null
Select @SourceStringLength=LEN(@SourceString), 
     @TargetStringLength=LEN(@TargetString),
     @Matrix=replicate(nchar(0),(@SourceStringLength+1)*(@TargetStringLength+1))
If @SourceStringLength = 0 return @TargetStringLength
If @TargetStringLength = 0 return @SourceStringLength
if (@TargetStringLength+1)*(@SourceStringLength+1)> 4000 return -1
--Step 2: Initialize the first row to 0..n.
--     Initialize the first column to 0..m.
SET @ii=0
WHILE @ii<=@SourceStringLength
    BEGIN
    SET @Matrix=STUFF(@Matrix,@ii+1,1,nchar(@ii))--d(i, 0) = i
    SET @ii=@ii+1
    END
SET @ii=0
WHILE @ii<=@TargetStringLength
    BEGIN
    SET @Matrix=STUFF(@Matrix,@ii*(@SourceStringLength+1)+1,1,nchar(@ii))--d(0, j) = j
    SET @ii=@ii+1
    END
--Step 3 Examine each character of s (i from 1 to n).
SET @ii=1
WHILE @ii<=@SourceStringLength
    BEGIN
 
--Step 4   Examine each character of t (j from 1 to m).
    SET @jj=1
    WHILE @jj<=@TargetStringLength
        BEGIN
--Step 5 and 6
        Select 
        --Set cell d[i,j] of the matrix equal to the minimum of:
        --a. The cell immediately above plus 1: d[i-1,j] + 1.
        --b. The cell immediately to the left plus 1: d[i,j-1] + 1.
        --c. The cell diagonally above and to the left plus the cost: d[i-1,j-1] + cost
        @Above=unicode(substring(@Matrix,@jj*(@SourceStringLength+1)+@ii-1+1,1))+1,
        @ToTheLeft=unicode(substring(@Matrix,(@jj-1)*(@SourceStringLength+1)+@ii+1,1))+1,
        @AboveAndToLeft=unicode(substring(@Matrix,(@jj-1)*(@SourceStringLength+1)+@ii-1+1,1))
         + case when (substring(@SourceString,@ii,1)) = (substring(@TargetString,@jj,1)) 
            then 0 else 1 end--the cost
        -- If s[i] equals t[j], the cost is 0.
      -- If s[i] doesn't equal t[j], the cost is 1.
        -- now calculate the minimum value of the three
        if (@Above < @ToTheLeft) AND (@Above < @AboveAndToLeft) 
            select @MinimumValueOfCells=@Above
      else if (@ToTheLeft < @Above) AND (@ToTheLeft < @AboveAndToLeft)
            select @MinimumValueOfCells=@ToTheLeft
        else
            select @MinimumValueOfCells=@AboveAndToLeft
        Select @Matrix=STUFF(@Matrix,
                   @jj*(@SourceStringLength+1)+@ii+1,1,
                   nchar(@MinimumValueOfCells)),
           @jj=@jj+1
        END
    SET @ii=@ii+1
    END    
--Step 7 After iteration steps (3, 4, 5, 6) are complete, distance is found in cell d[n,m]
return unicode(substring(
   @Matrix,@SourceStringLength*(@TargetStringLength+1)+@TargetStringLength+1,1
   ))
END
go ;


--TEST---
SELECT dbo.LEVENSHTEIN('abcde', 'abCgF') ;



-----APPLY LEVENSCHTEIN Function-----

--TRY--
SELECT Customer_Account.CUSTOMER_NUMBER, Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME,  
dbo.LEVENSHTEIN(Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME) AS MatchScore
FROM Customer_Account
INNER JOIN Customer_Sales
ON Customer_Account.CUSTOMER_NAME = Customer_Sales.CUSTOMER_NAME
OR Customer_Sales.CUSTOMER_NAME  LIKE '%' + Customer_Account.CUSTOMER_LAST_NAME + '%'
WHERE dbo.LEVENSHTEIN(Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME) > 0
ORDER BY MatchScore DESC ;


--INSERT Unmatched CUSTOMER_NUMBERS Into Table--
SELECT CUSTOMER_NUMBER FROM Customer_Sales WHERE CUSTOMER_NUMBER IS NULL ;

CREATE TABLE Customer_Unmatched (CUSTOMER_NUMBER_CA varchar(55), CUSTOMER_NUMBER_CS varchar(55), CUSTOMER_NAME_CA varchar(55), 
CUSTOMER_NAME_CS varchar(55), MatchScore INT) ;


INSERT INTO Customer_Unmatched 
SELECT Customer_Account.CUSTOMER_NUMBER, Customer_Sales.CUSTOMER_NUMBER, Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME, 
dbo.LEVENSHTEIN(Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME) AS MatchScore
FROM Customer_Account
INNER JOIN Customer_Sales
ON dbo.LEVENSHTEIN(Customer_Account.CUSTOMER_NAME, Customer_Sales.CUSTOMER_NAME) < 23
WHERE Customer_Sales.CUSTOMER_NUMBER IS NULL
ORDER BY MatchScore DESC ;

SELECT * FROM Customer_Unmatched ;

--Add Columns--
ALTER TABLE Customer_Unmatched
ADD CA_NOSPACE varchar(100), ---> Customer Account Name with no space
	CS_NOSPACE varchar(100), ---> Customer Sales Name with no space
	DISTANCE INT,
	PERCENTAGE_SIMILARITY DECIMAL,
	CS_Name_Length INT,
	CA_Name_Length INT ;

--Set Columns--
Update Customer_Unmatched
SET CA_NOSPACE = REPLACE(CUSTOMER_NAME_CA, ' ', ''),
	CS_NOSPACE = REPLACE(CUSTOMER_NAME_CS, ' ', ''),
	DISTANCE = dbo.DamerauLevenschtein(CA_NOSPACE, CS_NOSPACE),
	CA_Name_Length = DATALENGTH(CUSTOMER_NAME_CA),
	CS_Name_Length = DATALENGTH(CUSTOMER_NAME_CS)

UPDATE Customer_Unmatched
SET PERCENTAGE_SIMILARITY = 
	CASE WHEN CS_Name_Length > CA_Name_Length 
	THEN�
	100 * (1-�( CAST(dbo.LEVENSHTEIN(CS_NOSPACE, CA_NOSPACE) AS NUMERIC) / CS_Name_Length))
	ELSE
��	100 * (1-�( CAST(dbo.LEVENSHTEIN(CS_NOSPACE, CA_NOSPACE) AS NUMERIC) / CA_Name_Length))
END ;

--Insert Into Matched TABLE--
CREATE TABLE Customer_Matched
(CUSTOMER_NUMBER_CA varchar(100)
, CUSTOMER_NUMBER_CS varchar(100) NULL
, CUSTOMER_NAME_CA varchar(100)
, CUSTOMER_NAME_CS varchar(100)
,  MatchScore INT, CA_NOSPACE varchar(100)
, CS_NOSPACE varchar(100)
, DISTANCE INT NULL
, PERCENTAGE_SIMILARITY INT
, CS_Name_Length INT
, CA_Name_Length INT
, HIGHEST_PERCENTAGE INT) ;


INSERT INTO Customer_Matched
	SELECT CUSTOMER_NUMBER_CA, CUSTOMER_NUMBER_CS, CUSTOMER_NAME_CA, U.CUSTOMER_NAME_CS,
	MatchScore, CA_NOSPACE, 
	CS_NOSPACE, DISTANCE, PERCENTAGE_SIMILARITY , CS_Name_Length , CA_Name_Length , HIGHEST_PERCENTAGE 
	FROM Customer_Unmatched U
	INNER JOIN
	    (SELECT CUSTOMER_NAME_CS, MAX(PERCENTAGE_SIMILARITY) AS HIGHEST_PERCENTAGE
	    FROM Customer_Unmatched
	    GROUP BY CUSTOMER_NAME_CS) A 
	ON U.CUSTOMER_NAME_CS = A.CUSTOMER_NAME_CS
	AND U.PERCENTAGE_SIMILARITY = A.HIGHEST_PERCENTAGE ;

SELECT * FROM Customer_Matched ;


------Check DUPLICATES-----
SELECT CUSTOMER_NUMBER_CA, COUNT(CUSTOMER_NUMBER_CA) AS COUNT
FROM Customer_Matched
GROUP BY CUSTOMER_NUMBER_CA
HAVING COUNT(CUSTOMER_NUMBER_CA) > 1 ;

--Dupe CS Names--
SELECT CS_NOSPACE, COUNT(CS_NOSPACE) AS COUNT
FROM Customer_Matched
GROUP BY CS_NOSPACE
HAVING COUNT(CS_NOSPACE) > 1 ;

--Dupe CA Names--
SELECT CUSTOMER_NAME_CA, COUNT(CUSTOMER_NAME_CA) AS COUNT
FROM Customer_Matched
GROUP BY CUSTOMER_NAME_CA
HAVING COUNT(CUSTOMER_NAME_CA) > 1 ;


-----Add Matched CUSTOMER_NUMBERS into Sales where NULL-----

UPDATE Customer_Sales
SET CUSTOMER_NUMBER = Customer_Matched.CUSTOMER_NUMBER_CA -- we were matching with CUSTOMER_NUMBER_CS earlier, which was always blank in matched table!
FROM Customer_Matched
WHERE CUSTOMER_NAME_CS = CUSTOMER_NAME ;

--CHECK--
SELECT customer_number FROM Customer_Sales group by customer_number having count(*)>1 ; --no duplicates!


--CHECK--
SELECT * FROM Customer_Matched ;


-----Join TABLES-----

SELECT *
FROM Customer_Account AS CA
INNER JOIN Customer_Sales
ON CA.CUSTOMER_NUMBER = Customer_Sales.CUSTOMER_NUMBER ;


