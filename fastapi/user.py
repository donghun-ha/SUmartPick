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
        # MySQL에서 사용자 확인
        query = "SELECT User_Id, email, name, auth_provider, Creation_date FROM users WHERE email = %s"
        cursor.execute(query, (email,))
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

        # MySQL에 사용자 추가
        insert_query = """
        INSERT INTO users (email, name, auth_provider, Creation_date)
        VALUES (%s, %s, %s, NOW())
        """
        cursor.execute(insert_query, (email, name, login_type))
        mysql_conn.commit()

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
    return {'results' : rows}
