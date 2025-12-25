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


-- I have done for menu items to get --
USE [RestaurantDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetMenuItem]    Script Date: 12/16/2025 3:24:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[sp_GetMenuItem]  
    @Username VARCHAR(300)  
AS  
BEGIN  
    BEGIN TRY  
        DECLARE @UserId INT;  
        SET @UserId = (SELECT Id FROM Users WHERE Username = @Username);  
        SELECT  
            item_id,  
            subcategory_id,  
            item_name,  
            description,  
            image_data,  
            price1,  
            price2,  
            count1,  
            count2,  
            title,  
            CreatedDate,  
            CreatedBy,  
            ModifiedDate,  
            ModifiedBy,  
            IsActive  
        FROM menu_items  
        WHERE IsActive = 1 OR IsActive = 0 AND CreatedBy = @UserId;  
    END TRY  
    BEGIN CATCH  
        SELECT ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH  
END;  



---- In thids I Have done in sir laptop 

CREATE   or ALter    PROCEDURE [dbo].[sp_GetOrdersByUserId]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            o.Id,
            o.OrderId,
            o.OrderStatus AS OrderStatusId,
            o.FullPortion,
            o.HalfPortion,
            o.TableNo,
            o.CreatedDate,
            o.CreatedBy,
            o.ModifiedDate,
            o.ModifiedBy,
            mi.item_name AS ItemName,       
            o.IsActive,
            o.item_id,
            o.Price,
            o.customerName,
            o.phone,
            o.OrderType,
            o.Address,
            o.payment_mode,
            o.DeliveryType,
            o.specialInstructions,
            osm.Name AS OrderStatus,       
            u.Username,
            u.Name,
            OS.DiscountAmount,
            o.CreatedDate AS [Date],      
            o.UserId AS [userId]            
        FROM Orders o
        INNER JOIN Users u ON o.UserId = u.Id
        LEFT JOIN menu_items mi ON mi.item_id = o.item_id 
        LEFT JOIN OrderSummary OS ON OS.OrderId = o.OrderId 
        LEFT JOIN OrderStatusMaster osm ON osm.Id = o.OrderStatus  
        WHERE o.UserId = @UserId
            
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;

-- =========================
-- Menu Category Procedures
-- =========================
 
-- Save (Insert) Menu Category
CREATE OR ALTER PROCEDURE sp_SaveMenuCategory
    @CategoryName NVARCHAR(100),
    @Description TEXT = NULL,
    @CreatedBy INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    INSERT INTO menu_categories (category_name, description, CreatedDate, CreatedBy, IsActive)
    VALUES (@CategoryName, @Description, GETDATE(), @CreatedBy, @IsActive)
END
GO
 
-- Update Menu Category
CREATE OR ALTER PROCEDURE sp_UpdateMenuCategory
    @CategoryId INT,
    @CategoryName NVARCHAR(100),
    @Description TEXT = NULL,
    @ModifiedBy INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    UPDATE menu_categories
    SET
        category_name = @CategoryName,
        description = @Description,
        ModifiedDate = GETDATE(),
        ModifiedBy = @ModifiedBy,
        IsActive = @IsActive
    WHERE category_id = @CategoryId
END
GO
 
-- =========================
-- Menu Subcategory Procedures
-- =========================
 
-- Save (Insert) Menu Subcategory
CREATE OR ALTER PROCEDURE sp_SaveMenuSubcategory
    @CategoryId INT,
    @SubcategoryName NVARCHAR(255),
    @Description TEXT = NULL,
    @DisplayOrder INT = NULL,
    @CreatedBy INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    INSERT INTO menu_subcategories (category_id, subcategory_name, description, display_order, CreatedDate, CreatedBy, IsActive)
    VALUES (@CategoryId, @SubcategoryName, @Description, @DisplayOrder, GETDATE(), @CreatedBy, @IsActive)
END
GO
 
-- Update Menu Subcategory
CREATE OR ALTER PROCEDURE sp_UpdateMenuSubcategory
    @SubcategoryId INT,
    @CategoryId INT,
    @SubcategoryName NVARCHAR(255),
    @Description TEXT = NULL,
    @DisplayOrder INT = NULL,
    @ModifiedBy INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    UPDATE menu_subcategories
    SET
        category_id = @CategoryId,
        subcategory_name = @SubcategoryName,
        description = @Description,
        display_order = @DisplayOrder,
        ModifiedDate = GETDATE(),
        ModifiedBy = @ModifiedBy,
        IsActive = @IsActive
    WHERE subcategory_id = @SubcategoryId
END
GO
 
-- =========================
-- Menu Item Procedures
-- =========================
 
-- Save (Insert) Menu Item
CREATE OR ALTER PROCEDURE sp_SaveMenuItem
    @SubcategoryId INT,
    @ItemName NVARCHAR(255),
    @Description TEXT = NULL,
    @ImageSrc VARCHAR(MAX) = NULL,
    @Price1 DECIMAL(10,2) = NULL,
    @Price2 DECIMAL(10,2) = NULL,
    @Count1 INT = NULL,
    @Count2 INT = NULL,
    @Title NVARCHAR(255) = NULL,
    @CreatedBy INT = NULL,
    @IsActive BIT = 1,
    @ImageData VARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO menu_items (
        subcategory_id, item_name, description, image_src, price1, price2, count1, count2, title,
        CreatedDate, CreatedBy, IsActive, image_data
    )
    VALUES (
        @SubcategoryId, @ItemName, @Description, @ImageSrc, @Price1, @Price2, @Count1, @Count2, @Title,
        GETDATE(), @CreatedBy, @IsActive, @ImageData
    )
END
GO
 
-- Update Menu Item
CREATE OR ALTER PROCEDURE sp_UpdateMenuItem
    @ItemId INT,
    @SubcategoryId INT,
    @ItemName NVARCHAR(255),
    @Description TEXT = NULL,
    @ImageSrc VARCHAR(MAX) = NULL,
    @Price1 DECIMAL(10,2) = NULL,
    @Price2 DECIMAL(10,2) = NULL,
    @Count1 INT = NULL,
    @Count2 INT = NULL,
    @Title NVARCHAR(255) = NULL,
    @ModifiedBy INT = NULL,
    @IsActive BIT = 1,
    @ImageData VARCHAR(MAX) = NULL
AS
BEGIN
    UPDATE menu_items
    SET
        subcategory_id = @SubcategoryId,
        item_name = @ItemName,
        description = @Description,
        image_src = @ImageSrc,
        price1 = @Price1,
        price2 = @Price2,
        count1 = @Count1,
        count2 = @Count2,
        title = @Title,
        ModifiedDate = GETDATE(),
        ModifiedBy = @ModifiedBy,
        IsActive = @IsActive,
        image_data = @ImageData
    WHERE item_id = @ItemId
END
GO

USE [RestaurantDb]
GO
/****** Object:  StoredProcedure [dbo].[sp_UpdateMenuItem]    Script Date: 16.12.2025 2.39.15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- Update Menu Item
Create   PROCEDURE sp_SaveSetTableCount
    @TableCount INT
AS
BEGIN
   update UserTableMaster set TableCount = @TableCount
END
===================================================
 
CREATE or ALTER PROCEDURE sp_GetMenuCategory    
    @Username VARCHAR(300)    
AS    
BEGIN    
    BEGIN TRY    
        DECLARE @UserId INT;    
        SET @UserId = (SELECT Id FROM Users WHERE Username = @Username);    
        PRINT(@UserId);    
        SELECT    
            category_id,    
            category_name,    
            description,    
            CreatedDate,    
            CreatedBy,    
            ModifiedDate,    
            ModifiedBy,    
            IsActive    
        FROM menu_categories    
        WHERE IsActive = 1 --AND CreatedBy = @UserId;    
    END TRY    
    BEGIN CATCH    
        SELECT ERROR_MESSAGE() AS ErrorMessage;    
    END CATCH    
END;
===================================================
CREATE OR ALTER PROCEDURE sp_SaveMenuCategory
    @CategoryName NVARCHAR(100),
    @Description TEXT = NULL,
    @CreatedBy INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    IF EXISTS (SELECT 1 FROM menu_categories WHERE category_name = @CategoryName)
    BEGIN
        -- Optionally, you can return a specific error code or message
        RAISERROR('Category name already exists.', 16, 1)
        RETURN
    END
 
    INSERT INTO menu_categories (category_name, description, CreatedDate, CreatedBy, IsActive)
    VALUES (@CategoryName, @Description, GETDATE(), @CreatedBy, @IsActive)
END
GO

USE [RestaurantDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_ResetPassword]    Script Date: 17.12.2025 9.26.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_ResetPassword]
(
    @Phone NVARCHAR(20),
    @Password NVARCHAR(200),
    @RowsAffected INT OUTPUT
)
AS
BEGIN
    UPDATE Users
    SET Password = @Password
    WHERE Phone = @Phone;

    SET @RowsAffected = @@ROWCOUNT;
END

-- Create Procedure --   for getOrderId
CREATE PROCEDURE sp_GetBillByOrderId
    @OrderId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE s.OrderId = @OrderId
    ORDER BY o.Id ASC;
END
GO


-- this is modified sp-- 
 ALTER PROCEDURE [dbo].[sp_LoginUser]
    @loginame NVARCHAR(100),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 u.Username, u.Password, u.Name, u.CreatedDate, u.IsActive,o.Address
    FROM Users u
	left Join Orders as o ON u.Id = o.UserId
    WHERE Username = @loginame AND Password = @Password AND u.IsActive = 1
	order by o.id desc
END

USE [RestaurantDB]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE OR ALTER PROCEDURE [dbo].[sp_GetBillByOrderId]
    @OrderId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
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
    INNER JOIN Orders o ON s.OrderId = o.OrderId
    LEFT JOIN menu_items mi ON mi.item_id = o.item_id
    WHERE s.OrderId = @OrderId
    ORDER BY o.Id ASC;
END
GO
--- Address sp --- 
CREATE or alter PROCEDURE sp_GetCustomerAddress
    @UserId Varchar(1000)
   
AS
BEGIN
    SET NOCOUNT ON;

    -- Prefer UserId
    IF (@UserId IS NOT NULL AND @UserId > 0)
    BEGIN
        SELECT TOP 1
            Address
        FROM Orders
        WHERE UserId = @UserId
          AND IsActive = 1
        ORDER BY CreatedDate DESC;
        RETURN;
    END
   
END



Insert into AppSettings(SettingKey , SettingValue)
values('FixedDiscount',10);


CREATE PROCEDURE Sp_getFixedDiscount
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SettingKey
    FROM AppSettings
    WHERE Id = 3;
END;


