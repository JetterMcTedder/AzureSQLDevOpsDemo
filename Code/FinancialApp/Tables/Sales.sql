CREATE TABLE [FinancialApp].[Sales] (
    [id]         INT      NOT NULL,
    [amount]     MONEY    NOT NULL,
    [currency]   CHAR (3) NOT NULL,
    [customerId] INT      NOT NULL,
    [employeeId] INT      NOT NULL,
    [itemId]     INT      NOT NULL,
    [date]       DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

ALTER TABLE [FinancialApp].[Sales]
    ADD CONSTRAINT [validCurrency] FOREIGN KEY ([currency]) REFERENCES [FinancialApp].[Currency] ([currencyCode]);
GO

