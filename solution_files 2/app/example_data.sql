-- Примеры для быстрой проверки
INSERT INTO client (name, address) VALUES ('ACME Corp', 'Street 1'), ('Beta LLC', 'Street 2');

INSERT INTO category (name) VALUES ('Бытовая техника'), ('Стиральные машины'), ('Холодильники'), ('Компьютеры'), ('Ноутбуки');

-- Закрытия для простого дерева (ancestor, descendant, depth)
-- Для demo можно добавить closure rows manually if needed.

INSERT INTO nomenclature (name, price, category_id) VALUES
('Стиральная машина X', 500.00, 2),
('Холодильник Y', 300.00, 3),
('Ноутбук Z', 1000.00, 5);

INSERT INTO stock (nomenclature_id, quantity) VALUES (1, 10), (2, 5), (3, 2);

INSERT INTO order_table (client_id) VALUES (1), (2);

INSERT INTO order_item (order_id, nomenclature_id, quantity, unit_price) VALUES (1,1,1,500.00);
