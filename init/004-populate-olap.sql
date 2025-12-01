-- =============================================================================
-- Populate OLAP tables from OLTP data
-- Rosy's SQL Practice Database
-- =============================================================================
-- This demonstrates how denormalized reporting tables are built from
-- normalized transactional data - a common ETL pattern.
-- =============================================================================

-- =============================================================================
-- Populate daily_delivery_metrics
-- =============================================================================

INSERT INTO daily_delivery_metrics (
    report_date, warehouse_id, warehouse_name, region,
    total_shipments, on_time_count, late_count, cancelled_count,
    avg_delay_hours, avg_shipping_cost,
    high_risk_count, moderate_risk_count, low_risk_count
)
SELECT
    DATE(s.scheduled_departure) as report_date,
    w.id as warehouse_id,
    w.name as warehouse_name,
    w.region,
    COUNT(*) as total_shipments,
    SUM(CASE
        WHEN s.actual_arrival IS NOT NULL
         AND s.actual_arrival <= s.scheduled_arrival
        THEN 1 ELSE 0
    END) as on_time_count,
    SUM(CASE
        WHEN s.actual_arrival IS NOT NULL
         AND s.actual_arrival > s.scheduled_arrival
        THEN 1 ELSE 0
    END) as late_count,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_count,
    AVG(CASE
        WHEN s.actual_arrival IS NOT NULL
        THEN TIMESTAMPDIFF(MINUTE, s.scheduled_arrival, s.actual_arrival) / 60.0
        ELSE NULL
    END) as avg_delay_hours,
    AVG(s.shipping_cost) as avg_shipping_cost,
    -- Risk counts from latest condition per shipment
    SUM(CASE WHEN latest_risk.route_risk_level = 'High' THEN 1 ELSE 0 END) as high_risk_count,
    SUM(CASE WHEN latest_risk.route_risk_level = 'Moderate' THEN 1 ELSE 0 END) as moderate_risk_count,
    SUM(CASE WHEN latest_risk.route_risk_level = 'Low' THEN 1 ELSE 0 END) as low_risk_count
FROM shipments s
JOIN warehouses w ON s.warehouse_id = w.id
LEFT JOIN (
    SELECT sc.shipment_id, sc.route_risk_level
    FROM shipment_conditions sc
    INNER JOIN (
        SELECT shipment_id, MAX(recorded_at) as max_time
        FROM shipment_conditions
        GROUP BY shipment_id
    ) latest ON sc.shipment_id = latest.shipment_id AND sc.recorded_at = latest.max_time
) latest_risk ON s.id = latest_risk.shipment_id
GROUP BY DATE(s.scheduled_departure), w.id, w.name, w.region;

-- =============================================================================
-- Populate weekly_sales_summary
-- =============================================================================

INSERT INTO weekly_sales_summary (
    week_start, week_end, product_id, sku, product_name, category,
    total_quantity_sold, total_revenue, total_discount_amount,
    avg_unit_price, unique_customers, order_count
)
SELECT
    DATE_SUB(o.order_date, INTERVAL WEEKDAY(o.order_date) DAY) as week_start,
    DATE_ADD(DATE_SUB(o.order_date, INTERVAL WEEKDAY(o.order_date) DAY), INTERVAL 6 DAY) as week_end,
    p.id as product_id,
    p.sku,
    p.name as product_name,
    p.category,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) as total_revenue,
    SUM(oi.quantity * oi.unit_price * oi.discount) as total_discount_amount,
    AVG(oi.unit_price) as avg_unit_price,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(DISTINCT o.id) as order_count
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.status != 'Cancelled'
GROUP BY
    DATE_SUB(o.order_date, INTERVAL WEEKDAY(o.order_date) DAY),
    p.id, p.sku, p.name, p.category;

-- =============================================================================
-- Populate monthly_inventory_report
-- =============================================================================

INSERT INTO monthly_inventory_report (
    report_month, warehouse_id, warehouse_name, product_id, sku, product_name, category,
    start_quantity, end_quantity, min_quantity, max_quantity, avg_quantity, below_reorder_days
)
SELECT
    DATE_FORMAT(inv.recorded_at, '%Y-%m-01') as report_month,
    w.id as warehouse_id,
    w.name as warehouse_name,
    p.id as product_id,
    p.sku,
    p.name as product_name,
    p.category,
    -- Start quantity (first record of month)
    (SELECT i2.quantity FROM inventory_snapshots i2
     WHERE i2.warehouse_id = inv.warehouse_id
       AND i2.product_id = inv.product_id
       AND DATE_FORMAT(i2.recorded_at, '%Y-%m') = DATE_FORMAT(inv.recorded_at, '%Y-%m')
     ORDER BY i2.recorded_at ASC LIMIT 1) as start_quantity,
    -- End quantity (last record of month)
    (SELECT i2.quantity FROM inventory_snapshots i2
     WHERE i2.warehouse_id = inv.warehouse_id
       AND i2.product_id = inv.product_id
       AND DATE_FORMAT(i2.recorded_at, '%Y-%m') = DATE_FORMAT(inv.recorded_at, '%Y-%m')
     ORDER BY i2.recorded_at DESC LIMIT 1) as end_quantity,
    MIN(inv.quantity) as min_quantity,
    MAX(inv.quantity) as max_quantity,
    AVG(inv.quantity) as avg_quantity,
    SUM(CASE WHEN inv.quantity < inv.reorder_point THEN 1 ELSE 0 END) as below_reorder_days
FROM inventory_snapshots inv
JOIN warehouses w ON inv.warehouse_id = w.id
JOIN products p ON inv.product_id = p.id
GROUP BY
    DATE_FORMAT(inv.recorded_at, '%Y-%m-01'),
    w.id, w.name,
    p.id, p.sku, p.name, p.category;

-- Show OLAP table counts
SELECT 'OLAP tables populated!' as status;
SELECT 'daily_delivery_metrics' as table_name, COUNT(*) as row_count FROM daily_delivery_metrics
UNION ALL SELECT 'weekly_sales_summary', COUNT(*) FROM weekly_sales_summary
UNION ALL SELECT 'monthly_inventory_report', COUNT(*) FROM monthly_inventory_report;
