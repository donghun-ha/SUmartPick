# from fastapi import APIRouter
# import pymysql

# router = APIRouter()

# def connection():
#     # Database 주소는 192.168.50.71
#     conn = pymysql.connect(
#         host='192.168.50.71',
#         user='sumartpick',
#         password='qwer1234',
#         db='SUmartPick',
#         charset='utf8'
#     )
#     return conn

# @router.get("/product_select")
# async def select():
#     conn = connection()
#     curs = conn.cursor()
#     # 결과값을 딕셔너리로 변환할때 쓰이는 SQL문장
#     # 지금 적혀있는건 더미값을 제외한 값을 출력하는 문장이다. 더미값을 지우면 >=430을 지워야 함
#     sql = "select P.preview_image, P.Product_ID, P.name, C.name, P.created, P.price from Products as P, Categories as C where C.Category_ID = P.Category_ID and P.Product_ID >= 430"
#     curs.execute(sql)
#     rows = curs.fetchall()
#     conn.close()
#     # 데이터가 많을때 쓰는 방법
#     return {'results' : rows}

# @router.get("/product_update")
# async def update(Product_ID: int, Category_ID: int, name: str, price: float):
#     conn = connection()
#     curs = conn.cursor()

#     try:
#         sql = "update Products set Category_ID = %s, name = %s, price = %s where Product_ID = %s"
#         curs.execute(sql, (Category_ID, name, price, Product_ID))
#         conn.commit()
#         conn.close()
#         return {'results' : 'OK'}
#     except Exception as e:
#         conn.close()
#         print("Error :", e)
#         return {'results' : 'Error'}