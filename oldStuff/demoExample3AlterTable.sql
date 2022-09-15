----------------------------------------------------------------------------
-- Example 3
IF OBJECT_ID('FinancialApp.UserInfo') IS NOT NULL DROP TABLE FinancialApp.UserInfo;
GO
CREATE TABLE FinancialApp.UserInfo(
    userId INT PRIMARY KEY,
    name VARCHAR(MAX) NOT NULL
);
GO

ALTER TABLE FinancialApp.CurrencyConversion
    ADD lastModifiedUserId INT NOT NULL REFERENCES FinancialApp.UserInfo(userId);
GO