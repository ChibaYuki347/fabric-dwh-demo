CREATE TABLE [dbo].[DailyBalance] (

	[BranchId] int NOT NULL, 
	[BusinessDate] date NOT NULL, 
	[DailyAmount] decimal(18,2) NOT NULL, 
	[TransactionCount] bigint NOT NULL, 
	[LoadedAt] datetime2(6) NOT NULL
);