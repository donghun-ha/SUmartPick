import os
import pymysql
from redis.asyncio import Redis
from fastapi import HTTPException

# 환경 변수
DB_HOST = "192.168.50.71"
DB_USER = "sumartpick"
DB_PASSWORD = "qwer1234"
DB_NAME = "sumartpick"
REDIS_HOST = "sumartpick-cache-server-001.upovzz.ng.0001.apn2.cache.amazonaws.com"
REDIS_PORT = 6379

# MySQL 연결
def connect_to_mysql():
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
        )
        print("MySQL 연결 성공")
        return conn
    except pymysql.MySQLError as e:
        print(f"MySQL 연결 실패: {e}")
        raise HTTPException(status_code=500, detail="MySQL 연결 실패")

# Redis client 초기화
redis_client = None

# Redis 연결 함수
async def get_redis_connection():
    """
    Redis 연결 초기화 및 기존 연결 반환
    """
    global redis_client
    if not redis_client:
        try:
            print("Initializing Redis connection...")
            # Redis 클라이언트 생성
            redis_client = Redis(
                host='sumartpick-cache-server-001.upovzz.ng.0001.apn2.cache.amazonaws.com',
                port=REDIS_PORT,
                decode_responses=True  # 문자열 디코딩 활성화
            )
            # 연결 테스트
            await redis_client.ping()
            print("Redis 연결 성공")
        except Exception as e:
            print(f"Redis 연결 실패: {e}")
            redis_client = None
            raise e
    return redis_client



