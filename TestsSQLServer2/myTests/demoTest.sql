--EXEC tSQLt.DropClass 'testFinancialApp';
--GO
CREATE SCHEMA testFinancialApp;
GO

----------------------------------------------------------------------------
-- Example 1 -- AssertEquals 
CREATE PROCEDURE testFinancialApp.[test that ConvertCurrency converts using given conversion rate]
AS
BEGIN
    DECLARE @actual MONEY;
    DECLARE @rate DECIMAL(10,4); SET @rate = 1.2;
    DECLARE @amount MONEY; SET @amount = 2.00;

    SELECT @actual = FinancialApp.ConvertCurrency(@rate, @amount);

    DECLARE @expected MONEY; SET @expected = 2.4;   --(rate * amount)
    EXEC tSQLt.AssertEquals @expected, @actual;

END;
GO

----------------------------------------------------------------------------
-- Example 2 -- FakeTable
CREATE PROCEDURE testFinancialApp.[test that ConvertCurrencyUsingLookup converts using conversion rate in CurrencyConversion table]
AS
BEGIN
    DECLARE @expected MONEY; SET @expected = 3.2;
    DECLARE @actual MONEY;
    DECLARE @amount MONEY; SET @amount = 2.00;
    DECLARE @sourceCurrency CHAR(3); SET @sourceCurrency = 'EUR';
    DECLARE @destCurrency CHAR(3); SET @destCurrency = 'USD';

------Fake Table
    EXEC tSQLt.FakeTable 'FinancialApp', 'CurrencyConversion';

    INSERT INTO FinancialApp.CurrencyConversion (id, sourceCurrency, destCurrency, conversionRate)
                                         VALUES (1, @sourceCurrency, @destCurrency, 1.6);
------Execution
    SELECT @actual = amount FROM FinancialApp.ConvertCurrencyUsingLookup(@sourceCurrency, @destCurrency, @amount);

------Assertion
    EXEC tSQLt.AssertEquals @expected, @actual;
END;
GO

----------------------------------------------------------------------------
-- Example 3 -- Create a new Foreign Key constraint
-- No new test code, show how FakeTable prevents fragile tests


----------------------------------------------------------------------------
-- Example 4 -- AssertEqualsTable (Table Comparison)
CREATE PROCEDURE testFinancialApp.[test that Report gets sales data with converted currency]
AS
BEGIN
    IF OBJECT_ID('actual') IS NOT NULL DROP TABLE actual;
    IF OBJECT_ID('expected') IS NOT NULL DROP TABLE expected;


------Fake Table
    EXEC tSQLt.FakeTable 'FinancialApp', 'CurrencyConversion';
    EXEC tSQLt.FakeTable 'FinancialApp', 'Sales';

    INSERT INTO FinancialApp.CurrencyConversion (id, sourceCurrency, destCurrency, conversionRate)
                                         VALUES (1, 'EUR', 'USD', 1.6);
    INSERT INTO FinancialApp.CurrencyConversion (id, sourceCurrency, destCurrency, conversionRate)
                                         VALUES (2, 'GBP', 'USD', 1.2);

    INSERT INTO FinancialApp.Sales (id, amount, currency, customerId, employeeId, itemId, date)
                                         VALUES (1, '1050.00', 'GBP', 1000, 7, 34, '1/1/2007');
    INSERT INTO FinancialApp.Sales (id, amount, currency, customerId, employeeId, itemId, date)
                                         VALUES (2, '4500.00', 'EUR', 2000, 19, 24, '1/1/2008');

------Execution
    SELECT amount, currency, customerId, employeeId, itemId, date
      INTO actual
      FROM FinancialApp.Report('USD');

------Assertion
    CREATE TABLE expected (
	    amount MONEY,
	    currency CHAR(3),
	    customerId INT,
	    employeeId INT,
	    itemId INT,
	    date DATETIME
    );

	INSERT INTO expected (amount, currency, customerId, employeeId, itemId, date) SELECT 1260.00, 'USD', 1000, 7, 34, '2007-01-01';
	INSERT INTO expected (amount, currency, customerId, employeeId, itemId, date) SELECT 7200.00, 'USD', 2000, 19, 24, '2008-01-01';

	EXEC tSQLt.AssertEqualsTable 'actual', 'expected';
END;
GO

----------------------------------------------------------------------------
-- Example 5 -- SpyProcedure
CREATE PROCEDURE testFinancialApp.[test that SalesReport calls HistoricalReport instead of CurrentReport when @showHistory = 1]
AS
BEGIN
-------Assemble
    EXEC tSQLt.SpyProcedure 'FinancialApp.HistoricalReport';
    EXEC tSQLt.SpyProcedure 'FinancialApp.CurrentReport';

-------Act
    EXEC FinancialApp.SalesReport 'USD', @showHistory = 1;

    SELECT currency
      INTO actual
      FROM FinancialApp.HistoricalReport_SpyProcedureLog;

-------Assert HistoricalReport got called with right parameter
    SELECT currency
      INTO expected
      FROM (SELECT 'USD') ex(currency);

    EXEC tSQLt.AssertEqualsTable 'actual', 'expected';
    
-------Assert CurrentReport did not get called
    IF EXISTS (SELECT 1 FROM FinancialApp.CurrentReport_SpyProcedureLog)
       EXEC tSQLt.Fail 'SalesReport should not have called CurrentReport when @showHistory = 1';
END;
GO

CREATE PROCEDURE testFinancialApp.[test that SalesReport calls CurrentReport when @showHistory = 0]
AS
BEGIN
-------Assemble
    EXEC tSQLt.SpyProcedure 'FinancialApp.HistoricalReport';
    EXEC tSQLt.SpyProcedure 'FinancialApp.CurrentReport';

-------Act
    EXEC FinancialApp.SalesReport 'USD', @showHistory = 0;

    SELECT currency
      INTO actual
      FROM FinancialApp.CurrentReport_SpyProcedureLog;

-------Assert
    SELECT currency
      INTO expected
      FROM (SELECT 'USD') ex(currency);

    EXEC tSQLt.AssertEqualsTable 'actual', 'expected';

    IF EXISTS (SELECT 1 FROM FinancialApp.HistoricalReport_SpyProcedureLog)
       EXEC tSQLt.Fail 'SalesReport should not have called HistoricalReport when @showHistory = 0';
END;
GO

----------------------------------------------------------------------------
-- Example 6 -- ApplyConstraint
CREATE PROCEDURE testFinancialApp.[test that Sales table does not allow invalid currency]
AS
BEGIN
    DECLARE @errorThrown bit; SET @errorThrown = 0;

    EXEC tSQLt.FakeTable 'FinancialApp', 'Sales';
    EXEC tSQLt.ApplyConstraint 'FinancialApp', 'Sales', 'validCurrency';

    BEGIN TRY
        INSERT INTO FinancialApp.Sales (id, currency)
                                VALUES (1, 'XYZ');
    END TRY
    BEGIN CATCH
        SET @errorThrown = 1;
    END CATCH;    

    IF (@errorThrown = 0 OR (EXISTS (SELECT 1 FROM FinancialApp.Sales)))
    BEGIN
        EXEC tSQLt.Fail 'Sales table should not allow invalid currency';
    END;

    IF EXISTS (SELECT 1 FROM FinancialApp.Sales)
        EXEC tSQLt.Fail 'Sales table should not allow invalid currency';
END;
GO

----------------------------------------------------------------------------
-- Example 7 - Replace check constraint with FK
