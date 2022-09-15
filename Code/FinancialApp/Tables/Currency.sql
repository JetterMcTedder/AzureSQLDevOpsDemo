CREATE TABLE [FinancialApp].[Currency] (
    [currencyCode] CHAR (3)       NOT NULL,
    [currencyName] NVARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([currencyCode] ASC)
);
GO

