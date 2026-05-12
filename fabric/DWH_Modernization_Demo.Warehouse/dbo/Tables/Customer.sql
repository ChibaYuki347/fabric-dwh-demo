CREATE TABLE [dbo].[Customer] (

	[CustomerId] int NOT NULL, 
	[CustomerSegment] varchar(20) NULL, 
	[OpenDate] date NULL, 
	[RiskScore] decimal(5,2) NULL, 
	[UpdatedAt] datetime2(6) NULL
);