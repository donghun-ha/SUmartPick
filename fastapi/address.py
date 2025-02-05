from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from hosts import connect_to_mysql  # 기존 MySQL 연결 함수 재활용

router = APIRouter()


# 업데이트 요청 데이터 모델
class UpdateAddressRequest(BaseModel):
    user_id: str  # 사용자 식별자
    address: str  # 변경할 주소


# 주소 업데이트 엔드포인트 (HTTP PUT)
@router.put("/update_address")
async def update_address(req: UpdateAddressRequest):
    conn = connect_to_mysql()  # 기존 연결 함수 사용
    cursor = conn.cursor()
    try:
        # users 테이블의 address 컬럼 업데이트
        sql = "UPDATE users SET address = %s WHERE User_ID = %s"
        cursor.execute(sql, (req.address, req.user_id))
        conn.commit()

        # 업데이트된 행이 없으면 해당 사용자가 없다고 판단
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="User not found")

        return {"message": "Address updated successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error occurred: {e}")
    finally:
        cursor.close()
        conn.close()
