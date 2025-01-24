"""
Author : 하동훈
Date : 2025-01-24
Description : 
이 모듈은 FastAPI를 사용하여 상품 검색 및 등록 API를 제공합니다.
- /products_query: MySQL 데이터베이스에서 상품 이름으로 검색하는 API
- /products/: 상품 데이터를 MySQL에 등록하는 API

Usage:
1. /products_query:
   - 상품 이름으로 검색 요청
   - Request: {"name": "상품명"}
   - Response: 상품 목록 리스트

2. /products/:
   - 상품 등록 요청
   - Request: {"Category_ID": 1, "name": "상품명", "preview_image": "URL", "price": 1000, "detail": "상세 설명", "manufacturer": "제조사"}
   - Response: {"message": "Product registered successfully"}
"""

from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from typing import List
from hosts import connect_to_mysql
import pymysql

# FastAPI 라우터 생성
router = APIRouter()

# 요청 데이터 모델
class ProductQuery(BaseModel):
    name: str  # 상품 이름 (필수)

# 응답 데이터 모델
class ProductResponse(BaseModel):
    Product_ID: int
    Category_ID: int
    name: str
    preview_image: str
    price: float
    detail: str
    manufacturer: str
    created: str

# 등록 데이터 모델
class ProductCreateRequest(BaseModel):
    Category_ID: int  # 카테고리 ID
    name: str         # 상품 이름
    preview_image: str  # Firebase 이미지 URL
    price: float
    detail: str
    manufacturer: str


@router.post("/products_query", response_model=List[ProductResponse])
async def products_query(query: ProductQuery):
    """
    상품 검색 요청 처리:
    1. 입력받은 상품 이름을 기준으로 MySQL에서 검색
    2. 검색된 결과를 반환

    Parameters:
    - query (ProductQuery): 상품 이름

    Returns:
    - List[ProductResponse]: 검색된 상품 리스트
    """
    if not query.name:
        raise HTTPException(status_code=400, detail="상품 이름이 누락되었습니다.")

    # MySQL 연결
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor(pymysql.cursors.DictCursor)  # DictCursor 사용

    try:
        # SQL 쿼리 작성
        sql_query = """
        SELECT Product_ID, Category_ID, name, preview_image ,price, detail, manufacturer, created 
        FROM products 
        WHERE name LIKE %s
        """
        params = [f"%{query.name}%"]
        print(params)

        # 쿼리 실행
        cursor.execute(sql_query, params)
        products = cursor.fetchall()

        # 결과 반환
        return products

    except Exception as e:
        # 에러 처리
        print(f"MySQL 쿼리 실패: {e}")
        raise HTTPException(status_code=500, detail="MySQL 작업 실패")

    finally:
        # MySQL 연결 닫기
        cursor.close()
        mysql_conn.close()

@router.post("/products/")
async def create_product(product: ProductCreateRequest):
    """
    상품 등록 요청 처리:
    1. 입력받은 상품 데이터를 MySQL에 저장
    2. 성공 메시지 반환

    Parameters:
    - product (ProductCreateRequest): 상품 데이터

    Returns:
    - dict: 성공 메시지
    """
    # MySQL 연결
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor()

    # MySQL 데이터베이스 삽입
    try:
        cursor.execute(
            """
            INSERT INTO products (Category_ID, name, preview_image, price, detail, manufacturer, created)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """,
            (product.Category_ID, product.name, product.preview_image, product.price, product.detail, product.manufacturer)
        )
        mysql_conn.commit()
        return {"message": "Product registered successfully"}

    except Exception as e:
        # 에러 처리
        print(f"MySQL 쿼리 실패: {e}")
        raise HTTPException(status_code=500, detail=f"MySQL 작업 실패: {str(e)}")

    finally:
        # MySQL 연결 닫기
        cursor.close()
        mysql_conn.close()