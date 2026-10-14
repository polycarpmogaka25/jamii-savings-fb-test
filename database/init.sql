CREATE TABLE IF NOT EXISTS accounts (
                                        account_number VARCHAR(50) PRIMARY KEY,
                                        customer_id VARCHAR(50) NOT NULL,
                                        status VARCHAR(20) NOT NULL,
                                        balance DECIMAL(15,2) NOT NULL,
                                        currency VARCHAR(3) NOT NULL
);

-- Seed test data with customer_id included
MERGE INTO accounts (account_number, customer_id, status, balance, currency)
    KEY(account_number)
    VALUES ('ACC100200', 'CUST001', 'ACTIVE', 54300.00, 'KES');