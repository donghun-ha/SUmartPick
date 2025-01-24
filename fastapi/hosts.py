"""
환경 변수 설정
"""

from fastapi import HTTPException
import os
import pymysql 
from redis.asyncio import Redis

# 환경 변수에서 불러오기
AWS_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
REGION = os.getenv('REGION')
DB = os.getenv('SUMARTPICK_DB')
DB_USER = os.getenv('SUMARTPICK_DB_USER')
DB_PASSWORD = os.getenv('SUMARTPICK_DB_PASSWORD')
DB_TABLE = os.getenv('SUMARTPICK_DB_TABLE')
DB_PORT = os.getenv('SUMARTPICK_PORT')
REDIS_HOST = os.getenv('REDIS_HOST')
REDIS_PORT = os.getenv("REDIS_PORT")



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

def connect_to_mysql():
    """
    MySQL 데이터베이스 연결 및 반환
    """
    print(DB_USER)
    print(DB_PORT)
    try:
        conn = pymysql.connect(
            host=DB,
            user=DB_USER,
            password=DB_PASSWORD,
            charset='utf8',
            db=DB_TABLE,
            port=3306
        )
        print("MySQL 연결 성공")
        print(f"{conn.host, conn.user, conn.password, conn.db, conn.port}")
        return conn
    except Exception as e:
        print(f"MySQL 연결 실패: {e}")
        raise e