-- E-Commerce Database Management System
-- Created by: Database System
-- Date: 2024

-- Create the database
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Table: customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- Table: addresses
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('billing', 'shipping') NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_address (customer_id, address_type)
);

-- Table: categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_category_parent (parent_category_id)
);

-- Table: products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    cost_price DECIMAL(10, 2) NOT NULL CHECK (cost_price >= 0),
    sku VARCHAR(100) UNIQUE NOT NULL,
    weight_kg DECIMAL(8, 3) CHECK (weight_kg >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    min_stock_level INT DEFAULT 5 CHECK (min_stock_level >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_product_category (category_id),
    INDEX idx_product_sku (sku),
    INDEX idx_product_price (price)
);

-- Table: product_images
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_primary_image (product_id, is_primary),
    INDEX idx_product_images (product_id)
);

-- Table: orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12, 2) NOT NULL CHECK (total_amount >= 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(10, 2) DEFAULT 0 CHECK (shipping_amount >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    final_amount DECIMAL(12, 2) NOT NULL CHECK (final_amount >= 0),
    shipping_address_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    notes TEXT,
    estimated_delivery_date DATE,
    actual_delivery_date TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_status (order_status),
    INDEX idx_order_date (order_date)
);

-- Table: order_items
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    discount_percentage DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percentage BETWEEN 0 AND 100),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_order_product (order_id, product_id),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id)
);

-- Table: payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash_on_delivery') NOT NULL,
    payment_status ENUM('pending', 'processing', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    transaction_id VARCHAR(255) UNIQUE,
    payment_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refund_amount DECIMAL(10, 2) DEFAULT 0 CHECK (refund_amount >= 0),
    refund_date TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_payment_order (order_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_date (payment_date)
);

-- Table: reviews
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_customer_review (product_id, customer_id),
    INDEX idx_review_product (product_id),
    INDEX idx_review_customer (customer_id),
    INDEX idx_review_rating (rating)
);

-- Table: wishlist
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product_wishlist (customer_id, product_id),
    INDEX idx_wishlist_customer (customer_id),
    INDEX idx_wishlist_product (product_id)
);

-- Table: coupons
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value >= 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0 CHECK (min_order_amount >= 0),
    max_discount_amount DECIMAL(10, 2) CHECK (max_discount_amount >= 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    usage_limit INT DEFAULT NULL CHECK (usage_limit IS NULL OR usage_limit > 0),
    used_count INT DEFAULT 0 CHECK (used_count >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date >= start_date),
    INDEX idx_coupon_code (coupon_code),
    INDEX idx_coupon_dates (start_date, end_date)
);

-- Table: order_coupons (Many-to-Many relationship between orders and coupons)
CREATE TABLE order_coupons (
    order_id INT NOT NULL,
    coupon_id INT NOT NULL,
    discount_applied DECIMAL(10, 2) NOT NULL CHECK (discount_applied >= 0),
    PRIMARY KEY (order_id, coupon_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE RESTRICT
);

-- Table: inventory_log
CREATE TABLE inventory_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    change_type ENUM('stock_in', 'stock_out', 'adjustment', 'return') NOT NULL,
    quantity_change INT NOT NULL,
    new_stock_level INT NOT NULL,
    reason VARCHAR(255),
    reference_id INT NULL, -- Can reference order_id or other relevant IDs
    reference_type ENUM('order', 'adjustment', 'return') NULL,
    changed_by VARCHAR(100) DEFAULT 'system',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_inventory_product (product_id),
    INDEX idx_inventory_date (changed_at)
);

-- Table: shipping_methods
CREATE TABLE shipping_methods (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL,
    description TEXT,
    base_cost DECIMAL(8, 2) NOT NULL CHECK (base_cost >= 0),
    cost_per_kg DECIMAL(8, 2) DEFAULT 0 CHECK (cost_per_kg >= 0),
    estimated_days_min INT NOT NULL CHECK (estimated_days_min >= 0),
    estimated_days_max INT NOT NULL CHECK (estimated_days_max >= estimated_days_min),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: order_shipments
CREATE TABLE order_shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    shipping_method_id INT NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    shipment_date TIMESTAMP NULL,
    estimated_delivery_date DATE,
    actual_delivery_date TIMESTAMP NULL,
    shipment_status ENUM('preparing', 'shipped', 'in_transit', 'out_for_delivery', 'delivered') DEFAULT 'preparing',
    shipping_cost DECIMAL(8, 2) NOT NULL CHECK (shipping_cost >= 0),
    carrier_name VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(method_id) ON DELETE RESTRICT,
    INDEX idx_shipment_order (order_id),
    INDEX idx_shipment_tracking (tracking_number),
    INDEX idx_shipment_status (shipment_status)
);

-- Insert sample data for categories
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Electronics', 'Electronic devices and accessories', NULL),
('Computers & Tablets', 'Computers, laptops, and tablets', 1),
('Smartphones', 'Mobile phones and smartphones', 1),
('Home Appliances', 'Home and kitchen appliances', NULL),
('Kitchen', 'Kitchen appliances and tools', 4),
('Furniture', 'Home and office furniture', NULL);

-- Insert sample shipping methods
INSERT INTO shipping_methods (method_name, description, base_cost, cost_per_kg, estimated_days_min, estimated_days_max) VALUES
('Standard Shipping', 'Regular ground shipping', 5.99, 1.50, 3, 7),
('Express Shipping', 'Faster delivery service', 12.99, 2.50, 1, 3),
('Overnight Shipping', 'Next day delivery', 24.99, 4.00, 1, 1);

-- Create indexes for better performance
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_orders_total_amount ON orders(total_amount);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_inventory_log_reference ON inventory_log(reference_id, reference_type);

-- Add comments to tables
ALTER TABLE customers COMMENT = 'Stores customer information and authentication details';
ALTER TABLE products COMMENT = 'Contains product information including pricing and inventory';
ALTER TABLE orders COMMENT = 'Main order information and status tracking';
ALTER TABLE order_items COMMENT = 'Individual items within each order';
ALTER TABLE payments COMMENT = 'Payment transaction records and status';
ALTER TABLE reviews COMMENT = 'Customer product reviews and ratings';

-- Create a view for product catalog
CREATE VIEW product_catalog AS
SELECT 
    p.product_id,
    p.product_name,
    p.description,
    c.category_name,
    p.price,
    p.stock_quantity,
    pi.image_url as primary_image,
    AVG(r.rating) as average_rating,
    COUNT(r.review_id) as review_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_primary = TRUE
LEFT JOIN reviews r ON p.product_id = r.product_id AND r.is_approved = TRUE
WHERE p.is_active = TRUE
GROUP BY p.product_id;

-- Create a view for order summary
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    c.email,
    o.order_status,
    o.total_amount,
    o.final_amount,
    p.payment_status,
    s.shipment_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN order_shipments s ON o.order_id = s.order_id;

-- Create stored procedure for placing an order
DELIMITER //
CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_shipping_address_id INT,
    IN p_billing_address_id INT,
    IN p_shipping_method_id INT,
    IN p_coupon_id INT DEFAULT NULL
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_total_amount DECIMAL(12,2);
    DECLARE v_final_amount DECIMAL(12,2);
    DECLARE v_discount_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_shipping_cost DECIMAL(8,2);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Calculate order totals from cart items (cart implementation would be separate)
    -- For simplicity, we assume cart items are stored temporarily
    
    -- Create order
    INSERT INTO orders (customer_id, shipping_address_id, billing_address_id, total_amount, final_amount)
    VALUES (p_customer_id, p_shipping_address_id, p_billing_address_id, v_total_amount, v_final_amount);
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- Apply coupon if provided
    IF p_coupon_id IS NOT NULL THEN
        -- Validate and apply coupon logic here
        INSERT INTO order_coupons (order_id, coupon_id, discount_applied)
        VALUES (v_order_id, p_coupon_id, v_discount_amount);
    END IF;
    
    -- Create shipment
    INSERT INTO order_shipments (order_id, shipping_method_id, shipping_cost)
    VALUES (v_order_id, p_shipping_method_id, v_shipping_cost);
    
    -- Update inventory
    -- This would loop through order items and update stock
    
    COMMIT;
END //
DELIMITER ;

-- Create trigger for inventory management
DELIMITER //
CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    -- Update product stock
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id;
    
    -- Log inventory change
    INSERT INTO inventory_log (product_id, change_type, quantity_change, new_stock_level, reason, reference_id, reference_type)
    SELECT 
        NEW.product_id,
        'stock_out',
        -NEW.quantity,
        stock_quantity - NEW.quantity,
        'Order placement',
        NEW.order_id,
        'order'
    FROM products 
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Create trigger for order status updates
DELIMITER //
CREATE TRIGGER after_order_status_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'cancelled' AND OLD.order_status != 'cancelled' THEN
        -- Restore inventory for cancelled orders
        UPDATE products p
        JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_quantity = p.stock_quantity + oi.quantity,
            p.updated_at = CURRENT_TIMESTAMP
        WHERE oi.order_id = NEW.order_id;
        
        -- Log inventory restoration
        INSERT INTO inventory_log (product_id, change_type, quantity_change, new_stock_level, reason, reference_id, reference_type)
        SELECT 
            oi.product_id,
            'stock_in',
            oi.quantity,
            p.stock_quantity + oi.quantity,
            'Order cancellation',
            NEW.order_id,
            'order'
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        WHERE oi.order_id = NEW.order_id;
    END IF;
END //
DELIMITER ;