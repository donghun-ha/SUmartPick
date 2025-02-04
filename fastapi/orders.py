from fastapi import APIRouter
import pymysql
import hosts

router = APIRouter()

@router.get("/order_select")
async def select():
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()
    # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
    sql = "SELECT O.Order_ID, O.Product_seq, O.User_ID, P.name, P.price, O.Order_date, O.Address, O.refund_demands_time, O.refund_time, O.payment_method, O.Arrival_Time, O.Order_state FROM orders as O, products as P, users as U where P.Product_ID = O.Product_ID and O.User_ID = U.User_ID"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    print(rows)
    # 데이터가 많을때 쓰는 방법
    return {'results' : rows}

@router.post("/order/create")
async def create_order(user_id: str, address: str, payment_method: str):
    conn = hosts.connect_to_mysql()
    curs = conn.cursor()

    # ✅ 장바구니 정보 가져오기
    cart_sql = "SELECT Product_ID, QTY FROM cart WHERE User_ID = %s"
    curs.execute(cart_sql, (user_id,))
    cart_items = curs.fetchall()

    if not cart_items:
        raise HTTPException(status_code=400, detail="장바구니가 비어 있습니다.")

    # ✅ 주문 저장
    for item in cart_items:
        order_sql = """
            INSERT INTO orders (Product_ID, User_ID, Address, payment_method, Order_state)
            VALUES (%s, %s, %s, %s, '주문완료')
        """
        curs.execute(order_sql, (item['Product_ID'], user_id, address, payment_method))

    # ✅ 장바구니 비우기
    delete_sql = "DELETE FROM cart WHERE User_ID = %s"
    curs.execute(delete_sql, (user_id,))

    conn.commit()
    conn.close()

    return {"message": "주문이 성공적으로 완료되었습니다."}
