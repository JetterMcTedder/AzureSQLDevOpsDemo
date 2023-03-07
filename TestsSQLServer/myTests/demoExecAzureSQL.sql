-- EXEC tSQLt.Run 'testFinancialApp';
BEGIN;
THROW 51000, 'Github Actions throw test.', 1;
end;
