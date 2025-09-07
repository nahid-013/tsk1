from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, BigInteger, Integer, Text, Numeric, ForeignKey, DateTime, func, UniqueConstraint
from sqlalchemy.orm import relationship

Base = declarative_base()

class Category(Base):
    __tablename__ = "category"
    id = Column(BigInteger, primary_key=True)
    name = Column(Text, nullable=False)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class CategoryClosure(Base):
    __tablename__ = "category_closure"
    ancestor = Column(BigInteger, ForeignKey("category.id", ondelete="CASCADE"), primary_key=True)
    descendant = Column(BigInteger, ForeignKey("category.id", ondelete="CASCADE"), primary_key=True)
    depth = Column(Integer, nullable=False)

class Nomenclature(Base):
    __tablename__ = "nomenclature"
    id = Column(BigInteger, primary_key=True)
    name = Column(Text, nullable=False)
    price = Column(Numeric(12,2), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    category_id = Column(BigInteger, ForeignKey("category.id", ondelete="SET NULL"))

class Stock(Base):
    __tablename__ = "stock"
    id = Column(BigInteger, primary_key=True)
    nomenclature_id = Column(BigInteger, ForeignKey("nomenclature.id", ondelete="CASCADE"), unique=True, nullable=False)
    quantity = Column(BigInteger, nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now())

class Client(Base):
    __tablename__ = "client"
    id = Column(BigInteger, primary_key=True)
    name = Column(Text, nullable=False)
    address = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class OrderTable(Base):
    __tablename__ = "order_table"
    id = Column(BigInteger, primary_key=True)
    client_id = Column(BigInteger, ForeignKey("client.id", ondelete="RESTRICT"), nullable=False)
    order_date = Column(DateTime(timezone=True), server_default=func.now())
    status = Column(Text, nullable=False, server_default="NEW")

class OrderItem(Base):
    __tablename__ = "order_item"
    id = Column(BigInteger, primary_key=True)
    order_id = Column(BigInteger, ForeignKey("order_table.id", ondelete="CASCADE"), nullable=False)
    nomenclature_id = Column(BigInteger, ForeignKey("nomenclature.id", ondelete="RESTRICT"), nullable=False)
    quantity = Column(BigInteger, nullable=False)
    unit_price = Column(Numeric(12,2), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint('order_id', 'nomenclature_id', name='uq_order_nomenclature'),)
