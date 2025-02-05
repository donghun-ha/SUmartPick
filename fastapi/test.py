# --*-- Coding: utf-8 --*--

from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pymysql
import os
import shutil
import config
import hosts


import pymysql
import pandas as pd
import hashlib
import joblib


app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_FOLDER = "uploads"
if not os.path.exists(UPLOAD_FOLDER):
    os.mkdir(UPLOAD_FOLDER)


# Database connection
def connect():
    db = config.get_db_config()
    try:
        conn = pymysql.connect(
            host=db["host"],
            user=db["user"],
            password=db["password"],
            database=db["database"],
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
        )
        return conn
    except pymysql.MySQLError as e:
        print(f"Database connection error: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")


# Pydantic 모델 정의
class User(BaseModel):
    User_ID: str
    auth_provider: str
    name: str
    email: str


class Product(BaseModel):
    Category_ID: int
    name: str
    preview_image: str
    price: float
    detail: str


# (1) 주소 관리를 위한 Pydantic 모델 (예시)
class Address(BaseModel):
    Address_ID: int | None = None
    User_ID: str
    address: str
    address_detail: str | None = None
    postal_code: str | None = None
    recipient_name: str | None = None
    phone: str | None = None
    is_default: bool | None = False


# @app.post("/upload")
# async def upload_file(file: UploadFile = File(...)):
#     # 업로드 처리
#     try:
#         file_path = os.path.join(UPLOAD_FOLDER, file.filename)
#         with open(file_path, "wb") as buffer:
#             shutil.copyfileobj(file.file, buffer)
#         return {"result": "OK"}
#     except Exception as ex:
#         print("Error", ex)
#         return {"result": "Error"}


# @app.delete("/deleteFile/{file_name}")
# async def delete_file(file_name: str):
#     # 파일 삭제 처리
#     try:
#         file_path = os.path.join(UPLOAD_FOLDER, file_name)
#         if os.path.exists(file_path):
#             os.remove(file_path)
#         return {"result": "OK"}
#     except Exception as ex:
#         print("Error:", ex)
#         return {"result": "Error"}

# ### 로그인
# @app.post("/users")
# async def add_user(user: User):
#     # 유저 추가
#     print(f"Received request: {user.dict()}")
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         cursor.execute("SELECT * FROM Users WHERE User_ID = %s", (user.User_ID,))
#         existing_user = cursor.fetchone()

#         if existing_user:
#             return {"message": "User already exists."}

#         sql = "INSERT INTO Users (User_ID, auth_provider, name, email) VALUES (%s, %s, %s, %s)"
#         cursor.execute(sql, (user.User_ID, user.auth_provider, user.name, user.email))
#         conn.commit()
#         return {"message": "User successfully added."}
#     except pymysql.MySQLError as ex:
#         print("Database error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()

# ### 로그인
# @app.get("/users/{user_id}")
# async def get_user(user_id: str):
#     # 유저 정보 조회
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         cursor.execute("SELECT * FROM Users WHERE User_ID = %s", (user_id,))
#         user = cursor.fetchone()

#         if not user:
#             raise HTTPException(status_code=404, detail="User not found.")

#         return user
#     except pymysql.MySQLError as ex:
#         print("Error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()


# @app.get("/products")
# async def get_products():
#     # 전체 상품 조회
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         cursor.execute("SELECT * FROM Products")
#         products = cursor.fetchall()
#         conn.close()
#         return products
#     except Exception as ex:
#         print("Error:", ex)
#         conn.close()
#         return {"result": "Error"}


# @app.post("/products")
# async def add_product(product: Product):
#     # 상품 추가
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         sql = "INSERT INTO Products (Category_ID, name, preview_image, price, detail) VALUES (%s, %s, %s, %s, %s)"
#         cursor.execute(
#             sql,
#             (
#                 product.Category_ID,
#                 product.name,
#                 product.preview_image,
#                 product.price,
#                 product.detail,
#             ),
#         )
#         conn.commit()
#         conn.close()
#         return {"result": "OK"}
#     except Exception as ex:
#         print("Error:", ex)
#         conn.close()
#         return {"result": "Error"}


# @app.get("/categories")
# async def get_categories():
#     # 카테고리 조회
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         cursor.execute("SELECT * FROM Categories")
#         categories = cursor.fetchall()
#         conn.close()
#         return categories
#     except Exception as ex:
#         print("Error:", ex)
#         conn.close()
#         return {"result": "Error"}


# @app.post("/categories")
# async def add_category(name: str):
#     # 카테고리 추가
#     conn = connect()
#     cursor = conn.cursor()

#     try:
#         sql = "INSERT INTO Categories (name) VALUES (%s)"
#         cursor.execute(sql, (name,))
#         conn.commit()
#         conn.close()
#         return {"result": "OK"}
#     except Exception as ex:
#         print("Error:", ex)
#         conn.close()
#         return {"result": "Error"}


# @app.get("/view/{file_name}")
# async def view(file_name: str):
#     # 이미지 파일 직접 보기
#     file_path = os.path.join(UPLOAD_FOLDER, file_name)
#     if os.path.exists(file_path):
#         return FileResponse(path=file_path, filename=file_name)
#     return {"result": "Error"}


#### 주문내역
@app.get("/orders/{user_id}")
async def get_user_orders(user_id: str):
    conn = connect()
    cursor = conn.cursor()
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
            FROM Orders o
            JOIN Products p ON o.Product_ID = p.Product_ID
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
@app.get("/orders/refunds/{user_id}")
async def get_refund_exchange_orders(user_id: str):
    conn = connect()
    cursor = conn.cursor()
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
            FROM Orders o
            JOIN Products p ON o.Product_ID = p.Product_ID
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


# 리뷰 조회: 특정 유저의 리뷰 목록을 가져오고, Product 테이블 join해서 상품명도 함께 반환
# @app.get("/reviews/{user_id}")
# async def get_user_reviews(user_id: str):
#     conn = connect()
#     cursor = conn.cursor()
#     try:
#         sql = """
#             SELECT r.ReviewSeq,
#                    r.User_ID,
#                    r.Product_ID,
#                    r.Review_Content,
#                    r.Star,
#                    p.name AS product_name
#             FROM Reviews r
#             JOIN Products p ON r.Product_ID = p.Product_ID
#             WHERE r.User_ID = %s
#             ORDER BY r.ReviewSeq DESC
#         """
#         cursor.execute(sql, (user_id,))
#         reviews = cursor.fetchall()
#         return reviews

#     except pymysql.MySQLError as ex:
#         print("Error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()

# # 리뷰 작성
# @app.post("/reviews")
# async def add_review(review: dict):
#     """
#     Body 예시:
#     {
#       "User_ID": "...",
#       "Product_ID": 123,
#       "Review_Content": "리뷰 내용",
#       "Star": 5
#     }
#     """
#     conn = connect()
#     cursor = conn.cursor()
#     try:
#         sql = """
#             INSERT INTO Reviews (User_ID, Product_ID, Review_Content, Star)
#             VALUES (%s, %s, %s, %s)
#         """
#         cursor.execute(
#             sql,
#             (
#                 review["User_ID"],
#                 review["Product_ID"],
#                 review["Review_Content"],
#                 review["Star"],
#             ),
#         )
#         conn.commit()
#         return {"message": "리뷰가 등록되었습니다."}
#     except pymysql.MySQLError as ex:
#         print("Error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()


# # 리뷰 수정
# @app.put("/reviews/{review_id}")
# async def update_review(review_id: int, review: dict):
#     """
#     Body 예시:
#     {
#       "Review_Content": "수정된 리뷰 내용",
#       "Star": 4
#     }
#     """
#     conn = connect()
#     cursor = conn.cursor()
#     try:
#         sql = """
#             UPDATE Reviews
#             SET Review_Content = %s,
#                 Star = %s
#             WHERE ReviewSeq = %s
#         """
#         cursor.execute(sql, (review["Review_Content"], review["Star"], review_id))
#         conn.commit()
#         return {"message": "리뷰가 수정되었습니다."}
#     except pymysql.MySQLError as ex:
#         print("Error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()


# # 리뷰 삭제
# @app.delete("/reviews/{review_id}")
# async def delete_review(review_id: int):
#     conn = connect()
#     cursor = conn.cursor()
#     try:
#         sql = "DELETE FROM Reviews WHERE ReviewSeq = %s"
#         cursor.execute(sql, (review_id,))
#         conn.commit()
#         return {"message": "리뷰가 삭제되었습니다."}
#     except pymysql.MySQLError as ex:
#         print("Error:", ex)
#         raise HTTPException(status_code=500, detail="Database error occurred.")
#     finally:
#         conn.close()
#########################


# (2) 주소 관련 CRUD
@app.get("/addresses/{user_id}")
async def get_addresses(user_id: str):
    conn = connect()
    cursor = conn.cursor()
    try:
        sql = """
            SELECT * FROM UserAddresses
            WHERE User_ID = %s
            ORDER BY is_default DESC, Address_ID DESC
        """
        cursor.execute(sql, (user_id,))
        rows = cursor.fetchall()

        for row in rows:
            if "is_default" in row and row["is_default"] in (0, 1):
                row["is_default"] = bool(row["is_default"])

        return rows
    except pymysql.MySQLError as e:
        ...
    finally:
        conn.close()


# 주소 관리
###############---###############---###############---###############---###############---###############---


@app.post("/addresses")
async def create_address(address: Address):
    """
    새 주소 등록
    """
    conn = connect()
    cursor = conn.cursor()
    try:
        if address.is_default:
            # 기존 기본주소들 is_default = False
            cursor.execute(
                "UPDATE UserAddresses SET is_default = FALSE WHERE User_ID = %s",
                (address.User_ID,),
            )

        sql = """
            INSERT INTO UserAddresses 
            (User_ID, address, address_detail, postal_code, recipient_name, phone, is_default)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(
            sql,
            (
                address.User_ID,
                address.address,
                address.address_detail,
                address.postal_code,
                address.recipient_name,
                address.phone,
                address.is_default,
            ),
        )
        conn.commit()
        return {"message": "Address created successfully."}
    except pymysql.MySQLError as e:
        print("Error:", e)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@app.put("/addresses/{address_id}")
async def update_address(address_id: int, address: Address):
    """
    주소 수정
    """
    conn = connect()
    cursor = conn.cursor()
    try:
        if address.is_default:
            # 새 주소를 기본으로 설정 시, 나머지 주소는 false 처리
            cursor.execute(
                "UPDATE UserAddresses SET is_default = FALSE WHERE User_ID = %s",
                (address.User_ID,),
            )

        sql = """
            UPDATE UserAddresses
            SET address = %s,
                address_detail = %s,
                postal_code = %s,
                recipient_name = %s,
                phone = %s,
                is_default = %s
            WHERE Address_ID = %s
        """
        cursor.execute(
            sql,
            (
                address.address,
                address.address_detail,
                address.postal_code,
                address.recipient_name,
                address.phone,
                address.is_default,
                address_id,
            ),
        )
        conn.commit()
        return {"message": "Address updated successfully."}
    except pymysql.MySQLError as e:
        print("Error:", e)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@app.delete("/addresses/{address_id}")
async def delete_address(address_id: int):
    """
    주소 삭제
    """
    conn = connect()
    cursor = conn.cursor()
    try:
        sql = "DELETE FROM UserAddresses WHERE Address_ID = %s"
        cursor.execute(sql, (address_id,))
        conn.commit()
        return {"message": "Address deleted successfully."}
    except pymysql.MySQLError as e:
        print("Error:", e)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


####################################---###############---###############---###############---###############---###############---###############---


#### 반품
@app.put("/orders/{order_id}/requestRefund")
async def request_refund(order_id: int):
    """
    예시: 반품 신청 처리
    """
    conn = connect()
    cursor = conn.cursor()
    try:
        sql = """
            UPDATE Orders
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
@app.get("/orders/{order_id}/track")
async def track_order(order_id: int):
    conn = connect()
    cursor = conn.cursor()
    try:
        sql = """
            SELECT Order_ID, TrackingNumber, Carrier, ShippingStatus
            FROM Orders
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


### 머신러닝 테스트
@app.get("/ml_test")
async def ml_test(order_id: int):
    """
    머신러닝 테스트용으로 만든 테스트에용
    """

    def text_to_number(text):
        hash_object = hashlib.md5(text.encode('utf-8'))  # MD5 해시 생성
        return int(hash_object.hexdigest(), 16)  # 16진수를 10진수 정수로 변환
    

    def connect():
        conn = pymysql.connect(
            host = "43.202.97.15", 
            user = "sumartpick",
            password = "qwer1234",
            db = "sumartpick",
            charset= 'utf8'
        )
        return conn

    import joblib
    loaded_rf = joblib.load('best_random_forest_model.pkl')

    seller_id_parser =  pd.read_csv('seller_id_parser.csv', index_col=0)
    train =  pd.read_csv('time_train.csv', index_col=0)


    conn = connect()
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


    dist_idx = text_to_number(orders[0]['Address']) % train.shape[0]
    dist = train['dist'].iloc[dist_idx]


    product_id = orders[0]['Product_ID']
    raw_price = orders[0]['price']

    conn = connect()
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


### 머신러닝 테스트
@app.get("/ml_test2")
async def ml_test2(order_id: int):
    from datetime import datetime
    return {
        'result' : datetime.now(),
    }

### 머신러닝 테스트
@app.get("/mltest")
async def mltest(order_id: int):
    return{'result' : order_id}



if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
