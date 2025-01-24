"""
Author : 이종남
Description : 
<사용자 로그인 처리 로직>
Apple/Google 로그인 데이터 기반으로 Redis와 MySQL을 연동하여 사용자 데이터를 관리,
Apple 로그인 시 이메일 가리기 로직 처리.
Usage: 로그인 시 캐싱을 통한 반환 및 MySQL Insert 처리
"""

from fastapi import APIRouter, HTTPException, Request
from hosts import get_redis_connection, connect_to_mysql
import json
from datetime import datetime

router = APIRouter()

@router.post("/login")
async def user_login(request: Request):
    try:
        data = await request.json()
        email = data.get("email")
        name = data.get("name")
        login_type = data.get("login_type")

        if not email:
            raise HTTPException(status_code=400, detail="email이 누락되었습니다.")
        if login_type not in ["apple", "google"]:
            raise HTTPException(status_code=400, detail="지원되지 않는 로그인 유형입니다.")

        redis_key = f"user:{email}"
        redis = await get_redis_connection()
        cached_user = await redis.get(redis_key)

        if cached_user:
            user_data = json.loads(cached_user)
            return {"source": "redis", "user_data": user_data}

        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user:
            user_data = {
                "User_Id": user["User_Id"],
                "email": user["email"],
                "name": user["name"],
                "auth_provider": user["auth_provider"],
                "Creation_date": user["Creation_date"].strftime('%Y-%m-%d %H:%M:%S'),
            }
            await redis.set(redis_key, json.dumps(user_data), ex=3600)
            return {"source": "mysql", "user_data": user_data}

        creation_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute(
            "INSERT INTO users (email, name, auth_provider, Creation_date) VALUES (%s, %s, %s, %s)",
            (email, name, login_type, creation_date),
        )
        conn.commit()

        user_data = {
            "User_Id": cursor.lastrowid,
            "email": email,
            "name": name,
            "auth_provider": login_type,
            "Creation_date": creation_date,
        }
        await redis.set(redis_key, json.dumps(user_data), ex=3600)

        return {"source": "mysql", "user_data": user_data}
    except Exception as e:
        print(f"에러 발생: {e}")
        raise HTTPException(status_code=500, detail="로그인 처리 중 오류가 발생했습니다.")
    finally:
        if "cursor" in locals():
            cursor.close()
        if "conn" in locals():
            conn.close()

@router.get("/test-mysql")
def test_mysql_connection():
    try:
        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute("SELECT NOW();")
        result = cursor.fetchone()
        return {"message": "MySQL 연결 성공", "current_time": result["NOW()"]}
    except Exception as e:
        return {"message": "MySQL 연결 실패", "error": str(e)}
    finally:
        if "cursor" in locals():
            cursor.close()
        if "conn" in locals():
            conn.close()

@router.get("/test-redis")
async def test_redis_connection():
    try:
        redis = await get_redis_connection()
        await redis.set("test_key", "test_value", ex=10)  # 테스트용 키 설정
        value = await redis.get("test_key")  # 설정한 키 가져오기
        return {"message": "Redis 연결 성공", "value": value}
    except Exception as e:
        return {"message": "Redis 연결 실패", "error": str(e)}


