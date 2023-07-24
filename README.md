
# **PowerBI Customer Analysis: ~ Data Engineering ~ DAX ~ SQL**

This project demonstrates the power of SQL Server functions in connection with PowerBI visualisations to engineer and analyze large datasets at speed and with accuracy. It is also important to point out the high-powered Levenshteins algorithm used in this project showing the capability of accurately joining datasets without a unique identifier present in both. DAX code was also used to build measures and calculated columns.

# Prerequisites 💻

To run the this project, you will need to have the following software installed:

- SQL Server
- PowerBI Desktop
- Levenshtein's Algorithm


# Getting Started 🛠

To run the SQL files in this project, follow these steps:

1. Import Datasets into SQL Server using the Wizard.
2. Create Levenshteins Distance Function in SQL Server.
3. Run the Join SQL script to join Account data and Sales data.
4. Use PowerBI Desktop to analyse the data :

   **PowerBI_Customer Analysis.pbix**

# Fuzzy Match "Levenshteins Distance Algorithm" 🔑

Sql function code as follows:

```sql
# Levenshteins Algorithm

CREATE FUNCTION edit_distance(@s1 nvarchar(3999), @s2 nvarchar(3999))
RETURNS int
AS
BEGIN
 DECLARE @s1_len int, @s2_len int
 DECLARE @i int, @j int, @s1_char nchar, @c int, @c_temp int
 DECLARE @cv0 varbinary(8000), @cv1 varbinary(8000)

 SELECT
  @s1_len = LEN(@s1),
  @s2_len = LEN(@s2),
  @cv1 = 0x0000,
  @j = 1, @i = 1, @c = 0

 WHILE @j <= @s2_len
  SELECT @cv1 = @cv1 + CAST(@j AS binary(2)), @j = @j + 1

 WHILE @i <= @s1_len
 BEGIN
  SELECT
   @s1_char = SUBSTRING(@s1, @i, 1),
   @c = @i,
   @cv0 = CAST(@i AS binary(2)),
   @j = 1

  WHILE @j <= @s2_len
  BEGIN
   SET @c = @c + 1
   SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j-1, 2) AS int) +
    CASE WHEN @s1_char = SUBSTRING(@s2, @j, 1) THEN 0 ELSE 1 END
   IF @c > @c_temp SET @c = @c_temp
   SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j+1, 2) AS int)+1
   IF @c > @c_temp SET @c = @c_temp
   SELECT @cv0 = @cv0 + CAST(@c AS binary(2)), @j = @j + 1
 END

 SELECT @cv1 = @cv0, @i = @i + 1
 END

 RETURN @c
END
```

# SQL Server Connection 🛢 🐘

Data stored, transformed and manipulated in a specified database in SQL Server. Live Connection created from database to PowerBI desktop for instant analysis. 

# PowerBI Visualisation 📊

The dataframe was explored through dynamic PowerBI Dahsboard

# DAX Code - Measures and Calculated Columns 🤖

DAX speed and power used to build measures and manipulate columns to harness data and extract meaniful insights.

# Files

The following files were used in this project:

- README.md: Description file outlining the project
- PowerBI_Dynamic Customer Analysis.pbix: dynamic view of dashboard
- PowerBI_Dynamic Customer Analysis.pdf: static view of dashboard
- Join.sql: SQL script joining datasets


