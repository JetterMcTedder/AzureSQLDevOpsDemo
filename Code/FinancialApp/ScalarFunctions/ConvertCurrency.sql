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

