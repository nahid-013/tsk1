-- 2.1. Получение информации о сумме товаров заказанных под каждого клиента (Наименование клиента, сумма)
-- Сумма в денежном выражении (unit_price * quantity)
SELECT c.name AS client_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_sum
FROM client c
LEFT JOIN order_table o ON o.client_id = c.id
LEFT JOIN order_item oi ON oi.order_id = o.id
GROUP BY c.id, c.name
ORDER BY total_sum DESC;

-- 2.2. Найти количество дочерних элементов первого уровня вложенности для категорий номенклатуры.
-- First-level children: depth = 1 in closure table where ancestor = category.id
SELECT cat.id,
       cat.name,
       COUNT(cc.descendant) FILTER (WHERE cc.depth = 1) AS first_level_children
FROM category cat
LEFT JOIN category_closure cc ON cc.ancestor = cat.id
GROUP BY cat.id, cat.name
ORDER BY cat.name;

-- 2.3.1 Отчет (view) "Топ-5 самых покупаемых товаров за последний месяц" (по количеству штук)
-- Возвращает: Наименование товара, Категория 1-го уровня, Общее количество проданных штук.

CREATE OR REPLACE VIEW top_5_selling_last_month AS
SELECT
    n.id AS nomenclature_id,
    n.name AS nomenclature_name,
    -- category 1st-level: find ancestor at depth = 1 (immediate parent). If product's category is deeper, get its top-level ancestor at depth = 1 from that category.
    c_parent.name AS category_level_1,
    SUM(oi.quantity) AS total_sold
FROM order_item oi
JOIN order_table o ON o.id = oi.order_id
JOIN nomenclature n ON n.id = oi.nomenclature_id
LEFT JOIN category c ON c.id = n.category_id
LEFT JOIN category_closure cc_parent ON cc_parent.descendant = COALESCE(n.category_id, c.id) AND cc_parent.depth = 1
LEFT JOIN category c_parent ON c_parent.id = cc_parent.ancestor
WHERE o.order_date >= (now() - interval '1 month')
GROUP BY n.id, n.name, c_parent.name
ORDER BY total_sold DESC
LIMIT 5;

-- Альтернативный запрос (без view): тот же select, используйте при необходимости.
