EXEC sp_configure 'show advanced option', '1';
RECONFIGURE;
GO
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
GO
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO
