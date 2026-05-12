CREATE TABLE [dbo].[Transaction] (

	[TransactionId] bigint NOT NULL, 
	[AccountId] bigint NOT NULL, 
	[TransactionDate] date NOT NULL, 
	[Amount] decimal(18,2) NOT NULL, 
	[ChannelCode] varchar(10) NULL, 
	[UpdatedAt] datetime2(6) NULL
);