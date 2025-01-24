from fastapi import APIRouter
import pymysql
import hosts

router = APIRouter()

conn = hosts.connect_to_mysql() # MySQL 연동