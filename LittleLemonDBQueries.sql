show databases;
use little_lemon_db;
show tables;
select * from Bookings;

CREATE VIEW OrdersView AS
SELECT OrderID, Quantity, BillAmount
FROM Orders
WHERE Quantity > 2;

show tables;
-- ALTER TABLE Orders
-- ADD COLUMN CustomersID INT UNIQUE;


SELECT 
    Customers.CustomersID,
    Customers.Name,
    Orders.OrderID,
    Orders.BillAmount,
    Menus.Cuisine,
    MenuItems.Name,
    MenuItems.Type,
    MenuItems.Price
FROM 
    Orders
JOIN 
    Customers ON Orders.CustomersID = Customers.CustomersID
JOIN 
    Menus ON Orders.MenuID = Menus.MenuID
JOIN 
    MenuItems ON Menus.ItemID = MenuItems.ItemID
WHERE 
    Orders.BillAmount > 150
ORDER BY 
    Orders.BillAmount ASC;
    

SELECT 
    Menus.Cuisine
FROM 
    Menus
WHERE 
    Menus.MenuID = ANY (
        SELECT 
            Orders.MenuID
        FROM 
            Orders
        GROUP BY 
            Orders.MenuID
        HAVING 
            COUNT(Orders.OrderID) > 2
    );
    
    
DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity
    FROM Orders;
END //

DELIMITER ;

-- Call the stored procedure to get the maximum ordered quantity
CALL GetMaxQuantity();



-- Create prepared Statement
PREPARE GetOrderDetail FROM
'SELECT OrderID, Quantity, BillAmount
FROM Orders
WHERE CustomersID = ?';

-- Setting the variable with CustomerID value
SET @id = 1; 
-- Execute Statement
EXECUTE GetOrderDetail USING @id;


DELIMITER //

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    DECLARE row_count INT;
    
    -- Delete the order
    DELETE FROM Orders
    WHERE OrderID = order_id;
    
    -- Get the number of affected rows
    SET row_count = ROW_COUNT();
    
    -- Check if any row was deleted
    IF row_count > 0 THEN
        SELECT CONCAT('Order with OrderID ', order_id, ' has been canceled.') AS Message;
    ELSE
        SELECT CONCAT('Order with OrderID ', order_id, ' was not found.') AS Message;
    END IF;
END //

DELIMITER ;

-- Example calling CancelOrder on order_id = 1
Call CancelOrder(1);



-- alter table bookings add column BookingDate Date;
-- select * from bookings;

-- Added new entries
INSERT INTO Bookings (BookingID, GuestFirstName, GuestLastName, BookingDate, TableNo, BookingSlot)
VALUES 
    (19, 'John', 'Doe', '2024-06-14', 1, '18:00:00'),
    (20, 'Jane', 'Smith', '2024-06-14', 2, '19:00:00'),
    (21, 'Jim', 'Brown', '2024-06-15', 1, '20:00:00'),
    (22, 'Lisa', 'White', '2024-06-15', 3, '18:30:00');	
    


-- Create CheckBooking procedure
DELIMITER //

CREATE PROCEDURE CheckBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE booking_count INT;

    SELECT COUNT(*) INTO booking_count
    FROM Bookings
    WHERE BookingDate = booking_date AND TableNo = table_number;

    IF booking_count > 0 THEN
        SELECT 'Table is already booked' AS Status;
    ELSE
        SELECT 'Table is available' AS Status;
    END IF;
END //

DELIMITER ;

Call CheckBooking("2022-11-12", 3);

-- drop procedure AddValidBooking;
-- Create AddValid procedure
DELIMITER //

CREATE PROCEDURE AddValidBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE booking_count INT;

    START TRANSACTION;

    SELECT COUNT(*) INTO booking_count
    FROM Bookings
    WHERE BookingDate = booking_date AND TableNo = table_number;

    IF booking_count > 0 THEN
        ROLLBACK;
        SELECT 'Booking failed: Table is already booked' AS Status;
    ELSE
        INSERT INTO Bookings (BookingDate, TableNo, BookingSlot)
        VALUES (booking_date, table_number, current_time());
        COMMIT;
        SELECT 'Booking successful' AS Status;
    END IF;
END //

DELIMITER ;

call AddValidBooking("2022-12-17", 6);


-- drop procedure AddBooking;
-- Create AddBooking procedure
DELIMITER //

CREATE PROCEDURE AddBooking(
    IN p_booking_id INT,
    IN p_customer_id INT,
    IN p_table_number INT,
    IN p_booking_date DATE
    
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Could not add the booking' AS Message;
    END;

    START TRANSACTION;

    INSERT INTO Bookings (BookingID, BookingSlot, CustomersID, TableNo, BookingDate)
    VALUES (p_booking_id, current_time(), p_customer_id, p_table_number, p_booking_date);

    COMMIT;
    SELECT 'Booking successfully added' AS Message;
END //

DELIMITER ;

Call AddBooking(24, 3, 4, "2022-12-17");


-- Create UpdateBooking procedure
DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN p_booking_id INT,
    IN p_booking_date DATE
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Could not update the booking' AS Message;
    END;

    START TRANSACTION;

    UPDATE Bookings
    SET BookingDate = p_booking_date
    WHERE BookingID = p_booking_id;

    COMMIT;
    SELECT 'Booking successfully updated' AS Message;
END //

DELIMITER ;

Call UpdateBooking(9, "2022-12-17");


-- Create CancelBooking procedure
DELIMITER //

CREATE PROCEDURE CancelBooking(
    IN p_booking_id INT
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: Could not cancel the booking' AS Message;
    END;

    START TRANSACTION;

    DELETE FROM Bookings
    WHERE BookingID = p_booking_id;

    COMMIT;
    SELECT 'Booking successfully canceled' AS Message;
END //

DELIMITER ;

Call CancelBooking(9);
