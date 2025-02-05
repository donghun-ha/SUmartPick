# main.py
import os
import json
import base64
import random
import hashlib
from datetime import datetime, timedelta

import pandas as pd
import pymysql
import joblib

from fastapi import FastAPI, APIRouter, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List

# -------------------------------------------------
# Database 연결 (로컬 환경)
# -------------------------------------------------
LOCAL_DB_CONFIG = {
    "host": "localhost",  # 로컬 MySQL 서버
    "user": "root",  # 사용자명 (필요에 따라 수정)
    "password": "qwer1234",  # 비밀번호 (필요에 따라 수정)
    "db": "sumartpick",  # 데이터베이스 이름 (필요에 따라 수정)
    "port": 3306,
    "charset": "utf8",
}


def connect_to_mysql():
    """
    로컬 MySQL 데이터베이스 연결 후 연결 객체 반환
    """
    try:
        conn = pymysql.connect(**LOCAL_DB_CONFIG)
        print("MySQL 연결 성공 (로컬)")
        return conn
    except Exception as e:
        print(f"MySQL 연결 실패: {e}")
        raise e


# -------------------------------------------------
# Firebase Admin SDK 초기화 (주석 처리)
# -------------------------------------------------
# import firebase_admin
# from firebase_admin import credentials, storage
#
# # 로컬 firebase 키 파일 경로와 버킷 이름 (필요에 따라 수정)
# firebase_key_path = os.getenv("FIREBASE_KEY_PATH", "local-firebase-key.json")
# cred = credentials.Certificate(firebase_key_path)
# firebase_admin.initialize_app(
#     cred,
#     {"storageBucket": os.getenv("FIREBASE_BUCKET", "local-firebase-bucket")}
# )

# -------------------------------------------------
# Address Router (주소 업데이트)
# -------------------------------------------------
router_address = APIRouter()


class UpdateAddressRequest(BaseModel):
    user_id: str  # 사용자 식별자
    address: str  # 변경할 주소


@router_address.put("/update_address")
async def update_address(req: UpdateAddressRequest):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = "UPDATE users SET address = %s WHERE User_ID = %s"
        cursor.execute(sql, (req.address, req.user_id))
        conn.commit()
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="User not found")
        return {"message": "Address updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error occurred: {e}")
    finally:
        cursor.close()
        conn.close()


# -------------------------------------------------
# Product Router (상품 관련 API)
# -------------------------------------------------
router_product = APIRouter()


class ProductQuery(BaseModel):
    name: str  # 상품 이름 검색


class ProductResponse(BaseModel):
    Product_ID: int
    Category_ID: int
    name: str
    preview_image: str
    price: float
    detail: str
    manufacturer: str
    created: str


class ProductCreateRequest(BaseModel):
    Category_ID: int  # 카테고리 ID
    name: str  # 상품 이름
    base64_image: str  # Base64 인코딩 이미지
    price: float
    detail: str
    manufacturer: str


class ProductUpdateRequest(BaseModel):
    Product_ID: int
    Category_ID: int
    name: str
    base64_image: str
    price: float


@router_product.post("/products_query", response_model=List[ProductResponse])
async def products_query(query: ProductQuery):
    if not query.name:
        raise HTTPException(status_code=400, detail="상품 이름이 누락되었습니다.")
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql_query = """
        SELECT 
            Product_ID, 
            Category_ID, 
            name, 
            preview_image,
            price, 
            detail, 
            manufacturer, 
            created 
        FROM products 
        WHERE name LIKE %s
        """
        params = [f"%{query.name}%"]
        cursor.execute(sql_query, params)
        products = cursor.fetchall()
        return products
    except Exception as e:
        raise HTTPException(status_code=500, detail="MySQL 작업 실패")
    finally:
        cursor.close()
        mysql_conn.close()


@router_product.post("/insert_products")
async def create_product(product: ProductCreateRequest):
    try:
        mysql_conn = connect_to_mysql()
        cursor = mysql_conn.cursor()
        # 카테고리 매핑 (예시)
        category_map = {
            4: "가구",
            5: "기타",
            6: "도서",
            7: "미디어",
            8: "뷰티",
            9: "스포츠",
            10: "식품_음료",
            11: "유아_애완",
            12: "전자제품",
            13: "패션",
        }
        category_name = category_map.get(product.Category_ID)
        if not category_name:
            raise HTTPException(
                status_code=400, detail="유효하지 않은 카테고리 ID입니다."
            )
        # Firebase Storage에 이미지 업로드 (주석 처리)
        # bucket = storage.bucket()
        # image_data = base64.b64decode(product.base64_image)
        # blob = bucket.blob(f"{category_name}/{product.name}.jpg")
        # blob.upload_from_string(image_data, content_type="image/jpeg")
        # blob.make_public()
        # image_url = blob.public_url
        # 임시로 base64 문자열을 이미지 URL로 사용
        image_url = f"local://{category_name}/{product.name}.jpg"
        cursor.execute(
            """
            INSERT INTO products (Category_ID, name, preview_image, price, detail, manufacturer, created)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """,
            (
                product.Category_ID,
                product.name,
                image_url,
                product.price,
                product.detail,
                product.manufacturer,
            ),
        )
        mysql_conn.commit()
        return {"message": "Product registered successfully", "image_url": image_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"상품 등록 실패: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        if mysql_conn:
            mysql_conn.close()


@router_product.get("/product_select_all")
async def select_all_products():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "select P.preview_image, P.Product_ID, P.name, C.name, P.created, P.price "
        "from products as P, category as C "
        "where C.Category_ID = P.Category_ID and P.Product_ID >= 430"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_product.get("/product_update")
async def update_product(Product_ID: int, Category_ID: int, name: str, price: float):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = "update products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
        cursor.execute(sql, (Category_ID, name, price, Product_ID))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error"}
    finally:
        conn.close()


@router_product.get("/delete")
async def delete_product(Product_ID: int):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = "delete from products where Product_ID = %s"
        cursor.execute(sql, (Product_ID,))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error"}
    finally:
        conn.close()


@router_product.post("/update_all_products")
async def update_all_products(product: ProductUpdateRequest):
    try:
        mysql_conn = connect_to_mysql()
        cursor = mysql_conn.cursor()
        category_map = {
            4: "가구",
            5: "기타",
            6: "도서",
            7: "미디어",
            8: "뷰티",
            9: "스포츠",
            10: "식품_음료",
            11: "유아_애완",
            12: "전자제품",
            13: "패션",
        }
        category_name = category_map.get(product.Category_ID)
        if not category_name:
            raise HTTPException(
                status_code=400, detail="유효하지 않은 카테고리 ID입니다."
            )
        # Firebase Storage에 이미지 업로드 (주석 처리)
        # bucket = storage.bucket()
        # image_data = base64.b64decode(product.base64_image)
        # blob = bucket.blob(f"{category_name}/{product.name}.jpg")
        # blob.upload_from_string(image_data, content_type="image/jpeg")
        # blob.make_public()
        # image_url = blob.public_url
        image_url = f"local://{category_name}/{product.name}.jpg"
        cursor.execute(
            """
            update products set Category_ID = %s, name = %s, preview_image = %s, price = %s where Product_ID = %s
            """,
            (
                product.Category_ID,
                product.name,
                image_url,
                product.price,
                product.Product_ID,
            ),
        )
        mysql_conn.commit()
        return {"message": "Product updated successfully", "image_url": image_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"상품 수정 실패: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        if mysql_conn:
            mysql_conn.close()


@router_product.get("/get_products_by_category")
async def get_products_by_category(category_id: int):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
        SELECT 
            P.Product_ID, 
            P.name, 
            P.preview_image, 
            P.price, 
            P.detail, 
            C.Category_ID,
            C.name AS category,
            P.created
        FROM products AS P
        INNER JOIN category AS C ON C.Category_ID = P.Category_ID
        WHERE C.Category_ID = %s
        """
        cursor.execute(sql, (category_id,))
        rows = cursor.fetchall()
        return {"results": rows}
    except Exception as e:
        raise HTTPException(status_code=500, detail="카테고리별 상품 조회 실패")
    finally:
        cursor.close()
        conn.close()


@router_product.get("/get_product/{product_id}")
async def get_product(product_id: int):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
        SELECT 
            P.Product_ID, 
            P.name, 
            P.preview_image, 
            P.price, 
            P.detail, 
            C.name AS category,
            P.created
        FROM products AS P
        INNER JOIN category AS C ON C.Category_ID = P.Category_ID
        WHERE P.Product_ID = %s
        """
        cursor.execute(sql, (product_id,))
        product = cursor.fetchone()
        if not product:
            raise HTTPException(status_code=404, detail="상품을 찾을 수 없습니다.")
        return {"result": product}
    except Exception as e:
        raise HTTPException(status_code=500, detail="상품 조회 실패")
    finally:
        cursor.close()
        conn.close()


@router_product.get("/mlplus")
async def mlplus(order_id: int):
    # 머신러닝 테스트 예제
    def text_to_number(text):
        hash_object = hashlib.md5(text.encode("utf-8"))
        return int(hash_object.hexdigest(), 16)

    loaded_rf = joblib.load("best_random_forest_model.pkl")
    seller_id_parser = pd.read_csv("seller_id_parser.csv", index_col=0)
    train = pd.read_csv("time_train.csv", index_col=0)
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    sql = f"""
        select *
        from orders as o
        JOIN products p ON p.Product_ID = o.Product_ID
        WHERE o.order_id = {order_id}
        """
    cursor.execute(sql)
    orders = cursor.fetchall()
    conn.close()
    dist_idx = text_to_number(orders[0]["Address"]) % train.shape[0]
    dist = train["dist"].iloc[dist_idx]
    product_id = orders[0]["Product_ID"]
    raw_price = orders[0]["price"]
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = """
        SELECT
            AVG(price) AS avg_price,
            STDDEV(price) AS std_price
        FROM products;
    """
    cursor.execute(sql)
    av_std_rows = cursor.fetchall()
    conn.close()
    your_mean = 1756.1477912569826
    your_std = 3908.8645767822213
    your_min = 5.2
    our_mean = av_std_rows[0][0]
    our_std = av_std_rows[0][1]
    price = max(((raw_price - our_mean) / our_std * your_std) + your_mean, your_min)
    customer_city_mean = train["customer_city_mean"].iloc[dist_idx]
    seller_id_mean = seller_id_parser.loc["6edacfd9f9074789dad6d62ba7950b9c"].item()
    pred = pd.DataFrame(
        {
            "price": [price],
            "dist": [dist],
            "seller_id_mean": [seller_id_mean],
            "customer_city_mean": [customer_city_mean],
        }
    )
    pred_result = loaded_rf.predict(pred).item()
    result_date = orders[0]["Order_Date"] + timedelta(pred_result + 1)
    return {"results": result_date}


# -------------------------------------------------
# Dashboard Router (통계, 차트 등)
# -------------------------------------------------
router_dashboard = APIRouter()


@router_dashboard.get("/user_recent_select")
async def user_recent_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select * from users order by Creation_date desc limit 5"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_recent_select")
async def order_recent_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT O.Order_ID, O.Product_seq, P.name, P.price, O.Order_date, "
        "O.payment_method, O.Order_state FROM orders as O, products as P, users as U "
        "where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID "
        "order by O.Order_date desc, O.Order_ID desc, O.Product_seq asc limit 3"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/total_orders")
async def total_orders():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "SELECT count(*) count FROM orders WHERE refund_time is null and Order_state != 'Return_Requested'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/total_orders_amount")
async def total_orders_amount():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT SUM(P.price) FROM orders AS O, products AS P "
        "WHERE O.Product_ID = P.Product_ID AND O.Order_state NOT IN ('Refund', 'Return_Requested')"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_payment_completed")
async def order_payment_completed():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select count(*) as total from orders where Order_State = 'Payment_completed'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_preparing_for_delivery")
async def order_preparing_for_delivery():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select count(*) as total from orders where Order_State = 'Preparing_for_delivery'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_in_delivery")
async def order_in_delivery():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select count(*) as total from orders where Order_State = 'In_delivery'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_delivered")
async def order_delivered():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select count(*) as total from orders where Order_State = 'Delivered'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/order_refund")
async def order_refund():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "select count(*) as total from orders where Order_State = 'Refund' or Order_State = 'Return_Requested'"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/orders_chart")
async def orders_chart():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT DATE(Order_Date) AS order_date, COUNT(*) AS order_count "
        "FROM orders where Order_Date is not null GROUP BY DATE(Order_Date) ORDER BY order_date"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_dashboard.get("/hub_chart")
async def hub_chart():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT H.name as name, sum(S.QTY) as total_QTY "
        "FROM stocktransfer as S, hubs as H WHERE H.Hub_ID = S.Hub_ID GROUP BY name ORDER BY name"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


# -------------------------------------------------
# Inventory Router (재고 관련 API)
# -------------------------------------------------
router_inventory = APIRouter()


@router_inventory.get("/inventory_1_select")
async def inventory_1_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "select S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason "
        "from stocktransfer as S, products as P "
        "where S.Hub_ID = 1 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/inventory_total_1_select")
async def inventory_total_1_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT S.Product_ID, P.name, sum(S.QTY) as Total "
        "FROM stocktransfer as S, products as P "
        "where S.Hub_ID = 1 and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/inventory_2_select")
async def inventory_2_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "select S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason "
        "from stocktransfer as S, products as P "
        "where S.Hub_ID = 2 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/inventory_total_2_select")
async def inventory_total_2_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT S.Product_ID, P.name, sum(S.QTY) as Total "
        "FROM stocktransfer as S, products as P "
        "where S.Hub_ID = 2 and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/inventory_3_select")
async def inventory_3_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "select S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason "
        "from stocktransfer as S, products as P "
        "where S.Hub_ID = 3 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/inventory_total_3_select")
async def inventory_total_3_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT S.Product_ID, P.name, sum(S.QTY) as Total "
        "FROM stocktransfer as S, products as P "
        "where S.Hub_ID = 3 and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_inventory.get("/hub_qty_update")
async def hub_qty_update(Product_ID: int, QTY: int):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = "update stocktransfer set QTY = %s where Product_ID = %s"
        cursor.execute(sql, (QTY, Product_ID))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error"}
    finally:
        conn.close()


# -------------------------------------------------
# Orders Router (주문 관련 API)
# -------------------------------------------------
router_orders = APIRouter()


class OrderItem(BaseModel):
    Product_ID: int
    quantity: int  # 주문 상품 개수


class OrderRequest(BaseModel):
    User_ID: str
    Address: str
    payment_method: str
    Order_state: str = "Payment_completed"
    products: list[OrderItem]


@router_orders.get("/order_select")
async def order_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = (
        "SELECT O.Order_ID, O.Product_seq, O.User_ID, P.name, P.price, O.Order_date, "
        "O.Address, O.refund_demands_time, O.refund_time, O.payment_method, O.Arrival_Time, O.Order_state "
        "FROM orders as O, products as P, users as U where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID"
    )
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_orders.post("/create_order")
async def create_order(order: OrderRequest):
    try:
        order_data = order.dict()
        mysql_conn = connect_to_mysql()
        cursor = mysql_conn.cursor()
        # 각 주문 상품이 존재하는지 확인
        for product in order.products:
            cursor.execute(
                "SELECT 1 FROM products WHERE Product_ID = %s", (product["Product_ID"],)
            )
            if not cursor.fetchone():
                raise HTTPException(
                    status_code=400,
                    detail=f"Product_ID {product['Product_ID']} does not exist",
                )
        sql_order = "SELECT Order_ID FROM orders ORDER BY Order_ID DESC LIMIT 1"
        cursor.execute(sql_order)
        last_order = cursor.fetchone()
        order_id = (last_order[0] + 1) if last_order else 1
        sql_product = """
        INSERT INTO orders (Order_ID, Product_seq, User_ID, Product_ID, Address, payment_method, Order_state)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        product_seq = 1
        for product in order.products:
            for _ in range(product["quantity"]):
                values_product = (
                    order_id,
                    product_seq,
                    order.User_ID,
                    product["Product_ID"],
                    order.Address,
                    order.payment_method,
                    order.Order_state,
                )
                cursor.execute(sql_product, values_product)
                product_seq += 1
        mysql_conn.commit()
        return {"message": "Order created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        mysql_conn.close()


@router_orders.get("/norefund_orders_update")
async def norefund_orders_update(
    Arrival_Time: str, Order_state: str, Order_ID: int, Product_seq: int
):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = """
        UPDATE orders 
        SET Arrival_Time = NULLIF(%s, ''), Order_state = %s 
        WHERE Order_ID = %s AND Product_seq = %s
        """
        cursor.execute(sql, (Arrival_Time, Order_state, Order_ID, Product_seq))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error"}
    finally:
        conn.close()


@router_orders.get("/refund_orders_update")
async def refund_orders_update(
    refund_time: str, Order_state: str, Order_ID: int, Product_seq: int
):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = """
        UPDATE orders 
        SET refund_time = NULLIF(%s, ''), Order_state = %s 
        WHERE Order_ID = %s AND Product_seq = %s
        """
        cursor.execute(sql, (refund_time, Order_state, Order_ID, Product_seq))
        conn.commit()
        return {"results": "OK"}
    except Exception as e:
        return {"results": "Error", "error": str(e)}
    finally:
        conn.close()


@router_orders.get("/{user_id}")
async def get_user_orders(user_id: str):
    conn = connect_to_mysql()
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
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_orders.get("/refunds/{user_id}")
async def get_refund_exchange_orders(user_id: str):
    conn = connect_to_mysql()
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
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_orders.put("/{order_id}/requestRefund")
async def request_refund(order_id: int):
    conn = connect_to_mysql()
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
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error.")
    finally:
        conn.close()


# -------------------------------------------------
# Review Router (리뷰 관련 API)
# -------------------------------------------------
router_review = APIRouter()


@router_review.get("/get_reviews/{product_id}")
async def get_reviews(product_id: int):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
        SELECT 
            r.ReviewSeq,
            r.User_ID,
            r.Product_ID,
            r.Review_Content,
            r.Star,
            p.name AS product_name
        FROM reviews AS r
        INNER JOIN products AS p ON r.Product_ID = p.Product_ID
        WHERE r.Product_ID = %s
        """
        cursor.execute(sql, (product_id,))
        reviews = cursor.fetchall()
        if not reviews:
            raise HTTPException(status_code=404, detail="리뷰를 찾을 수 없습니다.")
        return {"reviews": reviews}
    except Exception as e:
        raise HTTPException(status_code=500, detail="리뷰 정보를 불러오는 중 오류 발생")
    finally:
        cursor.close()
        conn.close()


@router_review.get("/reviews/{user_id}")
async def get_user_reviews(user_id: str):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            SELECT r.ReviewSeq,
                   r.User_ID,
                   r.Product_ID,
                   r.Review_Content,
                   r.Star,
                   p.name AS product_name
            FROM reviews r
            JOIN products p ON r.Product_ID = p.Product_ID
            WHERE r.User_ID = %s
            ORDER BY r.ReviewSeq DESC
        """
        cursor.execute(sql, (user_id,))
        reviews = cursor.fetchall()
        return reviews
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_review.post("/reviews")
async def add_review(review: dict):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            INSERT INTO reviews (User_ID, Product_ID, Review_Content, Star)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(
            sql,
            (
                review["User_ID"],
                review["Product_ID"],
                review["Review_Content"],
                review["Star"],
            ),
        )
        conn.commit()
        return {"message": "리뷰가 등록되었습니다."}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_review.put("/reviews/{review_id}")
async def update_review(review_id: int, review: dict):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            UPDATE reviews
            SET Review_Content = %s,
                Star = %s
            WHERE ReviewSeq = %s
        """
        cursor.execute(sql, (review["Review_Content"], review["Star"], review_id))
        conn.commit()
        return {"message": "리뷰가 수정되었습니다."}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_review.delete("/reviews/{review_id}")
async def delete_review(review_id: int):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = "DELETE FROM reviews WHERE ReviewSeq = %s"
        cursor.execute(sql, (review_id,))
        conn.commit()
        return {"message": "리뷰가 삭제되었습니다."}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


# -------------------------------------------------
# User Router (사용자 관련 API) - Firebase/Redis 관련 부분 제거
# -------------------------------------------------
router_user = APIRouter()


class User(BaseModel):
    User_ID: str | None = None
    auth_provider: str
    name: str
    email: str
    address: str = ""


@router_user.post("/login")
async def user_login(request: Request):
    data = await request.json()
    email = data.get("email")
    name = data.get("name")
    login_type = data.get("login_type")
    if not email:
        raise HTTPException(status_code=400, detail="email이 누락되었습니다.")
    if login_type not in ["apple", "google"]:
        raise HTTPException(status_code=400, detail="지원되지 않는 로그인 유형입니다.")
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor()
    try:
        query = "SELECT User_Id, email, name, auth_provider, address, Creation_date FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        user = cursor.fetchone()
        if user:
            user_data = {
                "User_Id": user[0],
                "email": user[1],
                "name": user[2],
                "auth_provider": user[3],
                "address": user[4],
                "Creation_date": (
                    user[5].strftime("%Y-%m-%d %H:%M:%S") if user[5] else None
                ),
            }
            return {"source": "mysql", "user_data": user_data}
        insert_query = """
        INSERT INTO users (email, name, auth_provider, address, Creation_date)
        VALUES (%s, %s, %s, %s, NOW())
        """
        cursor.execute(insert_query, (email, name, login_type, ""))
        mysql_conn.commit()
        user_id = cursor.lastrowid
        user_data = {
            "User_Id": user_id,
            "email": email,
            "name": name,
            "auth_provider": login_type,
            "address": "",
            "Creation_date": None,
        }
        return {"source": "mysql", "user_data": user_data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        mysql_conn.close()


@router_user.get("/user_select")
async def user_select():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    sql = "SELECT * FROM users"
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return {"results": rows}


@router_user.post("/users")
async def add_user(user: User):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM users WHERE User_ID = %s", (user.User_ID,))
        existing_user = cursor.fetchone()
        if existing_user:
            return {"message": "User already exists."}
        sql = "INSERT INTO users (User_ID, auth_provider, name, email, address) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(
            sql, (user.User_ID, user.auth_provider, user.name, user.email, user.address)
        )
        conn.commit()
        return {"message": "User successfully added."}
    except Exception as e:
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router_user.get("/users/{user_id}")
async def get_user(user_id: str):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM users WHERE User_ID = %s", (user_id,))
        user = cursor.fetchone()
        if not user:
            raise HTTPException(status_code=404, detail="User not found.")
        return {
            "User_Id": user[0],
            "email": user[1],
            "name": user[2],
            "auth_provider": user[3],
            "address": user[4],
            "Creation_date": user[5].strftime("%Y-%m-%d %H:%M:%S") if user[5] else None,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


# -------------------------------------------------
# FastAPI 앱 설정 및 라우터 등록
# -------------------------------------------------
app = FastAPI()

# 로컬 개발용 CORS 설정 (전체 오리진 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "message": "The server is running fine!",
        "uptime": "100%",
    }


@app.get("/get_all_products")
async def get_all_products(id: str = "apple-987654321"):

    import random
    import pandas as pd

    import os

    current_directory = os.getcwd()
    print("현재 디렉토리:", current_directory)

    corr_matrix = pd.read_csv("category.csv", index_col=0)

    """
    📌 추천상품 불러오기 api
    - 유저의 활동 내역을 기반으로(없으면 전체 주문을 기반으로) 자동으로 상품을 추천해줌
    - 먼저 id를 통해 이전 구매중 가장 많이 구매한 Category를 가져오고 (1번 sql)
    - 머신러닝을 통해 가져온 corr_matrix에서 관련있는 카테고리 총 10개를 가져옴(2번 과정, 카테고리는 중복 가능)
    - 관련 카테고리들 중에서 리뷰 많은 순으로 10개를 랜덤으로 가져옴(3번 과정)
    Returns:
    - `results`: 상품 목록 (JSON)
    """
    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # ✅ DictCursor 사용 (딕셔너리 변환)

    # id = 'apple-987654321' ### 시험용

    #### 2번과정에 쓸 카테고리 랜덤추출용 함수
    def recommend_maker(input_category):
        column = input_category
        positive_columns = corr_matrix[
            (corr_matrix[column] > 0) & (corr_matrix[column] != 1.0)
        ][column]
        positive_columns = corr_matrix[(corr_matrix[column] > 0)][column]
        category_cumsum = (
            (positive_columns / positive_columns.sum()).sort_values().cumsum()
        )

        num = random.random()
        for idx, value in enumerate(category_cumsum):
            if num < value:
                output_category = category_cumsum.index[idx]
                break

        return output_category

    ### 1번 과정 : ifnull을 통해서 내가, 혹은 남들이 가장 많이 산 카테고리를 가져옴
    try:
        sql = f"""
        SELECT IFNULL(
            (SELECT P.Category_ID
            FROM orders AS O
            INNER JOIN products AS P ON P.Product_ID = O.Product_ID
            WHERE User_id = "{id}"
            ORDER BY O.Order_date DESC
            LIMIT 1),
            
            (WITH CategoryCounts AS (
                SELECT P.Category_ID, COUNT(*) AS count
                FROM orders AS O
                INNER JOIN products AS P ON P.Product_ID = O.Product_ID
                GROUP BY P.Category_ID
            )
            SELECT Category_ID
            FROM CategoryCounts
            WHERE count = (SELECT MAX(count) FROM CategoryCounts)
            LIMIT 1)  -- 여러 개일 경우 하나만 반환
        ) AS Category_ID
        """

        curs.execute(sql)
        my_category = curs.fetchall()[0]["Category_ID"]

    except Exception as e:
        print(f"❌ 카테고리 가져오기 실패: {e}")

    finally:
        curs.close()
        conn.close()

    #### 2번과정 : 머신러닝을 통해 얻은 상관관계도를 통해서 관련있는 카테고리 10개 임의추출
    recommend_dict = {}

    for i in range(10):
        my_column = str(my_category)
        column = recommend_maker(my_column)
        if column not in recommend_dict.keys():
            recommend_dict[column] = 1
        else:
            recommend_dict[column] += 1

    # value를 기준으로 내림차순 정렬
    sorted_keys = sorted(recommend_dict, key=recommend_dict.get, reverse=True)

    #### 3번과정 : 2번을 통해 얻은 카테고리만큼의 갯수의 랜덤상품을 리뷰 많은 순으로 정리
    sqls = []
    for key in sorted_keys:
        temp_sql = f"""
        (SELECT 
            P.Product_ID AS Product_ID , 
            P.name AS name, 
            P.preview_image AS preview_image, 
            P.price AS price, 
            P.detail AS detail, 
            C.name AS category,
            P.created AS created,
            COUNT(R.Product_ID) AS review_count
        FROM products AS P
        INNER JOIN category AS C ON C.Category_ID = P.Category_ID
        INNER JOIN reviews AS R ON R.Product_ID = P.Product_ID
        WHERE P.Category_ID = {key}
        GROUP BY P.Product_ID
        ORDER BY COUNT(R.Product_ID) DESC, RAND()
        LIMIT {recommend_dict[key]})
        """
        sqls.append(temp_sql)

    sql1 = """
        SELECT 
            Product_ID,
            name,
            preview_image,
            price,
            detail,
            category,
            created
        FROM (\n"""
    sql2 = "\nUNION ALL\n".join(sqls)
    sql3 = ") AS CombinedResults\nORDER BY review_count DESC, RAND()"

    sql = sql1 + sql2 + sql3

    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # ✅ DictCursor 사용 (딕셔너리 변환)
    try:

        curs.execute(sql)
        rows = curs.fetchall()
        return {"results": rows}

    except Exception as e:
        print(f"❌ 상품 조회 실패: {e}")

    finally:
        curs.close()
        conn.close()  # ✅ DB 연결 종료 보장






# 각 기능별 Router 포함 (prefix 및 tags 지정)
app.include_router(router_address, tags=["Address"])
app.include_router(router_product, tags=["Products"])
app.include_router(router_dashboard, prefix="/dashboard", tags=["Dashboard"])
app.include_router(router_inventory, prefix="/inventories", tags=["Inventories"])
app.include_router(router_orders, prefix="/orders", tags=["Orders"])
app.include_router(router_review, tags=["Reviews"])
app.include_router(router_user, tags=["Users"])

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
