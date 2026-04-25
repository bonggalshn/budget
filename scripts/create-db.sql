-- Create user if not exists
CREATE USER budget_user WITH PASSWORD 'budget';
-- Create database
CREATE DATABASE budget_database OWNER budget_user;
-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE budget_database TO budget_user;