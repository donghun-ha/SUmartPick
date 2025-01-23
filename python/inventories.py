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

# -------------1번허브---------------
@router.get("/inventory_1_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select  S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason from StockTransfer as S, Products as P where S.Hub_ID = 1 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/inventory_total_1_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT S.Product_ID, P.name, sum(S.QTY)as Total FROM StockTransfer as S, Products as P where S.Hub_ID = 1  and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

# -------------2번허브---------------
@router.get("/inventory_2_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select  S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason from StockTransfer as S, Products as P where S.Hub_ID = 2 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/inventory_total_2_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT S.Product_ID, P.name, sum(S.QTY)as Total FROM StockTransfer as S, Products as P where S.Hub_ID = 2  and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

# -------------3번허브---------------
@router.get("/inventory_3_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "select  S.Timestamp, S.Product_ID, P.name, S.QTY, S.reason from StockTransfer as S, Products as P where S.Hub_ID = 3 and S.Product_ID = P.Product_ID order by S.Timestamp DESC"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.get("/inventory_total_3_select")
async def select():
    conn = connection()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT S.Product_ID, P.name, sum(S.QTY)as Total FROM StockTransfer as S, Products as P where S.Hub_ID = 3  and S.Product_ID = P.Product_ID group by S.Product_ID order by S.Product_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}