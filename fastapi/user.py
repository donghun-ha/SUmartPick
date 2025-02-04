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
from pydantic import BaseModel
import pymysql


class User(BaseModel):
    User_ID: str
    auth_provider: str
    name: str
    email: str


# FastAPI 라우터 생성
router = APIRouter()


@router.post("/login")
async def user_login(request: Request):
    """
    사용자 로그인 요청 처리:
    1. Redis에서 사용자 데이터 검색
    2. Redis에 데이터가 없으면 MySQL에서 확인 후 추가
    3. Apple/Google 로그인 처리
    """
    data = await request.json()
    email = data.get("email")
    name = data.get("name")
    login_type = data.get("login_type")

    if not email:
        raise HTTPException(status_code=400, detail="email이 누락되었습니다.")
    if login_type not in ["apple", "google"]:
        raise HTTPException(status_code=400, detail="지원되지 않는 로그인 유형입니다.")

    # Redis 키 설정 (이메일 기반)
    redis_key = f"user:{email}"
    redis = await get_redis_connection()

    # Redis에서 데이터 검색
    cached_user = await redis.get(redis_key)
    if cached_user:
        user_data = json.loads(cached_user)
        print("Redis에서 사용자 데이터를 반환")
        return {"source": "redis", "user_data": user_data}

    # Redis에 데이터가 없을 경우 MySQL 확인
    mysql_conn = connect_to_mysql()
    cursor = mysql_conn.cursor()

    try:
        # MySQL에서 사용자 확인
        query = "SELECT User_Id, email, name, auth_provider, Creation_date FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        user = cursor.fetchone()

        if user:
            # MySQL 사용자 데이터를 반환
            user_data = {
                "User_Id": user[0],
                "email": user[1],
                "name": user[2],
                "auth_provider": user[3],
                "Creation_date": user[4].strftime("%Y-%m-%d %H:%M:%S"),
            }
            # Redis에 사용자 데이터 캐싱
            await redis.set(redis_key, json.dumps(user_data), ex=3600)  # 1시간 캐싱
            return {"source": "mysql", "user_data": user_data}

        # MySQL에 사용자 추가
        insert_query = """
        INSERT INTO users (email, name, auth_provider, Creation_date)
        VALUES (%s, %s, %s, NOW())
        """
        cursor.execute(insert_query, (email, name, login_type))
        mysql_conn.commit()

        user_id = cursor.lastrowid  # 새로 생성된 User_Id 가져오기
        user_data = {
            "User_Id": user_id,
            "email": email,
            "name": name,
            "auth_provider": login_type,
            "Creation_date": None,  # 새 사용자는 현재 Creation_date를 가져오지 않음
        }
        await redis.set(redis_key, json.dumps(user_data), ex=3600)
        return {"source": "mysql", "user_data": user_data}

    except Exception as e:
        print(f"MySQL 쿼리 실패: {e}")
        raise HTTPException(status_code=500, detail="MySQL 작업 실패")
    finally:
        cursor.close()
        mysql_conn.close()


@router.get("/user_select")
async def select():
    conn = connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT * FROM users"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


@router.post("/users")
async def add_user(user: User):
    # 유저 추가
    print(f"Received request: {user.dict()}")
    conn = connect_to_mysql()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM users WHERE User_ID = %s", (user.User_ID,))
        existing_user = cursor.fetchone()

        if existing_user:
            return {"message": "User already exists."}

        sql = "INSERT INTO users (User_ID, auth_provider, name, email) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (user.User_ID, user.auth_provider, user.name, user.email))
        conn.commit()
        return {"message": "User successfully added."}
    except pymysql.MySQLError as ex:
        print("Database error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()


@router.get("/users/{user_id}")
async def get_user(user_id: str):
    # 유저 정보 조회
    conn = connect_to_mysql()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM users WHERE User_ID = %s", (user_id,))
        user = cursor.fetchone()

        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        return user
    except pymysql.MySQLError as ex:
        print("Error:", ex)
        raise HTTPException(status_code=500, detail="Database error occurred.")
    finally:
        conn.close()
