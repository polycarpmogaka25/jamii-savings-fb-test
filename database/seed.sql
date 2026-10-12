MERGE INTO accounts (account_number,customer_id,status,balance,currency) KEY(account_number) VALUES
('100001','C001','ACTIVE',25000.50,'KES'),
('100002','C002','DORMANT',1200.00,'KES'),
('100003','C003','CLOSED',0.00,'KES'),
('100004','C004','ACTIVE',150000.75,'KES');
