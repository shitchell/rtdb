-- Sample data for SQL practice
-- This file runs automatically when the database is first created

-- Create a simple employees table
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a departments table
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    budget DECIMAL(12, 2),
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a projects table
CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT,
    start_date DATE,
    end_date DATE,
    status ENUM('planning', 'active', 'completed', 'on_hold') DEFAULT 'planning',
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Insert sample departments
INSERT INTO departments (name, budget) VALUES
    ('Engineering', 500000.00),
    ('Marketing', 200000.00),
    ('Sales', 300000.00),
    ('HR', 150000.00),
    ('Finance', 250000.00);

-- Insert sample employees
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date) VALUES
    ('Alice', 'Johnson', 'alice.johnson@example.com', 'Engineering', 85000.00, '2022-03-15'),
    ('Bob', 'Smith', 'bob.smith@example.com', 'Engineering', 92000.00, '2021-07-01'),
    ('Carol', 'Williams', 'carol.williams@example.com', 'Marketing', 72000.00, '2023-01-10'),
    ('David', 'Brown', 'david.brown@example.com', 'Sales', 65000.00, '2022-09-20'),
    ('Eve', 'Davis', 'eve.davis@example.com', 'HR', 58000.00, '2023-05-05'),
    ('Frank', 'Miller', 'frank.miller@example.com', 'Finance', 78000.00, '2021-11-30'),
    ('Grace', 'Wilson', 'grace.wilson@example.com', 'Engineering', 95000.00, '2020-06-15'),
    ('Henry', 'Moore', 'henry.moore@example.com', 'Marketing', 68000.00, '2022-12-01'),
    ('Ivy', 'Taylor', 'ivy.taylor@example.com', 'Sales', 71000.00, '2023-03-22'),
    ('Jack', 'Anderson', 'jack.anderson@example.com', 'Engineering', 88000.00, '2021-04-18');

-- Update department managers
UPDATE departments SET manager_id = 7 WHERE name = 'Engineering';
UPDATE departments SET manager_id = 3 WHERE name = 'Marketing';
UPDATE departments SET manager_id = 4 WHERE name = 'Sales';
UPDATE departments SET manager_id = 5 WHERE name = 'HR';
UPDATE departments SET manager_id = 6 WHERE name = 'Finance';

-- Insert sample projects
INSERT INTO projects (name, department_id, start_date, end_date, status) VALUES
    ('Website Redesign', 1, '2024-01-15', '2024-06-30', 'active'),
    ('Q2 Marketing Campaign', 2, '2024-04-01', '2024-06-30', 'active'),
    ('Sales Training Program', 3, '2024-02-01', '2024-03-31', 'completed'),
    ('HR System Upgrade', 4, '2024-03-01', NULL, 'planning'),
    ('Annual Audit', 5, '2024-01-01', '2024-02-28', 'completed');
