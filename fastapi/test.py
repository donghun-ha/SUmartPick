# --*-- Coding: utf-8 --*--

from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pymysql
import os
import shutil

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
    try:
        conn = pymysql.connect(
            host="192.168.50.71",
            user="sumartpick",
            password="qwer1234",
            database="sumartpick",
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
    print(f"Received request: {user.dict()}")  # 요청 데이터 로그 출력

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
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {"result": "Error"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
