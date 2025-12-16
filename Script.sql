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


----Add Table ---
Alter Table OrderSummary
Add specialInstruction Nvarchar(max)

--  SP for Get Order   ---



CREATE  OR ALTER PROCEDURE [dbo].[sp_GetOrderHistory]
    @Username VARCHAR(300)
AS
BEGIN
    BEGIN TRY
        
        DECLARE @UserId INT;
        SET @UserId = (SELECT Id FROM Users WHERE Username = @Username);

        SELECT
            o.OrderId,
            o.CustomerName,
            o.Phone,
            o.TableNo,
             mi.item_name AS ItemName,      
            o.FullPortion,
            o.HalfPortion,
            o.Price,
            o.specialInstructions,
            os.TotalAmount,
            os.DiscountAmount,
            os.FinalAmount,
            o.Payment_Mode AS PaymentMode,
            o.CreatedDate AS Date
        FROM Orders o
        LEFT JOIN OrderSummary os 
            ON os.OrderId = o.OrderId
		LEFT JOIN menu_items mi ON mi.item_id = o.item_id 
        WHERE 
            o.CreatedBy = @UserId

			 AND o.IsActive = 0 
        ORDER BY 
            o.CreatedDate DESC,	
            o.OrderId DESC;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;

---only active order show ---

            SELECT 
    s.SummaryId,
    s.OrderId,
    s.CustomerName,
    s.Phone,
    s.TotalAmount,
    s.DiscountAmount,
    s.FinalAmount,
    s.CreatedDate,
    s.CompletedDate,

    o.item_id,
    mi.item_name AS ItemName,   
    o.Price,
    o.FullPortion,
    o.HalfPortion,
    o.TableNo,
    o.OrderStatus,
    o.OrderType,
	o.specialInstructions,
    o.payment_mode

FROM OrderSummary s
INNER JOIN Orders o 
    ON s.OrderId = o.OrderId
LEFT JOIN menu_items mi              
    ON mi.item_id = o.item_id
WHERE s.OrderId = @OrderId  AND o.OrderStatus = 4
ORDER BY o.Id ASC;



--- this is for thec check button for the forget password in ui so that we can check the number exizt or not ----
CREATE PROCEDURE sp_CheckPhoneExists
    @Phone NVARCHAR(20),
    @Exists BIT OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE PhoneNumber = @Phone)
        SET @Exists = 1;
    ELSE
        SET @Exists = 0;
END

