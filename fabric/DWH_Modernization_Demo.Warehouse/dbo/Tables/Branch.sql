CREATE TABLE [dbo].[Branch] (

	[BranchId] int NOT NULL, 
	[BranchName] varchar(60) NOT NULL, 
	[RegionCode] varchar(10) NULL, 
	[OpenDate] date NULL, 
	[StatusCode] char(1) NULL, 
	[UpdatedAt] datetime2(6) NULL
);