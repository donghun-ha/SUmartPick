"""
Author : 하동훈
Description : 
상품 검색 Query문 작성
Usage: 상품 이름으로 MySQL에서 검색
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