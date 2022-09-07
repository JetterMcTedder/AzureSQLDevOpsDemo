CREATE SCHEMA [dbo_ExampleProcedureTests] AUTHORIZATION [tSQLt.TestClass];
GO
CREATE PROCEDURE [dbo_ExampleProcedureTests].[test returns NULL AverageAmount if table is empty]
AS
BEGIN
  EXEC tSQLt.FakeTable 'dbo.ExampleTable';

  CREATE TABLE #Actual(
    AverageAmount DECIMAL(13,3)
  );

  INSERT INTO #Actual
  EXEC dbo.ExampleProcedure;

  SELECT TOP(0)A.* INTO #Expected FROM #Actual A RIGHT JOIN #Actual X ON 1=0;

  INSERT INTO #Expected VALUES(NULL);

  EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual';
END;
GO
CREATE PROCEDURE [dbo_ExampleProcedureTests].[test returns the value of the single row as AverageAmount if the table has only one row]
AS
BEGIN
  EXEC tSQLt.FakeTable 'dbo.ExampleTable';
  INSERT INTO dbo.ExampleTable (Amount) VALUES (12.12);
  
  CREATE TABLE #Actual(
    AverageAmount DECIMAL(13,3)
  );

  INSERT INTO #Actual
  EXEC dbo.ExampleProcedure;

  SELECT TOP(0)A.* INTO #Expected FROM #Actual A RIGHT JOIN #Actual X ON 1=0;

  INSERT INTO #Expected VALUES(12.12);

  EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual';
END;
GO
CREATE PROCEDURE [dbo_ExampleProcedureTests].[test returns the correct AverageAmount if the table has multiple rows]
AS
BEGIN
  EXEC tSQLt.FakeTable 'dbo.ExampleTable';
  INSERT INTO dbo.ExampleTable (Amount) VALUES (100), (200), (300);
  
  CREATE TABLE #Actual(
    AverageAmount DECIMAL(13,3)
  );

  INSERT INTO #Actual
  EXEC dbo.ExampleProcedure;

  SELECT TOP(0)A.* INTO #Expected FROM #Actual A RIGHT JOIN #Actual X ON 1=0;

  INSERT INTO #Expected VALUES(200);

  EXEC tSQLt.AssertEqualsTable @Expected = '#Expected', @Actual = '#Actual';
END;
GO
--[@tSQLt:SkipTest]('Fails on purpose, so let''s not run it!')
CREATE PROCEDURE [dbo_ExampleProcedureTests].[test failure]
AS
BEGIN
  EXEC tSQLt.Fail 'This test, you guessed correctly, is failing...'
END;
GO
