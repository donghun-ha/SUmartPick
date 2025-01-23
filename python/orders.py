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

@router.get("/order_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT O.Order_ID, O.Product_seq, O.User_ID, P.name, P.price, O.Order_date, O.Address, O.refund_demands_time, O.refund_time, O.payment_method, O.Arrival_Time, O.Order_state FROM Orders as O, Products as P, Users as U where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}