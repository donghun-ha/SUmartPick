"""
Author : 하동훈
Date : 2025-01-24
Description : 
이 모듈은 FastAPI를 사용하여 상품 검색 및 등록 API를 제공합니다.
- /products_query: MySQL 데이터베이스에서 상품 이름으로 검색하는 API
- /insert_products/: 상품 데이터를 Firebase_Storage에 저장 후 URL과 나머지 정보를 MySQL에 등록하는 API

Usage:
1. /products_query:
   - 상품 이름으로 검색 요청
   - Request: {"name": "상품명"}
   - Response: 상품 목록 리스트

2. /insert_products/:
   - 상품 등록 요청
   - Request: {"Category_ID": 1, "name": "상품명", "preview_image": "URL", "price": 1000, "detail": "상세 설명", "manufacturer": "제조사"}
   - Response: {"message": "Product registered successfully"}
"""

from fastapi import APIRouter, HTTPException, Request, File, UploadFile
from pydantic import BaseModel
from typing import List

import pymysql.cursors
from hosts import connect_to_mysql
import pymysql
from firebase_admin import credentials, storage # firebase
import firebase_admin
import base64, os

# FastAPI 라우터 생성
router = APIRouter()


# Firebase Admin SDK 초기화
firebase_key_path = os.getenv("FIREBASE_KEY_PATH", "sumartpick-firebase-adminsdk-v701f-ad1da0148c.json")
cred = credentials.Certificate(firebase_key_path)  # Firebase 서비스 계정 키 경로
firebase_admin.initialize_app(cred, {
    'storageBucket': 'sumartpick.firebasestorage.app'  # Firebase Storage 버킷 이름
})

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
    base64_image: str  # Firebase 이미지 URL
    price: float
    detail: str
    manufacturer: str

class ProductUpdateRequest(BaseModel):
    Product_ID: int # 상품 ID
    Category_ID: int  # 카테고리 ID
    name: str         # 상품 이름
    base64_image: str  # Firebase 이미지 URL
    price: float


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

@router.post("/insert_products")
async def create_product(product: ProductCreateRequest):
    """
    상품 등록:
    1. Base64 이미지를 Firebase Storage에 업로드
    2. Firebase URL과 함께 상품 정보를 MySQL에 저장
    """
    try:
        mysql_conn = connect_to_mysql()
        cursor = mysql_conn.cursor()
        # 카테고리 매핑
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
            13: "패션"
        }

        # 카테고리 이름 가져오기
        category_name = category_map.get(product.Category_ID)
        if not category_name:
            raise HTTPException(status_code=400, detail="유효하지 않은 카테고리 ID입니다.")

        # Base64 이미지를 디코딩하여 Firebase Storage에 저장
        bucket = storage.bucket()
        image_data = base64.b64decode(product.base64_image)
        blob = bucket.blob(f"{category_name}/{product.name}.jpg")  # 카테고리 이름 사용
        blob.upload_from_string(image_data, content_type="image/jpeg")
        blob.make_public()
        image_url = blob.public_url

        # MySQL에 상품 데이터 저장

        cursor.execute(
            """
            INSERT INTO products (Category_ID, name, preview_image, price, detail, manufacturer, created)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """,
            (product.Category_ID, product.name, image_url, product.price, product.detail, product.manufacturer)
        )
        mysql_conn.commit()

        return {"message": "Product registered successfully", "image_url": image_url}

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=f"상품 등록 실패: {str(e)}")

    finally:
        if cursor:  # ✅ `None` 체크 후 close()
            cursor.close()
        if mysql_conn:  # ✅ `None` 체크 후 close()
            mysql_conn.close()

@router.get("/product_select_all")
async def select():
    conn = connect_to_mysql()
    curs = conn.cursor()
    """
    상품 전체 불러오기 router endpoint
    결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    지금 적혀있는건 더미값을 제외한 값을 출력하는 문장이다. 더미값을 지우면 >=430을 지워야 함
    """
    sql = "select P.preview_image, P.Product_ID, P.name, C.name, P.created, P.price from products as P, category as C where C.Category_ID = P.Category_ID and P.Product_ID >= 430"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

# 상품 update 기능
@router.get("/product_update")
async def update(Product_ID: int, Category_ID: int, name: str, price: float):
    conn = connect_to_mysql()
    curs = conn.cursor()

    try:
        sql = "update products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
        curs.execute(sql, (Category_ID, name, price, Product_ID))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results' : 'Error'}


@router.get("/get_all_products")
async def get_all_products(id :str = "apple-987654321"):

    import random
    import pandas as pd

    corr_matrix = pd.read_csv('../analysis/model/category.csv', index_col=0)

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
        positive_columns =  corr_matrix[(corr_matrix[column] > 0) & (corr_matrix[column] !=1.0) ][column]
        positive_columns =  corr_matrix[(corr_matrix[column] > 0)][column]
        category_cumsum =  (positive_columns/positive_columns.sum()).sort_values().cumsum()

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
        my_category = curs.fetchall()[0]['Category_ID']

        

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
            recommend_dict[column] +=1

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
    sql2 =  '\nUNION ALL\n'.join(sqls)
    sql3 = ") AS CombinedResults\nORDER BY review_count DESC, RAND()"

    sql = sql1 + sql2 + sql3 


    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # ✅ DictCursor 사용 (딕셔너리 변환)
    try:
        
        curs.execute(sql)
        rows = curs.fetchall()
        return {'results' : rows}

    except Exception as e:
        print(f"❌ 상품 조회 실패: {e}")

    finally:
        curs.close()
        conn.close()  # ✅ DB 연결 종료 보장

# 관리자 페이지 상품 삭제 기능
@router.get("/delete")
async def update(Product_ID: int=None):
    conn = connect_to_mysql()
    curs = conn.cursor()

    try:
        sql = "delete from products where Product_ID = %s"
        curs.execute(sql, (Product_ID))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results' : 'Error'}


# 상품 전체 업데이트 기능
@router.post("/update_all_products")
async def create_product(product: ProductUpdateRequest):
    """
    상품 등록(수정):
    1. Base64 이미지를 Firebase Storage에 업로드
    2. Firebase URL과 함께 상품 정보를 MySQL에 저장
    """
    try:
        mysql_conn = connect_to_mysql()
        cursor = mysql_conn.cursor()
        # 카테고리 매핑
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
            13: "패션"
        }

        # 카테고리 이름 가져오기
        category_name = category_map.get(product.Category_ID)
        if not category_name:
            raise HTTPException(status_code=400, detail="유효하지 않은 카테고리 ID입니다.")

        # Base64 이미지를 디코딩하여 Firebase Storage에 저장
        bucket = storage.bucket()
        image_data = base64.b64decode(product.base64_image)
        blob = bucket.blob(f"{category_name}/{product.name}.jpg")  # 카테고리 이름 사용
        blob.upload_from_string(image_data, content_type="image/jpeg")
        blob.make_public()
        image_url = blob.public_url

        # MySQL에 상품 데이터 저장

        cursor.execute(
            """
            update products set Category_ID = %s, name = %s, preview_image = %s, price = %s where Product_ID = %s
            """,
            (product.Category_ID, product.name, image_url, product.price, product.Product_ID)
        )
        mysql_conn.commit()

        return {"message": "Product registered successfully", "image_url": image_url}

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=f"상품 등록 실패: {str(e)}")

    finally:
        if cursor:  # ✅ `None` 체크 후 close()
            cursor.close()
        if mysql_conn:  # ✅ `None` 체크 후 close()
            mysql_conn.close()

@router.get("/get_products_by_category")
async def get_products_by_category(category_id: int):
    """
    📌 특정 카테고리에 속하는 상품 조회 API
    - `category_id`를 기반으로 해당 카테고리의 상품 목록을 반환
    - `products` 테이블과 `category` 테이블을 조인하여 `category` 필드를 명확하게 반환

    Parameters:
    - `category_id` (int): 조회할 카테고리 ID (예: 4 = "가구", 6 = "도서" 등)

    Returns:
    - `results`: 해당 카테고리의 상품 목록 (JSON)
    """
    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # ✅ DictCursor 사용 (딕셔너리 변환)

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

        curs.execute(sql, (category_id,))
        rows = curs.fetchall()

        return {"results": rows}  # ✅ JSON 응답 구조 유지

    except Exception as e:
        print(f"❌ 카테고리별 상품 조회 실패: {e}")
        raise HTTPException(status_code=500, detail="카테고리별 상품을 불러오는 중 오류 발생")

    finally:
        curs.close()
        conn.close()  # ✅ DB 연결 종료 보장

@router.get("/get_product/{product_id}")
async def get_product(product_id: int):
    """
    📌 특정 상품 조회 API
    - `product_id`를 기반으로 상품 정보를 가져옵니다.
    - `products` 테이블과 `category` 테이블을 조인하여 카테고리 이름을 반환합니다.

    Parameters:
    - product_id (int): 조회할 상품 ID

    Returns:
    - `result`: 상품 정보 (JSON)
    """
    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # ✅ DictCursor 사용 (딕셔너리 변환)

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
        
        curs.execute(sql, (product_id,))
        product = curs.fetchone()  # ✅ 단일 결과만 가져오기

        if not product:
            raise HTTPException(status_code=404, detail="상품을 찾을 수 없습니다.")

        return {"result": product}  # ✅ JSON 응답

    except Exception as e:
        print(f"❌ 상품 조회 실패: {e}")
        raise HTTPException(status_code=500, detail="상품 정보를 불러오는 중 오류 발생")

    finally:
        curs.close()
        conn.close()  # ✅ DB 연결 종료
