CREATE TABLE [dbo].[Account] (

	[AccountId] bigint NOT NULL, 
	[CustomerId] int NOT NULL, 
	[BranchId] int NOT NULL, 
	[AccountType] varchar(20) NULL, 
	[StatusCode] char(1) NULL, 
	[OpenDate] date NULL, 
	[UpdatedAt] datetime2(6) NULL
);