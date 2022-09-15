
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

