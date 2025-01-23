"""
Author : 하동훈
Description : 
상품 검색 Query문 작성
Usage: product를 MySQL select 문으로 검색
"""

from fastapi import APIRouter, HTTPException, Request
from hosts import connect_to_mysql
import json

# FastAPI 라우터 생성
router = APIRouter()

@router.post("/products_query")
async def products_query(request: Request):
    """
    상품 검색 요청 처리:
    1. 사용자가 입력한 조건에 따라 MySQL에서 상품 검색
    2. 검색된 결과 반환
    """
    data = await request.json()
    category_id = data.get("category_id")  # 카테고리 ID
    product_name = data.get("name")  # 상품 이름 (부분 검색 가능)

    if not category_id and not product_name:
        raise HTTPException(status_code=400, detail="검색 조건이 제공되지 않았습니다.")

    # MySQL 연결
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor(dictionary=True)  # 결과를 딕셔너리 형태로 반환

    try:
        # 검색 조건에 따른 쿼리 작성
        query = "SELECT * FROM Products WHERE 1=1"
        params = []

        if category_id:
            query += " AND Category_ID = %s"
            params.append(category_id)

        if product_name:
            query += " AND name LIKE %s"
            params.append(f"%{product_name}%")  # 부분 검색

        # 쿼리 실행
        cursor.execute(query, params)
        products = cursor.fetchall()

        # 결과 반환
        return {"products": products}

    except Exception as e:
        print(f"MySQL 쿼리 실패: {e}")
        raise HTTPException(status_code=500, detail="MySQL 작업 실패")
    finally:
        cursor.close()
        mysql_conn.close()