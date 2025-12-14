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

USE [RestaurantDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_UpdateTableOrderStatus]  
    @OrderId NVARCHAR(50),  
    @StatusId INT,  
    @Payment_mode NVARCHAR(50),  
    @RowsAffected INT OUTPUT  
AS  
BEGIN  
    UPDATE dbo.Orders  
    SET   
        OrderStatus = @StatusId,  
        payment_mode = @Payment_mode,  
        ModifiedDate = GETDATE(),  
        IsActive = CASE WHEN @StatusId = 3 THEN 0 ELSE IsActive END  
    WHERE OrderId = @OrderId  and OrderStatus != 4;  
  
    SET @RowsAffected = @@ROWCOUNT;  
  
    SELECT O.Id AS OrderPrimaryKey, O.OrderId, O.OrderStatus  
    FROM dbo.Orders O  
    WHERE O.OrderId = @OrderId;  
END 

