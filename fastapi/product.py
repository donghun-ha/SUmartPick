from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from hosts import connect_to_mysql

router = APIRouter()

class Product(BaseModel):
    Category_ID: int
    name: str
    preview_image: str
    price: float
    detail: str

@router.get("/products")
async def get_products():
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM products")
        products = cursor.fetchall()
        return products
    except Exception as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="제품 정보를 가져오는 중 오류 발생")
    finally:
        cursor.close()
        conn.close()

@router.post("/products")
async def add_product(product: Product):
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO products (Category_ID, name, preview_image, price, detail) VALUES (%s, %s, %s, %s, %s)",
            (product.Category_ID, product.name, product.preview_image, product.price, product.detail),
        )
        conn.commit()
        return {"message": "Product added successfully"}
    except Exception as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="제품 추가 중 오류 발생")
    finally:
        cursor.close()
        conn.close()
