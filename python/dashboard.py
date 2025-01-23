from fastapi import APIRouter
import pymysql

router = APIRouter()

def connection():
    # Database 주소는 192.168.50.71
    conn = pymysql.connect(
        host='192.168.50.71',
        user='sumartpick',
        password='qwer1234',
        db='SUmartPick',
        charset='utf8'
    )
    return conn