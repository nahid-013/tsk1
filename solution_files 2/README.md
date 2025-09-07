Решение задания — пакет файлов.

Содержимое архива:
- schema.sql            -- DDL для PostgreSQL (таблицы и индексы)
- queries.sql           -- Запросы из пункта 2
- analysis_optimizations.md -- Анализ и варианты оптимизации (п. 2.3.2)
- app/                  -- Пример сервиса FastAPI для "Добавление товара в заказ"
    - main.py
    - models.py
    - database.py
    - docker-compose.yml
    - Dockerfile
    - requirements.txt
    - example_data.sql
    - README_service.md

Как запустить сервис (локально, с docker-compose):
1) Установите Docker и docker-compose.
2) Перейдите в папку app и выполните:
   docker-compose up --build
3) Сервис будет доступен на http://localhost:8000
   Endpoint: POST /orders/{order_id}/items
   Тело JSON:
   {
     "nomenclature_id": <int>,
     "quantity": <int>
   }

Ответы:
- 200 OK: возвращает обновлённую позицию заказа
- 404 Not Found: заказ или номенклатура не найдены
- 400 Bad Request: если количество <= 0
- 409 Conflict: если недостаточно на складе

Пример curl:
curl -X POST http://localhost:8000/orders/1/items -H "Content-Type: application/json" \
  -d '{"nomenclature_id":1,"quantity":2}'

Для заполнения БД примерами есть app/example_data.sql
