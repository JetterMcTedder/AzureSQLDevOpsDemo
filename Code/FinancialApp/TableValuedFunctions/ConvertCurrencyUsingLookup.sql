
CREATE FUNCTION FinancialApp.ConvertCurrencyUsingLookup(
     @sourceCurrency CHAR(3),
     @destCurrency CHAR(3),
     @amount MONEY)
RETURNS TABLE
AS
RETURN
    SELECT amount = conversionRate * @amount
     FROM FinancialApp.CurrencyConversion
    WHERE sourceCurrency = @sourceCurrency
      AND destCurrency = @destCurrency;
GO

