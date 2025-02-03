from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
import pymysql
import hosts

router = APIRouter()

class OrderItem(BaseModel):
    product_id: int
    quantity: int
    total_price: float

class OrderRequest(BaseModel):
    user_id: str
    order_date: datetime = datetime.now()
    address: str
    payment_method: str
    order_state: str = "Preparing_for_delivery"
    products: list[OrderItem]

@router.get("/order_select")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT O.Order_ID, O.Product_seq, O.User_ID, P.name, P.price, O.Order_date, O.Address, O.refund_demands_time, O.refund_time, O.payment_method, O.Arrival_Time, O.Order_state FROM orders as O, products as P, users as U where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.post("/create_order")
async def create_order(order: OrderRequest):
    try:
        conn = hosts.connect_to_mysql()
        curs = conn.cursor()

        # 1️먼저 주문을 생성하여 Order_ID 확보
        sql_order = """
        INSERT INTO orders (User_ID, Order_Date, Address, payment_method, Order_state)
        VALUES (%s, %s, %s, %s, %s)
        """
        values_order = (order.user_id, order.order_date, order.address, order.payment_method, order.order_state)

        curs.execute(sql_order, values_order)
        order_id = curs.lastrowid  # 방금 삽입한 주문의 ID 가져오기

        # 여러 개의 상품을 `Product_seq`에 추가
        sql_product = """
        INSERT INTO orders (Order_ID, Product_seq, User_ID, Product_ID, Order_Date, Address, payment_method, Order_state)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        product_seq = 1  # ✅ 첫 번째 상품부터 순차적으로 저장
        for product in order.products:
            values_product = (
                order_id, 
                product_seq, 
                order.user_id, 
                product.product_id, 
                order.order_date, 
                order.address, 
                order.payment_method, 
                order.order_state
            )
            curs.execute(sql_product, values_product)
            product_seq += 1  # 🔹 상품 순서 증가

        conn.commit()
        conn.close()

        return {"message": "Order created successfully", "order_id": order_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))