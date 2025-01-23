"""
Author : 하동훈
Description : 
상품 검색 Query문 작성
Usage: FastAPI를 사용하여 MySQL에서 상품 이름을 기준으로 검색
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from hosts import connect_to_mysql

# FastAPI 라우터 생성
router = APIRouter()


# 요청 데이터 모델
class ProductQuery(BaseModel):
    """
    상품 검색 요청 파라미터 모델:
    - name (str): 검색하려는 상품 이름 (부분 검색 가능)
    """
    name: str


# 응답 데이터 모델
class ProductResponse(BaseModel):
    """
    상품 검색 응답 모델:
    - product_id (int): 상품 ID
    - category_id (int): 카테고리 ID
    - name (str): 상품 이름
    - price (float): 상품 가격
    - detail (str): 상품 설명
    - manufacturer (str): 제조사
    - created (str): 상품 생성일
    """
    product_id: int
    category_id: int
    name: str
    price: float
    detail: str
    manufacturer: str
    created: str


@router.post("/products_query", response_model=List[ProductResponse])
async def products_query(query: ProductQuery):
    """
    상품 검색 요청 처리:
    1. 사용자가 입력한 상품 이름(name)에 따라 MySQL에서 상품 검색
    2. 검색된 결과를 반환

    Parameters:
    - query (ProductQuery): 사용자가 입력한 검색 조건 (상품 이름)

    Returns:
    - products (List[ProductResponse]): 검색된 상품 리스트
    """
    if not query.name:
        raise HTTPException(status_code=400, detail="상품 이름이 누락되었습니다.")

    # MySQL 연결
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor(dictionary=True)  # 결과를 딕셔너리 형태로 반환

    try:
        # 상품 이름으로 검색
        sql_query = """
        SELECT Product_ID, Category_ID, name, price, detail, manufacturer, created 
        FROM Products 
        WHERE name LIKE %s
        """
        params = [f"%{query.name}%"]  # 부분 검색

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