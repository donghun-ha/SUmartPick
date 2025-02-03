from fastapi import APIRouter
import pymysql
import hosts

router = APIRouter()

conn = hosts.connect_to_mysql() # MySQL 연동

@router.get("/user_recent_select")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select * from users order by Creation_date desc limit 5"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/order_recent_select")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT O.Order_ID, O.Product_seq, P.name, P.price, O.Order_date, O.payment_method, O.Order_state FROM orders as O, products as P, users as U where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID order by O.Order_ID asc, O.Order_state desc limit 3"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}