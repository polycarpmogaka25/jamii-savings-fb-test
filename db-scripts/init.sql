CREATE TABLE IF NOT EXISTS accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) NOT NULL
    );

INSERT INTO accounts (account_number, status, balance, currency) VALUES
                                                                     ('ACC100200', 'ACTIVE', 14500.50, 'KES'),
                                                                     ('ACC100201', 'DORMANT', 0.00, 'USD'),
                                                                     ('ACC100202', 'CLOSED', -50.00, 'KES');