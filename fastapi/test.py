# --*-- Coding: utf-8 --*--

from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pymysql
import os
import shutil
import config

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
    # config에서 DB 정보를 받아옴
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


@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    # 업로드 처리
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return {"result": "OK"}
    except Exception as ex:
        print("Error", ex)
        return {"result": "Error"}


@app.delete("/deleteFile/{file_name}")
async def delete_file(file_name: str):
    # 파일 삭제 처리
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {"result": "OK"}
    except Exception as ex:
        print("Error:", ex)
        return {"result": "Error"}


@app.post("/users")
async def add_user(user: User):
    # 유저 추가
    print(f"Received request: {user.dict()}")
    conn = connect()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM Users WHERE User_ID = %s", (user.User_ID,))
        existing_user = cursor.fetchone()

        if existing_user:
            return {"message": "User already exists."}

        sql = "INSERT INTO Users (User_ID, auth_provider, name, email) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (user.User_ID, user.auth_provider, user.name, user.email))
        conn.commit()
        return {"message": "User successfully added."}
    except pymysql.MySQLError as ex:
        print("Database error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@app.get("/users/{user_id}")
async def get_user(user_id: str):
    # 유저 정보 조회
    conn = connect()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM Users WHERE User_ID = %s", (user_id,))
        user = cursor.fetchone()

        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        return user
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@app.get("/products")
async def get_products():
    # 전체 상품 조회
    conn = connect()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM Products")
        products = cursor.fetchall()
        conn.close()
        return products
    except Exception as ex:
        print("Error:", ex)
        conn.close()
        return {"result": "Error"}


@app.post("/products")
async def add_product(product: Product):
    # 상품 추가
    conn = connect()
    cursor = conn.cursor()

    try:
        sql = "INSERT INTO Products (Category_ID, name, preview_image, price, detail) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(
            sql,
            (
                product.Category_ID,
                product.name,
                product.preview_image,
                product.price,
                product.detail,
            ),
        )
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as ex:
        print("Error:", ex)
        conn.close()
        return {"result": "Error"}


@app.get("/categories")
async def get_categories():
    # 카테고리 조회
    conn = connect()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM Categories")
        categories = cursor.fetchall()
        conn.close()
        return categories
    except Exception as ex:
        print("Error:", ex)
        conn.close()
        return {"result": "Error"}


@app.post("/categories")
async def add_category(name: str):
    # 카테고리 추가
    conn = connect()
    cursor = conn.cursor()

    try:
        sql = "INSERT INTO Categories (name) VALUES (%s)"
        cursor.execute(sql, (name,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as ex:
        print("Error:", ex)
        conn.close()
        return {"result": "Error"}


@app.get("/view/{file_name}")
async def view(file_name: str):
    # 이미지 파일 직접 보기
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {"result": "Error"}


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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
