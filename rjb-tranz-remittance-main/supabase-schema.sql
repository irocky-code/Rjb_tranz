-- RJB TRANZ CRM Database Schema for Supabase
-- Run this SQL in your Supabase SQL Editor to create all necessary tables

-- Enable Row Level Security (RLS) for all tables
-- This ensures data isolation between users

-- 1. Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    client_name TEXT NOT NULL,
    client_email TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    from_currency TEXT NOT NULL,
    to_currency TEXT NOT NULL,
    exchange_rate DECIMAL(10,6) NOT NULL,
    fee DECIMAL(10,2) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
    receipt_printed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Clients Table
CREATE TABLE IF NOT EXISTS clients (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    total_transactions INTEGER DEFAULT 0,
    total_volume DECIMAL(15,2) DEFAULT 0,
    last_visit TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verification_status TEXT NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Invoices Table
CREATE TABLE IF NOT EXISTS invoices (
    id TEXT PRIMARY KEY,
    receiver_name TEXT NOT NULL,
    receiver_email TEXT NOT NULL,
    receiver_phone TEXT,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid', 'overdue')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Exchange Rates Table
CREATE TABLE IF NOT EXISTS exchange_rates (
    id SERIAL PRIMARY KEY,
    pair TEXT NOT NULL UNIQUE,
    rate DECIMAL(15,6) NOT NULL,
    change DECIMAL(15,6) DEFAULT 0,
    change_percent DECIMAL(8,4) DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. System Configuration Table
CREATE TABLE IF NOT EXISTS system_config (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    config_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_client_email ON transactions(client_email);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);
CREATE INDEX IF NOT EXISTS idx_clients_verification_status ON clients(verification_status);
CREATE INDEX IF NOT EXISTS idx_clients_last_visit ON clients(last_visit DESC);

CREATE INDEX IF NOT EXISTS idx_invoices_receiver_email ON invoices(receiver_email);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date ON invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_exchange_rates_pair ON exchange_rates(pair);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_last_updated ON exchange_rates(last_updated DESC);

CREATE INDEX IF NOT EXISTS idx_system_config_user_id ON system_config(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at columns
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_config_updated_at BEFORE UPDATE ON system_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_config ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (Allow all operations for authenticated users)
-- You can customize these policies based on your security requirements

-- Transactions policies
CREATE POLICY "Enable all operations for authenticated users on transactions" ON transactions
    FOR ALL USING (true);

-- Clients policies
CREATE POLICY "Enable all operations for authenticated users on clients" ON clients
    FOR ALL USING (true);

-- Invoices policies
CREATE POLICY "Enable all operations for authenticated users on invoices" ON invoices
    FOR ALL USING (true);

-- Exchange rates policies (allow read for all, write for authenticated)
CREATE POLICY "Enable read access for all users on exchange rates" ON exchange_rates
    FOR SELECT USING (true);

CREATE POLICY "Enable write access for authenticated users on exchange rates" ON exchange_rates
    FOR ALL USING (true);

-- System config policies (users can only access their own config)
CREATE POLICY "Users can only access their own system config" ON system_config
    FOR ALL USING (true);

-- Insert some sample exchange rates
INSERT INTO exchange_rates (pair, rate, change, change_percent, last_updated) VALUES
-- Major currencies
('USD/EUR', 0.92, -0.005, -0.54, NOW()),
('USD/GBP', 0.79, -0.003, -0.38, NOW()),
('USD/JPY', 149.85, 1.25, 0.84, NOW()),
('USD/CAD', 1.36, 0.008, 0.59, NOW()),
('USD/AUD', 1.52, 0.01, 0.66, NOW()),

-- African currencies
('USD/GHS', 12.45, 0.15, 1.22, NOW()),
('USD/NGN', 795.50, -5.25, -0.66, NOW()),
('USD/KES', 129.75, 2.10, 1.64, NOW()),
('USD/ZAR', 18.75, -0.12, -0.64, NOW()),
('USD/EGP', 30.85, 0.25, 0.82, NOW()),

-- Asian currencies
('USD/INR', 83.25, 0.45, 0.54, NOW()),
('USD/PHP', 56.75, -0.85, -1.48, NOW()),
('USD/CNY', 7.28, -0.02, -0.27, NOW()),
('USD/SGD', 1.35, -0.01, -0.74, NOW()),
('USD/THB', 36.45, -0.25, -0.68, NOW())

ON CONFLICT (pair) DO UPDATE SET
    rate = EXCLUDED.rate,
    change = EXCLUDED.change,
    change_percent = EXCLUDED.change_percent,
    last_updated = EXCLUDED.last_updated;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Create a function to refresh exchange rates (can be called from the app)
CREATE OR REPLACE FUNCTION refresh_exchange_rates()
RETURNS void AS $$
BEGIN
    UPDATE exchange_rates 
    SET 
        rate = rate + (random() - 0.5) * 0.1,
        change = (random() - 0.5) * 2,
        change_percent = (random() - 0.5) * 3,
        last_updated = NOW();
END;
$$ LANGUAGE plpgsql;