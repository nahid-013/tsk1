-- PostgreSQL DDL for the assignment
-- Tables: category, category_closure, nomenclature, stock, client, order_table, order_item

CREATE TABLE IF NOT EXISTS category (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS category_closure (
    ancestor BIGINT NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    descendant BIGINT NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    depth INT NOT NULL,
    PRIMARY KEY (ancestor, descendant)
);

CREATE INDEX IF NOT EXISTS idx_category_closure_descendant ON category_closure(descendant);
CREATE INDEX IF NOT EXISTS idx_category_closure_ancestor ON category_closure(ancestor);

CREATE TABLE IF NOT EXISTS nomenclature (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    category_id BIGINT REFERENCES category(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_nomenclature_category ON nomenclature(category_id);

CREATE TABLE IF NOT EXISTS stock (
    id BIGSERIAL PRIMARY KEY,
    nomenclature_id BIGINT NOT NULL REFERENCES nomenclature(id) ON DELETE CASCADE,
    quantity BIGINT NOT NULL CHECK (quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (nomenclature_id)
);

CREATE INDEX IF NOT EXISTS idx_stock_nomenclature ON stock(nomenclature_id);

CREATE TABLE IF NOT EXISTS client (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_table (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL REFERENCES client(id) ON DELETE RESTRICT,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    status TEXT NOT NULL DEFAULT 'NEW'
);

CREATE INDEX IF NOT EXISTS idx_order_client ON order_table(client_id);

CREATE TABLE IF NOT EXISTS order_item (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES order_table(id) ON DELETE CASCADE,
    nomenclature_id BIGINT NOT NULL REFERENCES nomenclature(id) ON DELETE RESTRICT,
    quantity BIGINT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (order_id, nomenclature_id)
);

CREATE INDEX IF NOT EXISTS idx_order_item_order ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_nomenclature ON order_item(nomenclature_id);
