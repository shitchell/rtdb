-- =============================================================================
-- OLAP Schema: Denormalized tables for reporting and analytics
-- Rosy's SQL Practice Database
-- =============================================================================
-- These tables demonstrate how normalized OLTP data gets transformed into
-- pre-aggregated reporting tables for faster queries.
-- =============================================================================

DROP TABLE IF EXISTS daily_delivery_metrics;
DROP TABLE IF EXISTS weekly_sales_summary;
DROP TABLE IF EXISTS monthly_inventory_report;

-- =============================================================================
-- Daily Delivery Metrics
-- Pre-aggregated delivery performance by warehouse and day
-- =============================================================================

CREATE TABLE daily_delivery_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATE NOT NULL,
    warehouse_id INT NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    total_shipments INT NOT NULL DEFAULT 0,
    on_time_count INT NOT NULL DEFAULT 0,
    late_count INT NOT NULL DEFAULT 0,
    cancelled_count INT NOT NULL DEFAULT 0,
    avg_delay_hours DECIMAL(6, 2),
    avg_shipping_cost DECIMAL(10, 2),
    high_risk_count INT NOT NULL DEFAULT 0,
    moderate_risk_count INT NOT NULL DEFAULT 0,
    low_risk_count INT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_date_warehouse (report_date, warehouse_id),
    INDEX idx_date (report_date),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_region (region)
) ENGINE=InnoDB;

-- =============================================================================
-- Weekly Sales Summary
-- Pre-aggregated sales metrics by product and week
-- =============================================================================

CREATE TABLE weekly_sales_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    product_id INT NOT NULL,
    sku VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    total_quantity_sold INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    avg_unit_price DECIMAL(10, 2),
    unique_customers INT NOT NULL DEFAULT 0,
    order_count INT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_week_product (week_start, product_id),
    INDEX idx_week (week_start),
    INDEX idx_product (product_id),
    INDEX idx_category (category)
) ENGINE=InnoDB;

-- =============================================================================
-- Monthly Inventory Report
-- Pre-aggregated inventory metrics by warehouse, product, and month
-- =============================================================================

CREATE TABLE monthly_inventory_report (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_month DATE NOT NULL,
    warehouse_id INT NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    sku VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    start_quantity INT,
    end_quantity INT,
    min_quantity INT,
    max_quantity INT,
    avg_quantity DECIMAL(10, 2),
    below_reorder_days INT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_month_warehouse_product (report_month, warehouse_id, product_id),
    INDEX idx_month (report_month),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB;
