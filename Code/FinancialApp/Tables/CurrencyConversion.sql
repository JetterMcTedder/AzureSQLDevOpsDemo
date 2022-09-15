CREATE TABLE [FinancialApp].[CurrencyConversion] (
    [id]                 INT             NOT NULL,
    [sourceCurrency]     CHAR (3)        NOT NULL,
    [destCurrency]       CHAR (3)        NOT NULL,
    [conversionRate]     DECIMAL (10, 4) NOT NULL,
    [effectiveDate]      DATETIME        NOT NULL,
    [lastModifiedUserId] INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    FOREIGN KEY ([destCurrency]) REFERENCES [FinancialApp].[Currency] ([currencyCode]),
    FOREIGN KEY ([lastModifiedUserId]) REFERENCES [FinancialApp].[UserInfo] ([userId]),
    FOREIGN KEY ([sourceCurrency]) REFERENCES [FinancialApp].[Currency] ([currencyCode])
);
GO

