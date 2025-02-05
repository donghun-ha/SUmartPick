from fastapi import APIRouter, HTTPException
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from datetime import datetime
import pymysql
import hosts
import json

router = APIRouter()

# 주문 아이템 모델
class OrderItem(BaseModel):
    Product_ID: int
    quantity: int  # 상품 개수 추가

# 주문 요청 모델
class OrderRequest(BaseModel):
    User_ID: str
    Address: str
    payment_method: str
    Order_state: str = "Payment_completed"
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
        # JSON 직렬화 가능하게 변환
        order_data = jsonable_encoder(order)
        print("Received JSON:", json.dumps(order_data, indent=4, ensure_ascii=False))

        conn = hosts.connect_to_mysql()
        curs = conn.cursor()

        # 주문한 모든 상품이 `products` 테이블에 존재하는지 확인
        for product in order.products:
            curs.execute("SELECT 1 FROM products WHERE Product_ID = %s", (product.Product_ID,))
            if not curs.fetchone():
                raise HTTPException(status_code=400, detail=f"Product_ID {product.Product_ID} does not exist")

        sql_order = """
        SELECT Order_ID 
        FROM orders
        ORDER BY Order_ID DESC
        LIMIT 1
        """

        curs.execute(sql_order,)
        order_id = curs.fetchone()[0] + 1

        
        # 주문한 각 상품을 추가하면서 `Product_seq` 증가
        sql_product = """
        INSERT INTO orders (Order_ID, Product_seq, User_ID, Product_ID, Address, payment_method, Order_state)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        product_seq = 1  # 첫 번째 상품부터 Product_seq 시작
        for product in order.products:
            for _ in range(product.quantity):  # 주문 개수만큼 반복하여 삽입
                values_product = (
                    order_id,
                    product_seq,  # Product_seq 증가
                    order.User_ID,
                    product.Product_ID,
                    order.Address,
                    order.payment_method,
                    order.Order_state
                )
                curs.execute(sql_product, values_product)
                product_seq += 1  # Product_seq 증가

        conn.commit()
        conn.close()

        return {
            "message": "Order created successfully"
            }

    except Exception as e:
        print("JSON 직렬화 오류:", str(e))
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
        print("Error :", e)
        return {'results' : 'Error'}
    
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

#### 주문내역
@router.get("/{user_id}")
async def get_user_orders(user_id: str):
    conn = hosts.connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            SELECT 
                o.Order_ID,
                o.Product_seq,
                o.User_ID,
                o.Product_ID,
                o.Order_Date,
                o.Address,
                o.refund_demands_time,
                o.refund_time,
                o.payment_method,
                o.Arrival_Time,
                o.Order_state,
                p.name AS product_name,
                p.preview_image AS product_image,
                p.price AS product_price
            FROM orders o
            JOIN products p ON o.Product_ID = p.Product_ID
            WHERE o.User_ID = %s
            ORDER BY o.Order_Date DESC
        """
        cursor.execute(sql, (user_id,))
        orders = cursor.fetchall()

        # Python dict 형태로 온 데이터 중 datetime 타입을 isoformat()으로 변환
        for row in orders:
            if row["Order_Date"]:
                row["Order_Date"] = row["Order_Date"].isoformat()
            if row["refund_demands_time"]:
                row["refund_demands_time"] = row["refund_demands_time"].isoformat()
            if row["refund_time"]:
                row["refund_time"] = row["refund_time"].isoformat()
            if row["Arrival_Time"]:
                row["Arrival_Time"] = row["Arrival_Time"].isoformat()

        return orders

    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()



#### 환불
@router.get("/refunds/{user_id}")
async def get_refund_exchange_orders(user_id: str):
    conn = hosts.connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:

        sql = """
            SELECT 
                o.Order_ID,
                o.Product_seq,
                o.User_ID,
                o.Product_ID,
                o.Order_Date,
                o.Address,
                o.refund_demands_time,
                o.refund_time,
                o.payment_method,
                o.Arrival_Time,
                o.Order_state,
                p.name AS product_name,
                p.preview_image AS product_image,
                p.price AS product_price
            FROM orders o
            JOIN products p ON o.Product_ID = p.Product_ID
            WHERE o.User_ID = %s
              -- 반품 신청 상태값 추가
              AND o.Order_state IN ('Cancelled', 'Returned', 'Exchanged', 'Return_Requested')
            ORDER BY o.Order_Date DESC
        """
        cursor.execute(sql, (user_id,))
        orders = cursor.fetchall()

        for row in orders:
            if row["Order_Date"]:
                row["Order_Date"] = row["Order_Date"].isoformat()
            if row["refund_demands_time"]:
                row["refund_demands_time"] = row["refund_demands_time"].isoformat()
            if row["refund_time"]:
                row["refund_time"] = row["refund_time"].isoformat()
            if row["Arrival_Time"]:
                row["Arrival_Time"] = row["Arrival_Time"].isoformat()

        return orders

    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router.put("/{order_id}/requestRefund")
async def request_refund(order_id: int):
    """
    예시: 반품 신청 처리
    """
    conn = hosts.connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            UPDATE orders
            SET refund_demands_time = NOW(),
                Order_state = 'Return_Requested'
            WHERE Order_ID = %s
        """
        cursor.execute(sql, (order_id,))
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Order not found.")
        conn.commit()
        return {"message": "Refund request submitted."}
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error.")
    finally:
        conn.close()



#### 배송조회쪽(고칠예정)
@router.get("/{order_id}/track")
async def track_order(order_id: int):
    conn = hosts.connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            SELECT Order_ID, TrackingNumber, Carrier, ShippingStatus
            FROM orders
            WHERE Order_ID = %s
        """
        cursor.execute(sql, (order_id,))
        tracking_info = cursor.fetchone()

        # 만약 tracking_info가 None이면 order_id에 해당하는 레코드가 없는 경우
        if not tracking_info:
            raise HTTPException(status_code=404, detail="Order not found.")

        return tracking_info
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()
        print("Error:", e)
        return {'results': 'Error', 'error': str(e)}
    









#### 머신러닝 테스트
@router.get("/ml_test")
async def track_order(order_id: int):
    """
    머신러닝 테스트용으로 만든 테스트에용
    """
    import pymysql
    import pandas as pd
    import hashlib

    def text_to_number(text):
        hash_object = hashlib.md5(text.encode('utf-8'))  # MD5 해시 생성
        return int(hash_object.hexdigest(), 16)  # 16진수를 10진수 정수로 변환

    import joblib
    loaded_rf = joblib.load('best_random_forest_model.pkl')

    seller_id_parser =  pd.read_csv('seller_id_parser.csv', index_col=0)
    train =  pd.read_csv('time_train.csv', index_col=0)

    dist_idx = text_to_number(orders[0]['Address']) % train.shape[0]
    dist = train['dist'].iloc[dist_idx]

    # order_id = 14


    conn = hosts.connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)

    sql = f"""
        select *
        from orders as o
        JOIN products p ON p.Product_ID = o.Product_ID
        WHERE o.order_id = {order_id}
        """
    curs.execute(sql)

    orders = curs.fetchall()
    conn.close()

    product_id = orders[0]['Product_ID']
    raw_price = orders[0]['price']

    conn = hosts.connect_to_mysql()
    curs = conn.cursor()

    sql = f"""
        SELECT
            AVG(price) AS avg_price,  -- 평균
            STDDEV(price) AS std_price  -- 표준편차
        FROM products;
    """
    curs.execute(sql)

    av_std_rows = curs.fetchall()
    conn.close()
    # print(av_std_rows)

    your_mean = 1756.1477912569826

    your_std = 3908.8645767822213
    your_min = 5.2 

    our_mean =  av_std_rows[0][0]
    our_std = av_std_rows[0][1]


    price = max(((raw_price - our_mean)/our_std *your_std) + your_mean, your_min)


    customer_city_mean = train['customer_city_mean'].iloc[dist_idx]
    seller_id_mean =  seller_id_parser.loc['6edacfd9f9074789dad6d62ba7950b9c'].item()

    pred =  pd.DataFrame(
        {
            'price' : [price],
            'dist' : [dist],
            'seller_id_mean' : [seller_id_mean],
            'customer_city_mean' : [customer_city_mean],
        }
    )


    return {'results' : loaded_rf.predict(pred).item()}

