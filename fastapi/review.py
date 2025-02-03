from fastapi import APIRouter, HTTPException
from hosts import connect_to_mysql
import pymysql

router = APIRouter()

@router.get("/get_reviews/{product_id}")
async def get_reviews(product_id: int):
    """
    📋 특정 상품 리뷰 조회 API
    - `product_id`를 기반으로 해당 상품의 리뷰 목록을 가져옵니다.
    - `reviews` 테이블에서 사용자 ID, 리뷰 내용, 별점 정보를 반환합니다.

    🔍 Parameters:
    - product_id (int): 조회할 상품 ID

    📦 Returns:
    - `reviews`: 리뷰 목록 (JSON)
    """
    conn = connect_to_mysql()
    curs = conn.cursor(pymysql.cursors.DictCursor) 

    try:
        sql = """
        SELECT 
            User_ID,
            Review_Content,
            Star
        FROM reviews
        WHERE Product_ID = %s
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
