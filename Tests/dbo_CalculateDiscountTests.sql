/*--
EXEC tSQLt.DropClass [dbo_CalculateDiscountTests];
GO
--*/
CREATE SCHEMA [dbo_CalculateDiscountTests] AUTHORIZATION [tSQLt.TestClass];
GO
CREATE PROCEDURE dbo_CalculateDiscountTests.[test returns no discount for order value 49.00]
AS
BEGIN
  --Assemble

  --Act
  DECLARE @Actual NUMERIC(13,2) = (SELECT discount FROM dbo.CalculateDiscount(49.00) AS CD);

  --Assert
  EXEC tSQLt.AssertEquals @Expected = 0, @Actual = @Actual;

END;
GO
CREATE PROCEDURE dbo_CalculateDiscountTests.[test returns 10% discount for order value 51.00]
AS
BEGIN
  --Assemble

  --Act
  DECLARE @Actual NUMERIC(13,2) = (SELECT discount FROM dbo.CalculateDiscount(51.00) AS CD);

  --Assert
  EXEC tSQLt.AssertEquals @Expected = 5.10, @Actual = @Actual;

END;
GO
CREATE PROCEDURE dbo_CalculateDiscountTests.[test returns 10% discount for order value 50.00]
AS
BEGIN
  --Assemble

  --Act
  DECLARE @Actual NUMERIC(13,2) = (SELECT discount FROM dbo.CalculateDiscount(50.00) AS CD);

  --Assert
  EXEC tSQLt.AssertEquals @Expected = 5.00, @Actual = @Actual;

END;
GO
