-- EXEC tSQLt.Run 'testFinancialApp';
BEGIN;
--THROW 51000, 'Github Actions throw test.', 1;
RAISERROR (15600, -1, -1, 'mysp_CreateCustomer');
end;
