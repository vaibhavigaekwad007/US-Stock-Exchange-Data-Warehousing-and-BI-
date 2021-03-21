CREATE DATABASE ExchangeAnalysis_GOOD

USE ExchangeAnalysis_GOOD
GO

--STAGING TABLE


DROP TABLE Stg_StockData
DROP TABLE Stg_CompanyOverview;
DROP TABLE Stg_QuarterlyEarnings;
DROP TABLE Stg_IncomeStatement;
DROP TABLE Stg_Valuation;


CREATE TABLE Stg_StockData
(
[stock_date] NVARCHAR(100),
[symbol] NVARCHAR(5),
[open] VARCHAR(100),
[high] VARCHAR(100),
[low] VARCHAR(100),
[close] VARCHAR(100),
[volume] VARCHAR(100),
[divident_amount] VARCHAR(100)
);
--drop table Stg_CompanyOverview
CREATE TABLE [dbo].[Stg_CompanyOverview](
	[symbol] [varchar](100) NULL,
	[company_id] INT,
	[name] [varchar](100) NULL,
	[currency] [varchar](100) NULL,
	[country] [varchar](100) NULL,
	[sector] [varchar](100) NULL,
	[address] [varchar](200) NULL,
	[latest_quarter_date] [date] NULL,
	[full_time_employees] INT,
	[market_capitalization] [float] NULL,
	[dividend_per_share] [float] NULL,
	[dividend_yield] [float] NULL,
	[quarterly_earnings_growth] [float] NULL,
	[quarterly_revenue_growth] [float] NULL,
	[start_date] [date] NULL
) ON [PRIMARY]
GO


CREATE TABLE Stg_QuarterlyEarnings
(
[symbol] VARCHAR(100),
[fiscal_date_ending] VARCHAR(100),
[reported_date] VARCHAR(100),
[reported_EPS] VARCHAR(100),
[estimated_EPS] VARCHAR(100),
[surprise_EPS] VARCHAR(100),
[surprise_percentage] VARCHAR(100)
);

CREATE TABLE Stg_IncomeStatement
(
[symbol] VARCHAR(100),
[fiscal_date_ending] VARCHAR(100),
[reportedCurrency] VARCHAR(100),
[total_revenue] VARCHAR(100),
[gross_profit] VARCHAR(100),
[net_income] VARCHAR(100),
[total_operating_expense] VARCHAR(100),
[research_and_development_cost] VARCHAR(100)
);
--drop table Stg_Valuation
CREATE TABLE Stg_Valuation
(
[symbol] VARCHAR(100),
[valuation_date] DATE,
[price_to_earnings_ratio] FLOAT,
[price_to_sales_ratio] FLOAT,
[price_to_book_ratio] FLOAT
);

CREATE TABLE [dbo].[Stg_currency](
	[Country] [varchar](50) NULL,
	[CurrencyName] [varchar](50) NULL,
	[Currency] [varchar](50) NULL
) ON [PRIMARY]
GO
-------------------------ERD--------------------------------

DROP TABLE Dest_CompanyOverview;
DROP TABLE Dest_StockPrice;
DROP TABLE Dest_QuarterlyEarnings;
DROP TABLE Dest_IncomeStatement;
DROP TABLE Dest_Valuation;

DROP TABLE Dest_CompanyInfo;


CREATE TABLE Dest_CompanyInfo
(
[company_id] INT IDENTITY PRIMARY KEY,
[symbol] VARCHAR(10),
[name] VARCHAR(50),
[sector] VARCHAR(50),
[address] VARCHAR(200),
[old_address] VARCHAR(200),
[start_start] DATE,
[end_date] DATE,
[updated_date] DATE
);

CREATE TABLE Dest_CompanyOverview
(
[overview_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Dest_CompanyInfo([company_id]),
[latest_quarter_date] DATE,
[full_time_employees] INT,
[market_capitalization] FLOAT,
[dividend_per_share] FLOAT,
[dividend_yield] FLOAT,
[quarterly_earnings_growth] FLOAT,
[quarterly_revenue_growth] FLOAT,
[start_date] [date] NULL,
);

CREATE TABLE Dest_StockPrice
(
[price_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Dest_CompanyInfo([company_id]),
[open] FLOAT,
[high] FLOAT,
[low] FLOAT,
[close] FLOAT,
[volume] INT,
[divident_amount] FLOAT,
[stock_date] DATE,
[recorded_date] DATE
);

CREATE TABLE Dest_QuarterlyEarnings
(
[earn_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Dest_CompanyInfo([company_id]),
[fiscal_date_ending] DATE,
[reported_EPS] FLOAT,
[estimated_EPS] FLOAT,
[surprise_EPS] FLOAT,
[surprise_percentage] FLOAT,
[recorded_date] DATE
);

CREATE TABLE Dest_IncomeStatement
(
[statement_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Dest_CompanyInfo([company_id]),
[fiscal_date_ending] DATE,
[reportedCurrency] VARCHAR(30),
[total_revenue] FLOAT,
[gross_profit] FLOAT,
[net_income] FLOAT,
[total_operating_expense] FLOAT,
[research_and_development_cost] FLOAT,
[recorded_date] DATE
);

CREATE TABLE Dest_Valuation
(
[valuation_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Dest_CompanyInfo([company_id]),
[valuation_date] DATE,
[price_to_earnings_ratio] FLOAT,
[price_to_sales_ratio] FLOAT,
[price_to_book_ratio] FLOAT,
[recorded_date] DATE
);


-------------------------Star Schema--------------------------------

DROP TABLE StockDaily_Fact
DROP TABLE StockQuarter_Fact

DROP TABLE Company_Dimension
DROP TABLE Date_Dimension
DROP TABLE Sector_Dimension
DROP TABLE Currency_Dimension

CREATE TABLE Company_Dimension
(
[company_id] INT IDENTITY PRIMARY KEY,
[symbol] VARCHAR(5),
[company_name] VARCHAR(100),
[address] VARCHAR(200)
);

CREATE TABLE Sector_Dimension
(
[sector_id] INT IDENTITY PRIMARY KEY,
[sector] VARCHAR(30)
);

-------------Create date dimension---------
CREATE TABLE Date_Dimension
(
[date_id] INT IDENTITY PRIMARY KEY,
[TheDate] DATE,      
[TheDay] INT,      
[TheDayName] VARCHAR(30),      
[TheWeek] INT,         
[TheDayOfWeek] INT, 
[TheMonth] INT,      
[TheMonthName] VARCHAR(30),  
[TheQuarter] INT,    
[TheYear] INT
);

CREATE TABLE Currency_Dimension
(
[currency_id] INT IDENTITY PRIMARY KEY,
[currency] VARCHAR(30)
);


/***facts tables***/
CREATE TABLE StockDaily_Fact
(
[factSD_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Company_Dimension([company_id]),
[date_id] INT FOREIGN KEY REFERENCES Date_Dimension([date_id]),
[sector_id] INT FOREIGN KEY REFERENCES Sector_Dimension([sector_id]),
[currency_id] INT FOREIGN KEY REFERENCES Currency_Dimension([currency_id]),
[open] FLOAT,
[high] FLOAT,
[low] FLOAT,
[close] FLOAT,
[volume] FLOAT,
);

CREATE TABLE StockQuarter_Fact
(
[factSQ_id] INT IDENTITY PRIMARY KEY,
[company_id] INT FOREIGN KEY REFERENCES Company_Dimension([company_id]),
[date_id] INT FOREIGN KEY REFERENCES Date_Dimension([date_id]),
[sector_id] INT FOREIGN KEY REFERENCES Sector_Dimension([sector_id]),
[currency_id] INT FOREIGN KEY REFERENCES Currency_Dimension([currency_id]),
[full_time_employees] INT,
[market_capitalization] FLOAT,
[dividend_per_share] FLOAT,
[dividend_yield] FLOAT,
[reported_EPS]  FLOAT,
[surprise_EPS] FLOAT
);


/***end***/
Select * from  Stg_StockData
Select * from Stg_CompanyOverview
Select * from Stg_Valuation;

Select * from  Dest_CompanyOverview;
Select * from  Dest_StockPrice
Select * from  Dest_QuarterlyEarnings;
Select * from Dest_IncomeStatement;
Select * from  Dest_Valuation;
Select * from  Dest_CompanyInfo;

/***temp stg stock table***/
CREATE TABLE [dbo].[Stg_DailyStockData](
	[stock_date] [varchar](100) NULL,
	[symbol] [varchar](100) NULL,
	[open] [varchar](100) NULL,
	[high] [varchar](100) NULL,
	[low] [varchar](100) NULL,
	[close] [varchar](100) NULL,
	[volume] [varchar](100) NULL,
	[divident_amount] [varchar](100) NULL
) ON [PRIMARY]
GO


/***for company overview task***/
ALTER TABLE Stg_CompanyOverview
ADD company_id INT;

/***update company_id in staging table***/
UPDATE ExchangeAnalysis_GOOD.dbo.Stg_CompanyOverview
SET ExchangeAnalysis_GOOD.dbo.Stg_CompanyOverview.company_id = ExchangeAnalysis_GOOD.dbo.Dest_CompanyInfo.company_id

FROM ExchangeAnalysis_GOOD.dbo.Stg_CompanyOverview
INNER JOIN ExchangeAnalysis_GOOD.dbo.Dest_CompanyInfo
ON ExchangeAnalysis_GOOD.dbo.Stg_CompanyOverview.[symbol] = ExchangeAnalysis_GOOD.dbo.Dest_CompanyInfo.[symbol]


/***for SCD ***/
ALTER TABLE Stg_CompanyOverview
ADD start_date date;

/***stored procedure for SCD address***/
CREATE PROCEDURE UpdateAddress
@symbol VARCHAR(10),
@new_address VARCHAR(200)
AS
  DECLARE @address VARCHAR(200); 
  SELECT @address = (SELECT address FROM Dest_CompanyInfo WHERE symbol = @symbol);
  UPDATE Dest_CompanyInfo SET old_address = @address, address = @new_address, updated_date = GETDATE() 
  WHERE symbol = @symbol;


  /***error handling table***/
CREATE TABLE Err_dest_companyinfo
([company_id] INT IDENTITY PRIMARY KEY,
[symbol] VARCHAR(10),
[name] VARCHAR(50),
[sector] VARCHAR(50),
[address] VARCHAR(200),
start_date date,
[error_type] varchar(39) 
);



/***update the date dim***/
SET DATEFIRST  7, -- 1 = Monday, 7 = Sunday
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH

DECLARE @StartDate  date = '19800101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 60, @StartDate));

WITH seq(n) AS 
	(
	  SELECT 0 UNION ALL SELECT n + 1 FROM seq
	  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
	),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d)
  FROM d
)

INSERT INTO Date_Dimension
  SELECT * FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);


  /***quarterly temp fact table***/
CREATE TABLE Stg_QyuarFacts
(
[company_id] INT,
[date_id] INT,
[sector_id] INT,
[currency_id] INT,
[symbol] VARCHAR(5),
[name] VARCHAR(100),
[address] VARCHAR(200),
[sector] VARCHAR(30),
[currency] VARCHAR(30),
[full_time_employees] INT,
[market_capitalization] FLOAT,
[dividend_per_share] FLOAT,
[dividend_yield] FLOAT,
[reported_EPS] FLOAT,
[surprise_EPS]FLOAT,
[fiscal_date_ending] date
)

/***daily temp fact table***/
CREATE TABLE Stg_DayFacts
([company_id] INT,
[date_id] INT,
sector_id INT, 
currency_id INT,
[open] FLOAT,
[high] FLOAT,
[low] FLOAT,
[close] FLOAT,
[volume] FLOAT,
[Daily_Date] date
)


DROP TABLE Stg_DayFacts

DROP TABLE Stg_QyuarFacts


truncate table Stg_Facts;
truncate table Stg_QyuarFacts


select * from Stg_DayFacts

select * from Stg_QyuarFacts

/***
select company_id, max(stock_date) as latest_stockdate
from Dest_StockPrice
group by company_id
order by company_id
***/

/**stockprice***/
/**insert ***/
INSERT INTO
    Stg_DayFacts
(
[company_id],
[open],
[high],
[low],
[close],
[volume],
[Daily_Date])
	SELECT
	[company_id],
	[open],
	[high],
	[low],
	[close],
	[volume],
	[stock_date]
	From Dest_StockPrice


/**companyInfo***/
/**upodate statement***/
UPDATE Stg_QyuarFacts
SET 
Stg_QyuarFacts.[symbol] = Dest_CompanyInfo.[symbol],
Stg_QyuarFacts.[name] = Dest_CompanyInfo.[name],
Stg_QyuarFacts.[address] = Dest_CompanyInfo.[address],
Stg_QyuarFacts.[sector] = Dest_CompanyInfo.sector
From [Dest_CompanyInfo]
JOIN Stg_QyuarFacts
ON Dest_CompanyInfo.[company_id] = Stg_QyuarFacts.[company_id]



/***earning***/
/***insert***/
INSERT INTO
    Stg_QyuarFacts
(
[company_id],
[reported_EPS],
[surprise_EPS],
[fiscal_date_ending])
	SELECT
	[company_id],
	[reported_EPS],
	[surprise_EPS],
	[fiscal_date_ending]
	From Dest_QuarterlyEarnings



/***income statement***/
Update Stg_QyuarFacts
Set Stg_QyuarFacts.[currency] = Dest_IncomeStatement.[reportedCurrency]
From [Dest_IncomeStatement]
Join Stg_QyuarFacts
on Dest_IncomeStatement.company_id = Stg_QyuarFacts.company_id


/***company overview***/
UPDATE Stg_QyuarFacts
SET Stg_QyuarFacts.[full_time_employees] = Dest_CompanyOverview.[full_time_employees],
Stg_QyuarFacts.[market_capitalization] = Dest_CompanyOverview.[market_capitalization],
Stg_QyuarFacts.[dividend_per_share] = Dest_CompanyOverview.[dividend_per_share] ,
Stg_QyuarFacts.[dividend_yield] = Dest_CompanyOverview.[dividend_yield]

FROM Dest_CompanyOverview
Join Stg_QyuarFacts
on Dest_CompanyOverview.[company_id] = Stg_QyuarFacts.[company_id]
--WHERE Dest_CompanyOverview.[latest_quarter_date] = Stg_QyuarFacts.[fiscal_date_ending]

 

select * from Date_Dimension

/***update the date id in temp daily/quarterly fact table***/
UPDATE  Stg_DayFacts
SET Stg_DayFacts.[date_id] = Date_Dimension.[date_id]
FROM Stg_DayFacts
JOIN Date_Dimension
ON Stg_DayFacts.[Daily_Date] = Date_Dimension.[TheDate]

UPDATE  Stg_QyuarFacts
SET Stg_QyuarFacts.[date_id] = Date_Dimension.[date_id]
FROM Stg_QyuarFacts
JOIN Date_Dimension
ON Stg_QyuarFacts.[fiscal_date_ending] = Date_Dimension.[TheDate]


/***sector***/
INSERT INTO Sector_Dimension
( sector )
select distinct sector 
from Stg_QyuarFacts

--select *from Sector_Dimension


/***currency***/
INSERT INTO [Currency_Dimension] (currency)
SELECT DISTINCT Currency FROM Stg_QyuarFacts

--select * from Currency_Dimension

/***company***/
INSERT INTO [Company_Dimension] 
(symbol, company_name, address)
SELECT 
DISTINCT symbol,
name, 
address
FROM Stg_QyuarFacts

--select * from Company_Dimension

/***add IDs into temp stg_fact tables ***/
--ALTER TABLE Stg_DayFacts
---ADD sector_id INT, currency_id INT


UPDATE Stg_QyuarFacts
SET Stg_QyuarFacts.[sector_id] = Sector_Dimension.[sector_id],
Stg_QyuarFacts.[currency_id] = Currency_Dimension.[currency_id]
FROM Stg_QyuarFacts
join Sector_Dimension
on Stg_QyuarFacts.[sector] = Sector_Dimension.[sector]
join Currency_Dimension
on Stg_QyuarFacts.[currency] = Currency_Dimension.[currency]


UPDATE Stg_DayFacts
SET Stg_DayFacts.[sector_id] = Stg_QyuarFacts.[sector_id],
Stg_DayFacts.[currency_id] = Stg_QyuarFacts.[currency_id]
FROM Stg_DayFacts
JOIN Stg_QyuarFacts
ON Stg_DayFacts.[company_id] = Stg_QyuarFacts.[company_id]