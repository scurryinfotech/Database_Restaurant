/****** Change Dynamic userid ******/
USE [RestaurantDB]
GO

/****** Object:  Table [dbo].[AppSettings]    Script Date: 12/13/2025 8:06:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AppSettings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SettingKey] [nvarchar](100) NULL,
	[SettingValue] [nvarchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



  SELECT *  FROM [RestaurantDB].[dbo].[AppSettings]
  where SettingKey='IsOrderingAvailableOnline';

  update [RestaurantDB].[dbo].[AppSettings]
  set SettingValue='true' where SettingKey='IsOrderingAvailableOnline'
