from fastapi import APIRouter
import pymysql
import hosts

router = APIRouter()

conn = hosts.connect_to_mysql()  # MySQL 연동


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
    return {"results": rows}


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
    return {"results": rows}


# 총 주문수
@router.get("/total_orders")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT count(*) count FROM orders WHERE refund_time is null and Order_state != 'Return_Requested'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 총 주문액
@router.get("/total_orders_amount")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT SUM(P.price) FROM orders AS O, products AS P WHERE O.Product_ID = P.Product_ID AND O.Order_state NOT IN ('Refund', 'Return_Requested')"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 결제완료
@router.get("/order_payment_completed")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select count(*) as total from orders where Order_State = 'Payment_completed'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 배송준비
@router.get("/order_preparing_for_delivery")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select count(*) as total from orders where Order_State = 'Preparing_for_delivery'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 배송중
@router.get("/order_in_delivery")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select count(*) as total from orders where Order_State = 'In_delivery'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 배송완료
@router.get("/order_delivered")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select count(*) as total from orders where Order_State = 'Delivered'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}


# 환불건수
@router.get("/order_refund")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select count(*) as total from orders where Order_State = 'Refund' or Order_State = 'Return_Requested'"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/orders_chart")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT DATE(Order_Date) AS order_date, COUNT(*) AS order_count FROM orders where Order_Date is not null GROUP BY DATE(Order_Date) ORDER BY order_date"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/hub_chart")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT H.name as name, sum(S.QTY) as total_QTY FROM stocktransfer as S, hubs as H  WHERE H.Hub_ID = S.Hub_ID GROUP BY name ORDER BY name"
    # sql = "select * from student"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {"results": rows}
