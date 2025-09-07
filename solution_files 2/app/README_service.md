Service README

Endpoints:
POST /orders/{order_id}/items
Body:
{
    "nomenclature_id": int,
    "quantity": positive int
}

Responses:
200: {"order_id":.., "nomenclature_id":.., "quantity":.., "unit_price":..}
404: order or product not found
409: not enough stock

Notes:
- The service uses PostgreSQL (see docker-compose). On first start, it will create tables.
- example_data.sql can be applied to fill demo data.
