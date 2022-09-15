IF OBJECT_ID('FinancialApp.CurrentReport') IS NOT NULL DROP PROCEDURE FinancialApp.CurrentReport;
IF OBJECT_ID('FinancialApp.HistoricalReport') IS NOT NULL DROP PROCEDURE FinancialApp.HistoricalReport;
IF OBJECT_ID('FinancialApp.SalesReport') IS NOT NULL DROP PROCEDURE FinancialApp.SalesReport;
IF OBJECT_ID('FinancialApp.Report') IS NOT NULL DROP FUNCTION FinancialApp.Report;
IF OBJECT_ID('FinancialApp.Sales') IS NOT NULL DROP TABLE FinancialApp.Sales;
IF OBJECT_ID('FinancialApp.ConvertCurrency') IS NOT NULL DROP FUNCTION FinancialApp.ConvertCurrency;
IF OBJECT_ID('FinancialApp.ConvertCurrencyUsingLookup') IS NOT NULL DROP FUNCTION FinancialApp.ConvertCurrencyUsingLookup;
IF OBJECT_ID('FinancialApp.CurrencyConversion') IS NOT NULL DROP TABLE FinancialApp.CurrencyConversion;
IF OBJECT_ID('FinancialApp.Currency') IS NOT NULL DROP TABLE FinancialApp.Currency;
IF OBJECT_ID('FinancialApp.UserInfo') IS NOT NULL DROP TABLE FinancialApp.UserInfo;
IF EXISTS(SELECT * FROM sys.schemas WHERE NAME = 'FinancialApp') DROP SCHEMA FinancialApp;
GO

------------------------------------------------------------------------------
-- Example 1

CREATE SCHEMA FinancialApp;
GO
CREATE FUNCTION FinancialApp.ConvertCurrency(
    @rate DECIMAL(10,4),
    @amount MONEY)
RETURNS MONEY
AS
BEGIN
    DECLARE @NewAmount MONEY;
    SELECT @NewAmount = @amount * @rate;
    RETURN @NewAmount;
END;
GO
RAISERROR('Example 1 installed',0,1) WITH NOWAIT;
GO
----------------------------------------------------------------------------
-- Example 2
CREATE TABLE FinancialApp.Currency (
    currencyCode CHAR(3) PRIMARY KEY,
    currencyName NVARCHAR(100) NOT NULL
);
INSERT INTO FinancialApp.Currency(currencyCode, currencyName) VALUES('USD','Dollar')
INSERT INTO FinancialApp.Currency(currencyCode, currencyName) VALUES('GBP','Pound')
INSERT INTO FinancialApp.Currency(currencyCode, currencyName) VALUES('EUR','Euro')

GO

CREATE TABLE [FinancialApp].[CurrencyConversion] (
    [id]                 INT             NOT NULL,
    [sourceCurrency]     CHAR (3)        NOT NULL,
    [destCurrency]       CHAR (3)        NOT NULL,
    [conversionRate]     DECIMAL (10, 4) NOT NULL,
    [effectiveDate]      DATETIME        NOT NULL,
    [lastModifiedUserId] INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    FOREIGN KEY ([destCurrency]) REFERENCES [FinancialApp].[Currency] ([currencyCode]),
    FOREIGN KEY ([lastModifiedUserId]) REFERENCES [FinancialApp].[UserInfo] ([userId]),
    FOREIGN KEY ([sourceCurrency]) REFERENCES [FinancialApp].[Currency] ([currencyCode])
);
GO

CREATE FUNCTION FinancialApp.ConvertCurrencyUsingLookup(
     @sourceCurrency CHAR(3),
     @destCurrency CHAR(3),
     @amount MONEY)
RETURNS TABLE
AS
RETURN
    SELECT amount = ConversionRate * @amount
     FROM FinancialApp.CurrencyConversion
    WHERE sourceCurrency = @sourceCurrency
      AND destCurrency = @destCurrency;

GO

RAISERROR('Example 2 installed',0,1) WITH NOWAIT;
GO
----------------------------------------------------------------------------
-- Example 3
-- ALTER TABLE in other file

----------------------------------------------------------------------------
-- Example 4
CREATE TABLE [FinancialApp].[Sales] (
    [id]         INT      NOT NULL,
    [amount]     MONEY    NOT NULL,
    [currency]   CHAR (3) NOT NULL,
    [customerId] INT      NOT NULL,
    [employeeId] INT      NOT NULL,
    [itemId]     INT      NOT NULL,
    [date]       DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

CREATE FUNCTION FinancialApp.Report (
    @currency CHAR(3)
) 
RETURNS TABLE
AS
RETURN 
   SELECT cc.amount, @currency currency,
          customerId, employeeId, itemId, date
     FROM FinancialApp.Sales s
    CROSS APPLY FinancialApp.ConvertCurrencyUsingLookup(s.currency, @currency, s.amount) cc;
GO

RAISERROR('Example 4 installed',0,1) WITH NOWAIT;
GO
----------------------------------------------------------------------------
-- Example 5
CREATE PROCEDURE FinancialApp.HistoricalReport
   @currency CHAR(3)
AS
BEGIN
   RETURN 0;
END;
GO

CREATE PROCEDURE FinancialApp.CurrentReport
   @currency CHAR(3)
AS
BEGIN
   RETURN 0;
END;
GO

CREATE PROCEDURE FinancialApp.SalesReport
   @currency CHAR(3),
   @showHistory BIT = 0
AS
BEGIN
   IF(@showHistory = 0)
     EXEC FinancialApp.CurrentReport @currency;
   ELSE
     EXEC FinancialApp.HistoricalReport @currency;
   RETURN 0;
END;
GO
RAISERROR('Example 5 installed',0,1) WITH NOWAIT;
GO
----------------------------------------------------------------------------
-- Example 6
RAISERROR('Example 6a installed',0,1) WITH NOWAIT;
GO

--
ALTER TABLE FinancialApp.Sales DROP CONSTRAINT validCurrency;

ALTER TABLE FinancialApp.Sales ADD CONSTRAINT validCurrency CHECK (currency IN ('USD', 'GBP', 'EUR'));
GO
RAISERROR('Example 6b installed',0,1) WITH NOWAIT;
GO

----------------------------------------------------------------------------
-- Example 7

ALTER TABLE FinancialApp.Sales DROP CONSTRAINT validCurrency;

ALTER TABLE FinancialApp.Sales ADD CONSTRAINT validCurrency FOREIGN KEY (currency) REFERENCES FinancialApp.Currency(currencyCode);
GO
RAISERROR('Example 7 installed',0,1) WITH NOWAIT;
GO

ALTER TABLE [FinancialApp].[Sales]
    ADD CONSTRAINT [validCurrency] FOREIGN KEY ([currency]) REFERENCES [FinancialApp].[Currency] ([currencyCode]);
GO

