import os
from redis.asyncio import Redis
import pymysql
from fastapi import HTTPException
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

# Redis 환경 변수
REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))
REDIS_PASSWORD = os.getenv('REDIS_PASSWORD', '')

# MySQL 환경 변수
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_NAME = os.getenv('DB_NAME')
DB_PORT = int(os.getenv('DB_PORT', 3306))

# Redis 연결 객체
redis_client = None


async def get_redis_connection():
    """
    Redis 연결 초기화 및 기존 연결 반환
    """
    global redis_client
    if not redis_client:
        try:
            redis_client = Redis(
                host="sumartpick-cache-server-001.upovzz.ng.0001.apn2.cache.amazonaws.com",
                port=6379,
                decode_responses=True  # 문자열 디코딩 활성화
            )
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
    try:
        conn = pymysql.connect(
            host="192.168.50.71",
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=3306,
            charset='utf8mb4'
        )
        print("MySQL 연결 성공")
        return conn
    except Exception as e:
        print(f"MySQL 연결 실패: {e}")
        raise e
