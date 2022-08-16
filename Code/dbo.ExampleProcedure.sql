CREATE PROCEDURE [dbo].[ExampleProcedure]
AS
BEGIN
  SELECT AVG(Amount)
    FROM dbo.ExampleTable
END;
GO
