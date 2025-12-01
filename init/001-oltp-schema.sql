-- =============================================================================
-- OLTP Schema: Normalized tables for transactional data
-- Rosy's SQL Practice Database
-- =============================================================================

-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventory_snapshots;
DROP TABLE IF EXISTS shipment_conditions;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS warehouses;

-- =============================================================================
-- Base Entity Tables
-- =============================================================================

CREATE TABLE warehouses (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 6) NOT NULL,
    longitude DECIMAL(10, 6) NOT NULL,
    capacity INT NOT NULL,
    INDEX idx_region (region)
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    reliability_score DECIMAL(3, 2) NOT NULL,
    lead_time_days INT NOT NULL,
    INDEX idx_reliability (reliability_score)
) ENGINE=InnoDB;

CREATE TABLE products (
    id INT PRIMARY KEY,
    sku VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    supplier_id INT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    INDEX idx_category (category),
    INDEX idx_sku (sku)
) ENGINE=InnoDB;

CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    segment VARCHAR(50) NOT NULL,
    INDEX idx_region (region),
    INDEX idx_segment (segment)
) ENGINE=InnoDB;

CREATE TABLE drivers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    warehouse_id INT NOT NULL,
    behavior_score DECIMAL(3, 2) NOT NULL,
    fatigue_score DECIMAL(3, 2) NOT NULL,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_behavior (behavior_score)
) ENGINE=InnoDB;

CREATE TABLE vehicles (
    id INT PRIMARY KEY,
    vehicle_type VARCHAR(50) NOT NULL,
    warehouse_id INT NOT NULL,
    capacity_kg INT NOT NULL,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_type (vehicle_type)
) ENGINE=InnoDB;

-- =============================================================================
-- Transactional Tables
-- =============================================================================

CREATE TABLE shipments (
    id INT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    scheduled_departure DATETIME NOT NULL,
    actual_departure DATETIME NOT NULL,
    scheduled_arrival DATETIME NOT NULL,
    actual_arrival DATETIME,
    destination_lat DECIMAL(10, 6) NOT NULL,
    destination_lng DECIMAL(10, 6) NOT NULL,
    status VARCHAR(20) NOT NULL,
    shipping_cost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    INDEX idx_status (status),
    INDEX idx_scheduled_dep (scheduled_departure),
    INDEX idx_warehouse (warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE shipment_conditions (
    id INT PRIMARY KEY,
    shipment_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    gps_latitude DECIMAL(10, 6) NOT NULL,
    gps_longitude DECIMAL(10, 6) NOT NULL,
    traffic_congestion_level DECIMAL(4, 2) NOT NULL,
    weather_severity DECIMAL(3, 2) NOT NULL,
    iot_temperature DECIMAL(5, 2) NOT NULL,
    cargo_condition VARCHAR(20) NOT NULL,
    route_risk_level VARCHAR(20) NOT NULL,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id),
    INDEX idx_shipment (shipment_id),
    INDEX idx_recorded (recorded_at),
    INDEX idx_risk (route_risk_level)
) ENGINE=InnoDB;

CREATE TABLE inventory_snapshots (
    id INT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    recorded_at DATE NOT NULL,
    quantity INT NOT NULL,
    reorder_point INT NOT NULL,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_warehouse_product (warehouse_id, product_id),
    INDEX idx_recorded (recorded_at)
) ENGINE=InnoDB;

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    shipment_id INT NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    delivery_date DATE,
    status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (shipment_id) REFERENCES shipments(id),
    INDEX idx_customer (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(3, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB;
