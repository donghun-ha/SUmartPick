from fastapi import APIRouter, HTTPException
from hosts import connect_to_mysql
import pymysql

router = APIRouter()


@router.get("/get_reviews/{product_id}")
async def get_reviews(product_id: int):
    """
    📋 특정 상품 리뷰 조회 API
    - `product_id`를 기반으로 해당 상품의 리뷰 목록을 가져옵니다.
    - `reviews` 테이블과 `products` 테이블을 조인하여 `product_name`을 반환합니다.

    🔍 Parameters:
    - product_id (int): 조회할 상품 ID

    📦 Returns:
    - `reviews`: 리뷰 목록 (JSON)
    """
    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor)

    try:
        # ✅ products 테이블과 조인하여 product_name을 가져오기
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

        curs.execute(sql, (product_id,))
        reviews = curs.fetchall()  # ✅ 여러 개의 리뷰 가져오기

        if not reviews:
            raise HTTPException(status_code=404, detail="리뷰를 찾을 수 없습니다.")

        return {"reviews": reviews}  # ✅ JSON 응답 반환

    except Exception as e:
        print(f"❌ 리뷰 조회 실패: {e}")
        raise HTTPException(status_code=500, detail="리뷰 정보를 불러오는 중 오류 발생")

    finally:
        curs.close()
        conn.close()  # ✅ DB 연결 종료 보장


# 리뷰 조회: 특정 유저의 리뷰 목록을 가져오고, Product 테이블 join해서 상품명도 함께 반환
@router.get("/reviews/{user_id}")
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

    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


# 리뷰 작성
@router.post("/reviews")
async def add_review(review: dict):
    """
    Body 예시:
    {
      "User_ID": "...",
      "Product_ID": 123,
      "Review_Content": "리뷰 내용",
      "Star": 5
    }
    """
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
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


# 리뷰 수정
@router.put("/reviews/{review_id}")
async def update_review(review_id: int, review: dict):
    """
    Body 예시:
    {
      "Review_Content": "수정된 리뷰 내용",
      "Star": 4
    }
    """
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
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


# 리뷰 삭제
@router.delete("/reviews/{review_id}")
async def delete_review(review_id: int):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = "DELETE FROM reviews WHERE ReviewSeq = %s"
        cursor.execute(sql, (review_id,))
        conn.commit()
        return {"message": "리뷰가 삭제되었습니다."}
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()
