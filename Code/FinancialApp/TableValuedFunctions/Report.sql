
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

