-- ============================================================================
-- Script de Inicialización de MySQL para Microservicios
-- ============================================================================

-- Crear bases de datos adicionales
CREATE DATABASE IF NOT EXISTS inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS shipping_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS analytics_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crear usuario de desarrollo
CREATE USER IF NOT EXISTS 'dev_user'@'%' IDENTIFIED BY 'dev_pass';
GRANT ALL PRIVILEGES ON *.* TO 'dev_user'@'%';
FLUSH PRIVILEGES;

-- ============================================================================
-- Base de datos: INVENTORY
-- ============================================================================
USE inventory_db;

-- Tabla de almacenes
CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de inventario
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id CHAR(36) NOT NULL,
    sku VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    reserved_quantity INT NOT NULL DEFAULT 0,
    available_quantity INT GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    reorder_point INT DEFAULT 10,
    reorder_quantity INT DEFAULT 50,
    last_restocked_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY unique_warehouse_product (warehouse_id, product_id),
    INDEX idx_product (product_id),
    INDEX idx_sku (sku),
    CHECK (quantity >= 0),
    CHECK (reserved_quantity >= 0)
) ENGINE=InnoDB;

-- Tabla de movimientos de inventario
CREATE TABLE inventory_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    movement_type ENUM('in', 'out', 'adjustment', 'transfer', 'reserved', 'released') NOT NULL,
    quantity INT NOT NULL,
    reference_type VARCHAR(50),
    reference_id VARCHAR(100),
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id),
    INDEX idx_inventory (inventory_id),
    INDEX idx_created_at (created_at),
    INDEX idx_reference (reference_type, reference_id)
) ENGINE=InnoDB;

-- Insertar datos de ejemplo
INSERT INTO warehouses (code, name, address, city, country) VALUES
    ('WH-001', 'Almacén Central Madrid', 'Calle Principal 123', 'Madrid', 'España'),
    ('WH-002', 'Almacén Barcelona', 'Av. Diagonal 456', 'Barcelona', 'España');

INSERT INTO inventory (warehouse_id, product_id, sku, quantity) VALUES
    (1, UUID(), 'PROD-001', 100),
    (1, UUID(), 'PROD-002', 250),
    (2, UUID(), 'PROD-001', 75);

-- ============================================================================
-- Base de datos: SHIPPING
-- ============================================================================
USE shipping_db;

-- Tabla de métodos de envío
CREATE TABLE shipping_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    carrier VARCHAR(100),
    estimated_days_min INT,
    estimated_days_max INT,
    base_cost DECIMAL(10, 2) NOT NULL,
    cost_per_kg DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de envíos
CREATE TABLE shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_number VARCHAR(100) UNIQUE NOT NULL,
    order_id CHAR(36) NOT NULL,
    shipping_method_id INT NOT NULL,
    carrier VARCHAR(100),
    status ENUM('pending', 'in_transit', 'out_for_delivery', 'delivered', 'failed', 'returned') DEFAULT 'pending',
    origin_address JSON NOT NULL,
    destination_address JSON NOT NULL,
    package_weight DECIMAL(10, 2),
    package_dimensions JSON,
    shipping_cost DECIMAL(10, 2) NOT NULL,
    estimated_delivery_date DATE,
    actual_delivery_date DATETIME NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id),
    INDEX idx_order (order_id),
    INDEX idx_tracking (tracking_number),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- Tabla de eventos de seguimiento
CREATE TABLE shipment_tracking_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    status ENUM('picked_up', 'in_transit', 'customs', 'out_for_delivery', 'delivered', 'exception') NOT NULL,
    location VARCHAR(255),
    description TEXT,
    occurred_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
    INDEX idx_shipment (shipment_id),
    INDEX idx_occurred (occurred_at)
) ENGINE=InnoDB;

-- Insertar métodos de envío de ejemplo
INSERT INTO shipping_methods (code, name, carrier, estimated_days_min, estimated_days_max, base_cost, cost_per_kg) VALUES
    ('STD', 'Envío Estándar', 'Correos', 3, 5, 5.99, 0.50),
    ('EXP', 'Envío Express', 'DHL', 1, 2, 15.99, 1.00),
    ('INTL', 'Envío Internacional', 'FedEx', 7, 14, 25.99, 2.00);

-- ============================================================================
-- Base de datos: ANALYTICS
-- ============================================================================
USE analytics_db;

-- Tabla de eventos de usuario
CREATE TABLE user_events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36),
    session_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL,
    event_category VARCHAR(50),
    event_action VARCHAR(100),
    event_label VARCHAR(255),
    event_value DECIMAL(10, 2),
    page_url TEXT,
    referrer_url TEXT,
    user_agent TEXT,
    ip_address VARCHAR(45),
    country VARCHAR(100),
    city VARCHAR(100),
    device_type ENUM('desktop', 'mobile', 'tablet', 'other'),
    browser VARCHAR(50),
    os VARCHAR(50),
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at),
    INDEX idx_session (session_id)
) ENGINE=InnoDB;

-- Tabla de métricas diarias agregadas
CREATE TABLE daily_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metric_date DATE NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_category VARCHAR(50),
    metric_value DECIMAL(15, 2) NOT NULL,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_daily_metric (metric_date, metric_name, metric_category),
    INDEX idx_date (metric_date),
    INDEX idx_name (metric_name)
) ENGINE=InnoDB;

-- Tabla de conversiones
CREATE TABLE conversions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36),
    session_id VARCHAR(100),
    conversion_type ENUM('purchase', 'signup', 'subscription', 'lead', 'custom') NOT NULL,
    conversion_value DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    order_id CHAR(36),
    product_id CHAR(36),
    campaign_source VARCHAR(100),
    campaign_medium VARCHAR(100),
    campaign_name VARCHAR(100),
    metadata JSON,
    converted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_type (conversion_type),
    INDEX idx_converted_at (converted_at),
    INDEX idx_campaign (campaign_source, campaign_medium)
) ENGINE=InnoDB;

-- Vista para métricas de ventas diarias
CREATE VIEW daily_sales_metrics AS
SELECT 
    DATE(converted_at) as sale_date,
    COUNT(*) as total_orders,
    COUNT(DISTINCT user_id) as unique_customers,
    SUM(conversion_value) as total_revenue,
    AVG(conversion_value) as average_order_value
FROM conversions
WHERE conversion_type = 'purchase'
GROUP BY DATE(converted_at);

-- Procedimiento almacenado para registrar evento
DELIMITER //
CREATE PROCEDURE log_user_event(
    IN p_user_id CHAR(36),
    IN p_event_type VARCHAR(50),
    IN p_event_category VARCHAR(50),
    IN p_event_action VARCHAR(100),
    IN p_metadata JSON
)
BEGIN
    INSERT INTO user_events (user_id, event_type, event_category, event_action, metadata)
    VALUES (p_user_id, p_event_type, p_event_category, p_event_action, p_metadata);
END //
DELIMITER ;

-- Insertar datos de ejemplo
INSERT INTO user_events (user_id, event_type, event_category, event_action, device_type, browser) VALUES
    (UUID(), 'page_view', 'navigation', 'home_page_visit', 'desktop', 'Chrome'),
    (UUID(), 'button_click', 'interaction', 'add_to_cart', 'mobile', 'Safari'),
    (UUID(), 'page_view', 'navigation', 'product_view', 'desktop', 'Firefox');

INSERT INTO conversions (user_id, conversion_type, conversion_value, currency, campaign_source) VALUES
    (UUID(), 'purchase', 149.99, 'EUR', 'google'),
    (UUID(), 'purchase', 89.99, 'EUR', 'facebook'),
    (UUID(), 'signup', 0.00, 'EUR', 'organic');

-- ============================================================================
-- TRIGGERS Y FUNCIONES ÚTILES
-- ============================================================================

-- Trigger para actualizar cantidad disponible en inventario
USE inventory_db;
DELIMITER //
CREATE TRIGGER after_inventory_movement_insert
AFTER INSERT ON inventory_movements
FOR EACH ROW
BEGIN
    IF NEW.movement_type = 'in' THEN
        UPDATE inventory 
        SET quantity = quantity + NEW.quantity
        WHERE id = NEW.inventory_id;
    ELSEIF NEW.movement_type = 'out' THEN
        UPDATE inventory 
        SET quantity = quantity - NEW.quantity
        WHERE id = NEW.inventory_id;
    ELSEIF NEW.movement_type = 'reserved' THEN
        UPDATE inventory 
        SET reserved_quantity = reserved_quantity + NEW.quantity
        WHERE id = NEW.inventory_id;
    ELSEIF NEW.movement_type = 'released' THEN
        UPDATE inventory 
        SET reserved_quantity = reserved_quantity - NEW.quantity
        WHERE id = NEW.inventory_id;
    END IF;
END //
DELIMITER ;

-- Trigger para actualizar estado de envío
USE shipping_db;
DELIMITER //
CREATE TRIGGER after_tracking_event_insert
AFTER INSERT ON shipment_tracking_events
FOR EACH ROW
BEGIN
    UPDATE shipments
    SET status = CASE NEW.status
        WHEN 'picked_up' THEN 'in_transit'
        WHEN 'in_transit' THEN 'in_transit'
        WHEN 'out_for_delivery' THEN 'out_for_delivery'
        WHEN 'delivered' THEN 'delivered'
        ELSE status
    END,
    actual_delivery_date = CASE 
        WHEN NEW.status = 'delivered' THEN NEW.occurred_at
        ELSE actual_delivery_date
    END
    WHERE id = NEW.shipment_id;
END //
DELIMITER ;

-- ============================================================================
-- ÍNDICES ADICIONALES PARA PERFORMANCE
-- ============================================================================

USE inventory_db;
CREATE INDEX idx_inventory_low_stock ON inventory(warehouse_id, available_quantity, reorder_point);
CREATE INDEX idx_movements_created ON inventory_movements(created_at DESC);

USE shipping_db;
CREATE INDEX idx_shipments_delivery_date ON shipments(estimated_delivery_date);
CREATE INDEX idx_shipments_created ON shipments(created_at DESC);

USE analytics_db;
CREATE INDEX idx_events_user_date ON user_events(user_id, created_at);
CREATE INDEX idx_conversions_date ON conversions(converted_at DESC);

-- ============================================================================
-- FIN DEL SCRIPT DE INICIALIZACIÓN
-- ============================================================================