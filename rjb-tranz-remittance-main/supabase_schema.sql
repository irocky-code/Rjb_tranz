-- RJB TRANZ CRM Database Schema
-- Run this SQL in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  avatar_url TEXT,
  role VARCHAR(20) CHECK (role IN ('admin', 'operator', 'viewer')) DEFAULT 'viewer',
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  
  CONSTRAINT valid_email CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Countries table
CREATE TABLE IF NOT EXISTS countries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code VARCHAR(3) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  currency_code VARCHAR(3) NOT NULL,
  currency_name VARCHAR(255) NOT NULL,
  flag_emoji VARCHAR(10) NOT NULL,
  continent VARCHAR(50) NOT NULL,
  is_popular BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Clients table
CREATE TABLE IF NOT EXISTS clients (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(50) NOT NULL,
  address TEXT,
  country VARCHAR(3) REFERENCES countries(code),
  identification_type VARCHAR(50),
  identification_number VARCHAR(100),
  date_of_birth DATE,
  verification_status VARCHAR(20) CHECK (verification_status IN ('pending', 'verified', 'rejected')) DEFAULT 'pending',
  total_transactions INTEGER DEFAULT 0,
  total_volume DECIMAL(15,2) DEFAULT 0,
  last_transaction_date TIMESTAMP WITH TIME ZONE,
  registration_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  
  CONSTRAINT valid_client_email CHECK (email IS NULL OR email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Exchange rates table
CREATE TABLE IF NOT EXISTS exchange_rates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  from_currency VARCHAR(3) NOT NULL,
  to_currency VARCHAR(3) NOT NULL,
  rate DECIMAL(15,6) NOT NULL,
  buy_rate DECIMAL(15,6),
  sell_rate DECIMAL(15,6),
  change_amount DECIMAL(15,6) DEFAULT 0,
  change_percentage DECIMAL(8,4) DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  source VARCHAR(50) DEFAULT 'manual',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(from_currency, to_currency),
  CONSTRAINT positive_rate CHECK (rate > 0)
);

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  transaction_id VARCHAR(50) UNIQUE NOT NULL,
  client_name VARCHAR(255) NOT NULL,
  client_email VARCHAR(255),
  client_phone VARCHAR(50) NOT NULL,
  sender_name VARCHAR(255) NOT NULL,
  sender_email VARCHAR(255),
  sender_phone VARCHAR(50) NOT NULL,
  sender_country VARCHAR(3) REFERENCES countries(code),
  receiver_name VARCHAR(255) NOT NULL,
  receiver_email VARCHAR(255),
  receiver_phone VARCHAR(50) NOT NULL,
  receiver_country VARCHAR(3) REFERENCES countries(code),
  amount DECIMAL(15,2) NOT NULL,
  from_currency VARCHAR(3) NOT NULL,
  to_currency VARCHAR(3) NOT NULL,
  exchange_rate DECIMAL(15,6) NOT NULL,
  fee_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  fee_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  fee_currency VARCHAR(3) NOT NULL,
  fee_paid_by VARCHAR(10) CHECK (fee_paid_by IN ('sender', 'receiver', 'both')) DEFAULT 'sender',
  total_amount DECIMAL(15,2) NOT NULL,
  status VARCHAR(20) CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')) DEFAULT 'pending',
  payment_method VARCHAR(50),
  receipt_printed BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES users(id),
  
  CONSTRAINT positive_amount CHECK (amount > 0),
  CONSTRAINT positive_total CHECK (total_amount > 0),
  CONSTRAINT valid_client_email CHECK (client_email IS NULL OR client_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_sender_email CHECK (sender_email IS NULL OR sender_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_receiver_email CHECK (receiver_email IS NULL OR receiver_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  invoice_number VARCHAR(50) UNIQUE NOT NULL,
  sender_name VARCHAR(255) NOT NULL,
  sender_email VARCHAR(255),
  sender_phone VARCHAR(50) NOT NULL,
  sender_country VARCHAR(3) REFERENCES countries(code),
  receiver_name VARCHAR(255) NOT NULL,
  receiver_email VARCHAR(255),
  receiver_phone VARCHAR(50) NOT NULL,
  receiver_country VARCHAR(3) REFERENCES countries(code),
  amount DECIMAL(15,2) NOT NULL,
  currency VARCHAR(3) NOT NULL,
  exchange_rate DECIMAL(15,6),
  converted_amount DECIMAL(15,2),
  converted_currency VARCHAR(3),
  fee_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  fee_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  description TEXT,
  due_date DATE NOT NULL,
  status VARCHAR(20) CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')) DEFAULT 'draft',
  payment_method VARCHAR(50),
  payment_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  
  CONSTRAINT positive_invoice_amount CHECK (amount > 0),
  CONSTRAINT valid_sender_email CHECK (sender_email IS NULL OR sender_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_receiver_email CHECK (receiver_email IS NULL OR receiver_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- System configurations table
CREATE TABLE IF NOT EXISTS system_configs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  category VARCHAR(50) NOT NULL DEFAULT 'general',
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Printer logs table
CREATE TABLE IF NOT EXISTS printer_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  transaction_id UUID REFERENCES transactions(id),
  invoice_id UUID REFERENCES invoices(id),
  print_type VARCHAR(20) CHECK (print_type IN ('receipt', 'invoice', 'report')) NOT NULL,
  status VARCHAR(20) CHECK (status IN ('success', 'failed', 'pending')) DEFAULT 'pending',
  printer_name VARCHAR(255),
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  
  CONSTRAINT has_reference CHECK (transaction_id IS NOT NULL OR invoice_id IS NOT NULL)
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  action VARCHAR(50) NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id UUID NOT NULL,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_client_name ON transactions(client_name);
CREATE INDEX IF NOT EXISTS idx_transactions_currency_pair ON transactions(from_currency, to_currency);

CREATE INDEX IF NOT EXISTS idx_clients_name ON clients(name);
CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);
CREATE INDEX IF NOT EXISTS idx_clients_phone ON clients(phone);
CREATE INDEX IF NOT EXISTS idx_clients_verification_status ON clients(verification_status);

CREATE INDEX IF NOT EXISTS idx_exchange_rates_currency_pair ON exchange_rates(from_currency, to_currency);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_last_updated ON exchange_rates(last_updated DESC);

CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date ON invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Create triggers for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply the trigger to relevant tables
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_clients_updated_at ON clients;
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_transactions_updated_at ON transactions;
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_invoices_updated_at ON invoices;
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_exchange_rates_updated_at ON exchange_rates;
CREATE TRIGGER update_exchange_rates_updated_at BEFORE UPDATE ON exchange_rates FOR EACH ROW EXECUTE FUNCTION update_exchange_rates_updated_at_column();

DROP TRIGGER IF EXISTS update_countries_updated_at ON countries;
CREATE TRIGGER update_countries_updated_at BEFORE UPDATE ON countries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_system_configs_updated_at ON system_configs;
CREATE TRIGGER update_system_configs_updated_at BEFORE UPDATE ON system_configs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update client statistics
CREATE OR REPLACE FUNCTION update_client_stats(client_id UUID, transaction_amount DECIMAL)
RETURNS VOID AS $$
BEGIN
    UPDATE clients 
    SET 
        total_transactions = total_transactions + 1,
        total_volume = total_volume + transaction_amount,
        last_transaction_date = NOW(),
        updated_at = NOW()
    WHERE id = client_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get dashboard statistics
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS TABLE(
    total_transactions BIGINT,
    completed_transactions BIGINT,
    pending_transactions BIGINT,
    failed_transactions BIGINT,
    total_revenue DECIMAL,
    total_volume DECIMAL,
    active_clients BIGINT,
    today_transactions BIGINT,
    today_revenue DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_transactions,
        COUNT(*) FILTER (WHERE status = 'completed') as completed_transactions,
        COUNT(*) FILTER (WHERE status = 'pending') as pending_transactions,
        COUNT(*) FILTER (WHERE status = 'failed') as failed_transactions,
        COALESCE(SUM(fee_amount) FILTER (WHERE status = 'completed'), 0) as total_revenue,
        COALESCE(SUM(amount) FILTER (WHERE status = 'completed'), 0) as total_volume,
        (SELECT COUNT(*) FROM clients WHERE is_active = true) as active_clients,
        COUNT(*) FILTER (WHERE DATE(created_at) = CURRENT_DATE) as today_transactions,
        COALESCE(SUM(fee_amount) FILTER (WHERE DATE(created_at) = CURRENT_DATE AND status = 'completed'), 0) as today_revenue
    FROM transactions;
END;
$$ LANGUAGE plpgsql;

-- Function to get transactions by period
CREATE OR REPLACE FUNCTION get_transactions_by_period(period_type TEXT)
RETURNS TABLE(
    period_date DATE,
    transaction_count BIGINT,
    total_volume DECIMAL,
    total_revenue DECIMAL
) AS $$
BEGIN
    IF period_type = 'day' THEN
        RETURN QUERY
        SELECT 
            DATE(created_at) as period_date,
            COUNT(*) as transaction_count,
            COALESCE(SUM(amount), 0) as total_volume,
            COALESCE(SUM(fee_amount), 0) as total_revenue
        FROM transactions 
        WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at);
    ELSIF period_type = 'week' THEN
        RETURN QUERY
        SELECT 
            DATE(DATE_TRUNC('week', created_at)) as period_date,
            COUNT(*) as transaction_count,
            COALESCE(SUM(amount), 0) as total_volume,
            COALESCE(SUM(fee_amount), 0) as total_revenue
        FROM transactions 
        WHERE created_at >= CURRENT_DATE - INTERVAL '12 weeks'
        GROUP BY DATE_TRUNC('week', created_at)
        ORDER BY DATE_TRUNC('week', created_at);
    ELSIF period_type = 'month' THEN
        RETURN QUERY
        SELECT 
            DATE(DATE_TRUNC('month', created_at)) as period_date,
            COUNT(*) as transaction_count,
            COALESCE(SUM(amount), 0) as total_volume,
            COALESCE(SUM(fee_amount), 0) as total_revenue
        FROM transactions 
        WHERE created_at >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY DATE_TRUNC('month', created_at)
        ORDER BY DATE_TRUNC('month', created_at);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert default admin user (password: admin123 - change this immediately!)
INSERT INTO users (username, email, full_name, role, password_hash) 
VALUES (
    'admin', 
    'admin@rjbtranz.com', 
    'System Administrator', 
    'admin', 
    crypt('admin123', gen_salt('bf'))
) ON CONFLICT (username) DO NOTHING;

-- Insert sample countries with flags and currency information
INSERT INTO countries (code, name, currency_code, currency_name, flag_emoji, continent, is_popular) VALUES
-- Africa
('GHA', 'Ghana', 'GHS', 'Ghanaian Cedi', '🇬🇭', 'Africa', true),
('NGA', 'Nigeria', 'NGN', 'Nigerian Naira', '🇳🇬', 'Africa', true),
('KEN', 'Kenya', 'KES', 'Kenyan Shilling', '🇰🇪', 'Africa', false),
('ZAF', 'South Africa', 'ZAR', 'South African Rand', '🇿🇦', 'Africa', false),
('EGY', 'Egypt', 'EGP', 'Egyptian Pound', '🇪🇬', 'Africa', false),
('MAR', 'Morocco', 'MAD', 'Moroccan Dirham', '🇲🇦', 'Africa', false),
('TUN', 'Tunisia', 'TND', 'Tunisian Dinar', '🇹🇳', 'Africa', false),
('ETH', 'Ethiopia', 'ETB', 'Ethiopian Birr', '🇪🇹', 'Africa', false),
('UGA', 'Uganda', 'UGX', 'Ugandan Shilling', '🇺🇬', 'Africa', false),
('TZA', 'Tanzania', 'TZS', 'Tanzanian Shilling', '🇹🇿', 'Africa', false),

-- Asia
('IND', 'India', 'INR', 'Indian Rupee', '🇮🇳', 'Asia', true),
('PHL', 'Philippines', 'PHP', 'Philippine Peso', '🇵🇭', 'Asia', true),
('BGD', 'Bangladesh', 'BDT', 'Bangladeshi Taka', '🇧🇩', 'Asia', false),
('PAK', 'Pakistan', 'PKR', 'Pakistani Rupee', '🇵🇰', 'Asia', false),
('CHN', 'China', 'CNY', 'Chinese Yuan', '🇨🇳', 'Asia', true),
('JPN', 'Japan', 'JPY', 'Japanese Yen', '🇯🇵', 'Asia', true),
('KOR', 'South Korea', 'KRW', 'South Korean Won', '🇰🇷', 'Asia', false),
('THA', 'Thailand', 'THB', 'Thai Baht', '🇹🇭', 'Asia', true),
('VNM', 'Vietnam', 'VND', 'Vietnamese Dong', '🇻🇳', 'Asia', true),
('IDN', 'Indonesia', 'IDR', 'Indonesian Rupiah', '🇮🇩', 'Asia', true),

-- Europe
('GBR', 'United Kingdom', 'GBP', 'British Pound', '🇬🇧', 'Europe', true),
('DEU', 'Germany', 'EUR', 'Euro', '🇩🇪', 'Europe', false),
('FRA', 'France', 'EUR', 'Euro', '🇫🇷', 'Europe', false),
('ITA', 'Italy', 'EUR', 'Euro', '🇮🇹', 'Europe', false),
('ESP', 'Spain', 'EUR', 'Euro', '🇪🇸', 'Europe', false),
('CHE', 'Switzerland', 'CHF', 'Swiss Franc', '🇨🇭', 'Europe', false),

-- Americas
('USA', 'United States', 'USD', 'US Dollar', '🇺🇸', 'North America', true),
('CAN', 'Canada', 'CAD', 'Canadian Dollar', '🇨🇦', 'North America', false),
('MEX', 'Mexico', 'MXN', 'Mexican Peso', '🇲🇽', 'North America', true),
('BRA', 'Brazil', 'BRL', 'Brazilian Real', '🇧🇷', 'South America', true),

-- Oceania
('AUS', 'Australia', 'AUD', 'Australian Dollar', '🇦🇺', 'Oceania', true),
('NZL', 'New Zealand', 'NZD', 'New Zealand Dollar', '🇳🇿', 'Oceania', false)

ON CONFLICT (code) DO NOTHING;

-- Insert default system configurations
INSERT INTO system_configs (key, value, description, category) VALUES
('company_name', 'RJB TRANZ', 'Company name displayed in the system', 'company'),
('company_email', 'admin@rjbtranz.com', 'Primary company email address', 'company'),
('company_phone', '+233-123-456-789', 'Primary company phone number', 'company'),
('company_address', 'Accra, Ghana', 'Company physical address', 'company'),
('base_currency', 'USD', 'Base currency for calculations', 'financial'),
('default_fee_rate', '2.5', 'Default transaction fee percentage', 'financial'),
('auto_backup', 'true', 'Enable automatic data backup', 'system'),
('notification_sound', 'true', 'Enable notification sounds', 'notifications'),
('print_receipts', 'true', 'Automatically print receipts', 'printing'),
('session_timeout', '30', 'Session timeout in minutes', 'security')
ON CONFLICT (key) DO NOTHING;

-- Insert sample exchange rates
INSERT INTO exchange_rates (from_currency, to_currency, rate, change_amount, change_percentage, source) VALUES
('USD', 'GHS', 12.45, 0.15, 1.22, 'manual'),
('USD', 'NGN', 795.50, -5.25, -0.66, 'manual'),
('USD', 'KES', 129.75, 2.10, 1.64, 'manual'),
('USD', 'INR', 83.25, 0.45, 0.54, 'manual'),
('USD', 'PHP', 56.75, -0.85, -1.48, 'manual'),
('USD', 'EUR', 0.92, -0.005, -0.54, 'manual'),
('USD', 'GBP', 0.79, -0.003, -0.38, 'manual'),
('USD', 'CAD', 1.36, 0.008, 0.59, 'manual'),
('USD', 'AUD', 1.52, 0.01, 0.66, 'manual')
ON CONFLICT (from_currency, to_currency) DO NOTHING;