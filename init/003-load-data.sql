-- =============================================================================
-- Load CSV data into OLTP tables
-- Rosy's SQL Practice Database
-- =============================================================================

-- Enable local infile loading
SET GLOBAL local_infile = 1;

-- Load base entities first (no foreign key dependencies)
LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/warehouses.csv'
INTO TABLE warehouses
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load entities with single foreign key dependency
LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/vehicles.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load transactional data
LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/shipments.csv'
INTO TABLE shipments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, vehicle_id, driver_id, warehouse_id, scheduled_departure, actual_departure,
 scheduled_arrival, @actual_arrival, destination_lat, destination_lng, status, shipping_cost)
SET actual_arrival = NULLIF(@actual_arrival, '');

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/shipment_conditions.csv'
INTO TABLE shipment_conditions
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/inventory_snapshots.csv'
INTO TABLE inventory_snapshots
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, customer_id, shipment_id, order_date, ship_date, @delivery_date, status, total_amount)
SET delivery_date = NULLIF(@delivery_date, '');

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Show counts to verify
SELECT 'Data loaded successfully!' as status;
SELECT 'warehouses' as table_name, COUNT(*) as row_count FROM warehouses
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'shipment_conditions', COUNT(*) FROM shipment_conditions
UNION ALL SELECT 'inventory_snapshots', COUNT(*) FROM inventory_snapshots
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
