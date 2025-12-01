-- =============================================================================
-- SQL Practice Quiz for Rosy
-- Amazon Data & Reporting Analyst Interview Prep
-- =============================================================================
--
-- Instructions:
-- 1. Try to solve each question on your own first
-- 2. The answers are provided below each question (scroll down!)
-- 3. Questions are organized by difficulty and topic
-- 4. Focus on understanding WHY the answer works, not just memorizing it
--
-- =============================================================================

-- #############################################################################
-- SECTION 1: BASIC QUERIES (Warm-up)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q1: List all warehouses and their regions, sorted by name
-- Skills: SELECT, ORDER BY
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT name, region FROM warehouses ORDER BY name;

-- -----------------------------------------------------------------------------
-- Q2: Find all products in the 'Electronics' category
-- Skills: SELECT, WHERE
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT sku, name, unit_cost FROM products WHERE category = 'Electronics';

-- -----------------------------------------------------------------------------
-- Q3: Count how many customers are in each segment
-- Skills: GROUP BY, COUNT
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT segment, COUNT(*) as customer_count
-- FROM customers
-- GROUP BY segment
-- ORDER BY customer_count DESC;

-- -----------------------------------------------------------------------------
-- Q4: Find the top 5 most expensive products
-- Skills: ORDER BY, LIMIT
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT sku, name, category, unit_cost
-- FROM products
-- ORDER BY unit_cost DESC
-- LIMIT 5;


-- #############################################################################
-- SECTION 2: JOINS (Essential for interviews!)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q5: List all products with their supplier names
-- Skills: INNER JOIN
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT p.sku, p.name, p.category, s.name as supplier_name, s.reliability_score
-- FROM products p
-- INNER JOIN suppliers s ON p.supplier_id = s.id;

-- -----------------------------------------------------------------------------
-- Q6: Find all drivers and their warehouse names
-- Skills: INNER JOIN
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT d.name as driver_name, d.behavior_score, w.name as warehouse_name, w.region
-- FROM drivers d
-- INNER JOIN warehouses w ON d.warehouse_id = w.id
-- ORDER BY w.name, d.name;

-- -----------------------------------------------------------------------------
-- Q7: List all orders with customer name and total amount
-- Only show orders over $500
-- Skills: INNER JOIN, WHERE
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT o.id as order_id, c.name as customer_name, c.segment,
--        o.order_date, o.total_amount
-- FROM orders o
-- INNER JOIN customers c ON o.customer_id = c.id
-- WHERE o.total_amount > 500
-- ORDER BY o.total_amount DESC;

-- -----------------------------------------------------------------------------
-- Q8: Show order details with product information
-- Include: order_id, product name, quantity, unit_price, line total
-- Skills: Multiple JOINs, Calculated columns
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT o.id as order_id, o.order_date, p.name as product_name, p.category,
--        oi.quantity, oi.unit_price, oi.discount,
--        ROUND(oi.quantity * oi.unit_price * (1 - oi.discount), 2) as line_total
-- FROM orders o
-- INNER JOIN order_items oi ON o.id = oi.order_id
-- INNER JOIN products p ON oi.product_id = p.id
-- LIMIT 100;


-- #############################################################################
-- SECTION 3: AGGREGATIONS (Very common in interviews!)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q9: Calculate total revenue by product category
-- Skills: JOIN, GROUP BY, SUM
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT p.category,
--        COUNT(DISTINCT o.id) as order_count,
--        SUM(oi.quantity) as total_units_sold,
--        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) as total_revenue
-- FROM order_items oi
-- INNER JOIN orders o ON oi.order_id = o.id
-- INNER JOIN products p ON oi.product_id = p.id
-- WHERE o.status != 'Cancelled'
-- GROUP BY p.category
-- ORDER BY total_revenue DESC;

-- -----------------------------------------------------------------------------
-- Q10: Find the average shipping cost by warehouse
-- Skills: JOIN, GROUP BY, AVG
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT w.name as warehouse_name, w.region,
--        COUNT(*) as total_shipments,
--        ROUND(AVG(s.shipping_cost), 2) as avg_shipping_cost,
--        ROUND(MIN(s.shipping_cost), 2) as min_cost,
--        ROUND(MAX(s.shipping_cost), 2) as max_cost
-- FROM shipments s
-- INNER JOIN warehouses w ON s.warehouse_id = w.id
-- GROUP BY w.id, w.name, w.region
-- ORDER BY avg_shipping_cost DESC;

-- -----------------------------------------------------------------------------
-- Q11: Count shipments by status for each warehouse
-- Skills: GROUP BY multiple columns, COUNT
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT w.name as warehouse_name, s.status, COUNT(*) as shipment_count
-- FROM shipments s
-- INNER JOIN warehouses w ON s.warehouse_id = w.id
-- GROUP BY w.name, s.status
-- ORDER BY w.name, shipment_count DESC;


-- #############################################################################
-- SECTION 4: TIME-SERIES QUERIES (Important for reporting roles!)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q12: Find total orders and revenue by month for 2024
-- Skills: DATE functions, GROUP BY
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     DATE_FORMAT(order_date, '%Y-%m') as month,
--     COUNT(*) as total_orders,
--     ROUND(SUM(total_amount), 2) as total_revenue,
--     ROUND(AVG(total_amount), 2) as avg_order_value
-- FROM orders
-- WHERE YEAR(order_date) = 2024 AND status != 'Cancelled'
-- GROUP BY DATE_FORMAT(order_date, '%Y-%m')
-- ORDER BY month;

-- -----------------------------------------------------------------------------
-- Q13: Compare this month vs last month shipments (using OLAP table)
-- Skills: Self-join for period comparison
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     curr.warehouse_name,
--     curr.report_date as current_date,
--     curr.total_shipments as current_shipments,
--     prev.total_shipments as previous_shipments,
--     curr.total_shipments - prev.total_shipments as change,
--     ROUND((curr.total_shipments - prev.total_shipments) * 100.0 / prev.total_shipments, 1) as pct_change
-- FROM daily_delivery_metrics curr
-- LEFT JOIN daily_delivery_metrics prev
--     ON curr.warehouse_id = prev.warehouse_id
--     AND prev.report_date = DATE_SUB(curr.report_date, INTERVAL 1 DAY)
-- WHERE curr.report_date = '2024-06-15'
-- ORDER BY pct_change DESC;

-- -----------------------------------------------------------------------------
-- Q14: Find the current inventory level for each product at each warehouse
-- (Most recent snapshot)
-- Skills: Subquery for "latest" record
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT w.name as warehouse_name, p.sku, p.name as product_name,
--        inv.quantity, inv.reorder_point, inv.recorded_at,
--        CASE WHEN inv.quantity < inv.reorder_point THEN 'REORDER NEEDED' ELSE 'OK' END as status
-- FROM inventory_snapshots inv
-- INNER JOIN warehouses w ON inv.warehouse_id = w.id
-- INNER JOIN products p ON inv.product_id = p.id
-- WHERE inv.recorded_at = (
--     SELECT MAX(i2.recorded_at)
--     FROM inventory_snapshots i2
--     WHERE i2.warehouse_id = inv.warehouse_id
--       AND i2.product_id = inv.product_id
-- )
-- ORDER BY w.name, p.name;

-- -----------------------------------------------------------------------------
-- Q15: Calculate week-over-week sales growth by category
-- Skills: Window functions or self-join
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     curr.week_start,
--     curr.category,
--     curr.total_revenue as current_week_revenue,
--     prev.total_revenue as previous_week_revenue,
--     ROUND(curr.total_revenue - COALESCE(prev.total_revenue, 0), 2) as revenue_change,
--     CASE
--         WHEN prev.total_revenue IS NULL OR prev.total_revenue = 0 THEN NULL
--         ELSE ROUND((curr.total_revenue - prev.total_revenue) * 100.0 / prev.total_revenue, 1)
--     END as pct_growth
-- FROM (
--     SELECT week_start, category, SUM(total_revenue) as total_revenue
--     FROM weekly_sales_summary
--     GROUP BY week_start, category
-- ) curr
-- LEFT JOIN (
--     SELECT week_start, category, SUM(total_revenue) as total_revenue
--     FROM weekly_sales_summary
--     GROUP BY week_start, category
-- ) prev ON curr.category = prev.category
--       AND prev.week_start = DATE_SUB(curr.week_start, INTERVAL 7 DAY)
-- WHERE curr.week_start >= '2024-01-01'
-- ORDER BY curr.week_start, curr.category;


-- #############################################################################
-- SECTION 5: SUBQUERIES (Common interview pattern!)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q16: Find warehouses with above-average on-time delivery rate
-- Skills: Subquery in WHERE
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT warehouse_name, region,
--        SUM(on_time_count) as total_on_time,
--        SUM(total_shipments) as total_shipments,
--        ROUND(SUM(on_time_count) * 100.0 / SUM(total_shipments), 1) as on_time_pct
-- FROM daily_delivery_metrics
-- GROUP BY warehouse_id, warehouse_name, region
-- HAVING SUM(on_time_count) * 100.0 / SUM(total_shipments) > (
--     SELECT SUM(on_time_count) * 100.0 / SUM(total_shipments)
--     FROM daily_delivery_metrics
-- )
-- ORDER BY on_time_pct DESC;

-- -----------------------------------------------------------------------------
-- Q17: Find customers who have spent more than the average customer
-- Skills: Subquery, HAVING
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT c.name as customer_name, c.segment, c.region,
--        COUNT(o.id) as order_count,
--        ROUND(SUM(o.total_amount), 2) as total_spent
-- FROM customers c
-- INNER JOIN orders o ON c.id = o.customer_id
-- WHERE o.status != 'Cancelled'
-- GROUP BY c.id, c.name, c.segment, c.region
-- HAVING SUM(o.total_amount) > (
--     SELECT AVG(customer_total) FROM (
--         SELECT SUM(total_amount) as customer_total
--         FROM orders
--         WHERE status != 'Cancelled'
--         GROUP BY customer_id
--     ) avg_calc
-- )
-- ORDER BY total_spent DESC;

-- -----------------------------------------------------------------------------
-- Q18: Find products that have never been ordered
-- Skills: LEFT JOIN with NULL check, or NOT EXISTS
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution (using LEFT JOIN):
-- SELECT p.sku, p.name, p.category
-- FROM products p
-- LEFT JOIN order_items oi ON p.id = oi.product_id
-- WHERE oi.id IS NULL;

-- Solution (using NOT EXISTS):
-- SELECT p.sku, p.name, p.category
-- FROM products p
-- WHERE NOT EXISTS (
--     SELECT 1 FROM order_items oi WHERE oi.product_id = p.id
-- );


-- #############################################################################
-- SECTION 6: CASE STATEMENTS (Very useful for reporting!)
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q19: Categorize shipments by delay severity
-- Skills: CASE WHEN
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     s.id as shipment_id,
--     w.name as warehouse_name,
--     s.status,
--     TIMESTAMPDIFF(HOUR, s.scheduled_arrival, s.actual_arrival) as delay_hours,
--     CASE
--         WHEN s.actual_arrival IS NULL THEN 'Not Delivered'
--         WHEN s.actual_arrival <= s.scheduled_arrival THEN 'On Time'
--         WHEN TIMESTAMPDIFF(HOUR, s.scheduled_arrival, s.actual_arrival) <= 2 THEN 'Minor Delay'
--         WHEN TIMESTAMPDIFF(HOUR, s.scheduled_arrival, s.actual_arrival) <= 8 THEN 'Moderate Delay'
--         ELSE 'Severe Delay'
--     END as delay_category
-- FROM shipments s
-- INNER JOIN warehouses w ON s.warehouse_id = w.id
-- LIMIT 100;

-- -----------------------------------------------------------------------------
-- Q20: Create a customer tier based on total spending
-- Skills: CASE WHEN with aggregation
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     c.name as customer_name,
--     c.segment,
--     COUNT(o.id) as order_count,
--     ROUND(SUM(o.total_amount), 2) as total_spent,
--     CASE
--         WHEN SUM(o.total_amount) >= 10000 THEN 'Platinum'
--         WHEN SUM(o.total_amount) >= 5000 THEN 'Gold'
--         WHEN SUM(o.total_amount) >= 1000 THEN 'Silver'
--         ELSE 'Bronze'
--     END as customer_tier
-- FROM customers c
-- INNER JOIN orders o ON c.id = o.customer_id
-- WHERE o.status != 'Cancelled'
-- GROUP BY c.id, c.name, c.segment
-- ORDER BY total_spent DESC;


-- #############################################################################
-- SECTION 7: AMAZON-STYLE INTERVIEW QUESTIONS
-- #############################################################################

-- -----------------------------------------------------------------------------
-- Q21: "Find the top 3 products by revenue in each category"
-- Skills: Ranking within groups (common Amazon question!)
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT category, sku, product_name, total_revenue, revenue_rank
-- FROM (
--     SELECT
--         p.category,
--         p.sku,
--         p.name as product_name,
--         ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) as total_revenue,
--         RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) DESC) as revenue_rank
--     FROM order_items oi
--     INNER JOIN orders o ON oi.order_id = o.id
--     INNER JOIN products p ON oi.product_id = p.id
--     WHERE o.status != 'Cancelled'
--     GROUP BY p.category, p.id, p.sku, p.name
-- ) ranked
-- WHERE revenue_rank <= 3
-- ORDER BY category, revenue_rank;

-- -----------------------------------------------------------------------------
-- Q22: "Calculate the 7-day moving average of daily shipments"
-- Skills: Window functions, moving averages
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     report_date,
--     total_shipments,
--     ROUND(AVG(total_shipments) OVER (
--         ORDER BY report_date
--         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
--     ), 1) as seven_day_avg
-- FROM (
--     SELECT report_date, SUM(total_shipments) as total_shipments
--     FROM daily_delivery_metrics
--     GROUP BY report_date
-- ) daily
-- ORDER BY report_date;

-- -----------------------------------------------------------------------------
-- Q23: "Find warehouses where on-time delivery has decreased month-over-month"
-- Skills: Period comparison, percentage calculations
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- WITH monthly_metrics AS (
--     SELECT
--         warehouse_id,
--         warehouse_name,
--         DATE_FORMAT(report_date, '%Y-%m') as month,
--         SUM(on_time_count) as on_time,
--         SUM(total_shipments) as total,
--         ROUND(SUM(on_time_count) * 100.0 / SUM(total_shipments), 1) as on_time_pct
--     FROM daily_delivery_metrics
--     GROUP BY warehouse_id, warehouse_name, DATE_FORMAT(report_date, '%Y-%m')
-- )
-- SELECT
--     curr.warehouse_name,
--     curr.month as current_month,
--     curr.on_time_pct as current_pct,
--     prev.on_time_pct as previous_pct,
--     ROUND(curr.on_time_pct - prev.on_time_pct, 1) as pct_change
-- FROM monthly_metrics curr
-- INNER JOIN monthly_metrics prev
--     ON curr.warehouse_id = prev.warehouse_id
--     AND prev.month = DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(curr.month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
-- WHERE curr.on_time_pct < prev.on_time_pct
-- ORDER BY pct_change;

-- -----------------------------------------------------------------------------
-- Q24: "Identify products that are frequently out of stock"
-- Skills: Aggregation, conditional counting
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT
--     p.sku,
--     p.name as product_name,
--     p.category,
--     COUNT(*) as total_snapshots,
--     SUM(CASE WHEN inv.quantity = 0 THEN 1 ELSE 0 END) as out_of_stock_count,
--     SUM(CASE WHEN inv.quantity < inv.reorder_point THEN 1 ELSE 0 END) as below_reorder_count,
--     ROUND(SUM(CASE WHEN inv.quantity = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as out_of_stock_pct
-- FROM inventory_snapshots inv
-- INNER JOIN products p ON inv.product_id = p.id
-- GROUP BY p.id, p.sku, p.name, p.category
-- HAVING SUM(CASE WHEN inv.quantity = 0 THEN 1 ELSE 0 END) > 0
-- ORDER BY out_of_stock_pct DESC;

-- -----------------------------------------------------------------------------
-- Q25: "Find the busiest delivery day of the week for each warehouse"
-- Skills: Day of week analysis, ranking
-- -----------------------------------------------------------------------------
-- Your answer:


-- Solution:
-- SELECT warehouse_name, day_name, total_shipments, day_rank
-- FROM (
--     SELECT
--         w.name as warehouse_name,
--         DAYNAME(s.scheduled_departure) as day_name,
--         COUNT(*) as total_shipments,
--         RANK() OVER (PARTITION BY w.id ORDER BY COUNT(*) DESC) as day_rank
--     FROM shipments s
--     INNER JOIN warehouses w ON s.warehouse_id = w.id
--     GROUP BY w.id, w.name, DAYNAME(s.scheduled_departure)
-- ) ranked
-- WHERE day_rank = 1
-- ORDER BY warehouse_name;


-- #############################################################################
-- BONUS: COMPARING OLTP vs OLAP QUERIES
-- #############################################################################

-- -----------------------------------------------------------------------------
-- BONUS Q1: Get monthly revenue by category
-- Compare the complexity of querying OLTP vs OLAP tables!
-- -----------------------------------------------------------------------------

-- OLTP approach (joins multiple tables, more complex):
-- SELECT
--     DATE_FORMAT(o.order_date, '%Y-%m') as month,
--     p.category,
--     ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) as revenue
-- FROM orders o
-- INNER JOIN order_items oi ON o.id = oi.order_id
-- INNER JOIN products p ON oi.product_id = p.id
-- WHERE o.status != 'Cancelled'
-- GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category
-- ORDER BY month, category;

-- OLAP approach (pre-aggregated, simpler and faster):
-- SELECT
--     DATE_FORMAT(week_start, '%Y-%m') as month,
--     category,
--     ROUND(SUM(total_revenue), 2) as revenue
-- FROM weekly_sales_summary
-- GROUP BY DATE_FORMAT(week_start, '%Y-%m'), category
-- ORDER BY month, category;

-- =============================================================================
-- Good luck with your interview, Rosy! You've got this!
-- =============================================================================
