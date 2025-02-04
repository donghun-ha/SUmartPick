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

        # 먼저 `orders` 테이블에 주문 정보 저장 (Product_ID 없이 삽입)
        sql_order = """
        INSERT INTO orders (User_ID, Order_Date, Address, payment_method, Order_state)
        VALUES (%s, %s, %s, %s, %s)
        """
        values_order = (order.user_id, order.order_date, order.address, order.payment_method, order.order_state)
        curs.execute(sql_order, values_order)

        order_id = curs.lastrowid  # 새로 생성된 주문 ID 가져오기

        # 주문한 각 상품을 `orders` 테이블에 추가
        product_seq = 1  # 첫 번째 상품부터 시작
        for product in order.products:
            sql_product = """
            INSERT INTO orders (Order_ID, Product_seq, User_ID, Product_ID, Order_Date, Address, payment_method, Order_state)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            values_product = (
                order_id,  # 방금 삽입한 주문 ID
                product_seq,  # 순차적인 제품 번호
                order.user_id,
                product.product_id,  # 올바른 Product_ID 입력
                order.order_date,
                order.address,
                order.payment_method,
                order.order_state
            )
            curs.execute(sql_product, values_product)
            product_seq += 1  # 상품 순서 증가

        conn.commit()
        conn.close()

        return {"message": "Order created successfully", "order_id": order_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 환불요청 없는 주문 상태 업데이트
@router.get("/norefund_orders_update")
async def update(Arrival_Time: str = None, Order_state: str = None, Order_ID: int = None, Product_seq: int = None):
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()

    try:
        sql = """
        UPDATE orders 
        SET Arrival_Time = NULLIF(%s, ''), Order_state = %s 
        WHERE Order_ID = %s AND Product_seq = %s
        """
        curs.execute(sql, (Arrival_Time, Order_state, Order_ID, Product_seq))
        conn.commit()
        conn.close()
        return {'results': 'OK'}
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'results': 'Error', 'error': str(e)}

# 환불요청 주문 상태 업데이트
@router.get("/refund_orders_update")
async def update(refund_time: str = None, Order_state: str = None, Order_ID: int = None, Product_seq: int = None):
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()

    try:
        sql = """
        UPDATE orders 
        SET refund_time = NULLIF(%s, ''), Order_state = %s 
        WHERE Order_ID = %s AND Product_seq = %s
        """
        curs.execute(sql, (refund_time, Order_state, Order_ID, Product_seq))
        conn.commit()
        conn.close()
        return {'results': 'OK'}
    except Exception as e:
        conn.close()
        print("Error:", e)
        return {'results': 'Error', 'error': str(e)}