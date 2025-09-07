from fastapi import FastAPI, HTTPException, Path
from pydantic import BaseModel, PositiveInt
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, Nomenclature, OrderTable, OrderItem, Stock
from database import get_db, init_db
from sqlalchemy.exc import IntegrityError

app = FastAPI(title="Order service - Add item to order")

# Pydantic model for request
class AddItemRequest(BaseModel):
    nomenclature_id: int
    quantity: PositiveInt

@app.on_event("startup")
def startup():
    init_db()

@app.post("/orders/{order_id}/items")
def add_item(order_id: int = Path(..., gt=0), payload: AddItemRequest = None):
    db = next(get_db())
    # Check order exists
    order = db.query(OrderTable).filter(OrderTable.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Check nomenclature exists
    product = db.query(Nomenclature).filter(Nomenclature.id == payload.nomenclature_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Nomenclature not found")

    # Check stock
    stock = db.query(Stock).filter(Stock.nomenclature_id == product.id).with_for_update().first()
    if not stock or stock.quantity < payload.quantity:
        raise HTTPException(status_code=409, detail="Not enough stock")

    # Upsert order_item: if exists increase quantity, else insert
    oi = db.query(OrderItem).filter(
        OrderItem.order_id == order_id,
        OrderItem.nomenclature_id == product.id
    ).with_for_update().first()

    try:
        if oi:
            oi.quantity += payload.quantity
            db.add(oi)
        else:
            oi = OrderItem(
                order_id=order_id,
                nomenclature_id=product.id,
                quantity=payload.quantity,
                unit_price=product.price
            )
            db.add(oi)

        # Decrease stock
        stock.quantity -= payload.quantity
        db.add(stock)

        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database integrity error")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    return {
        "order_id": order_id,
        "nomenclature_id": product.id,
        "quantity": oi.quantity,
        "unit_price": float(oi.unit_price)
    }
