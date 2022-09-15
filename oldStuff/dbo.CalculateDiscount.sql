/*--
DROP FUNCTION IF EXISTS dbo.CalculateDiscount;
GO
--*/
CREATE FUNCTION [dbo].[CalculateDiscount]
(
	@Value NUMERIC(13,2)
)
RETURNS TABLE
AS
RETURN
  SELECT CASE WHEN @Value >= 50 THEN @Value * 0.10 ELSE 0 END discount;
GO
