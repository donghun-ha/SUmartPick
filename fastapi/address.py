from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import pymysql
import config
from hosts import connect_to_mysql

router = APIRouter()


class Address(BaseModel):
    Address_ID: int | None = None
    User_ID: str
    address: str
    address_detail: str | None = None
    postal_code: str | None = None
    recipient_name: str | None = None
    phone: str | None = None
    is_default: bool | None = False




@router.get("/addresses/{user_id}")
async def get_addresses(user_id: str):
    conn = connect_to_mysql()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = """
            SELECT * FROM UserAddresses
            WHERE User_ID = %s
            ORDER BY is_default DESC, Address_ID DESC
        """
        cursor.execute(sql, (user_id,))
        rows = cursor.fetchall()

        for row in rows:
            # MySQL tinyint(1) -> Python int(0/1) -> 수동 변환
            # row["is_default"] 가 0 또는 1이라면 bool(...)로 변환
            if "is_default" in row and row["is_default"] in (0, 1):
                row["is_default"] = bool(row["is_default"])

        return rows
    except pymysql.MySQLError as e:
        ...
    finally:
        conn.close()


@router.post("/addresses")
async def create_address(address: Address):
    """
    새 주소 등록
    """
    conn = connect_to_mysql()
    cursor = conn.cursor()

    try:
        # 만약 is_default = True 로 등록하면,
        # 기존 주소들의 is_default를 False로 만들어줄 수도 있음 (1개의 주소만 기본)
        if address.is_default:
            cursor.execute(
                "UPDATE UserAddresses SET is_default = FALSE WHERE User_ID = %s",
                (address.User_ID,),
            )

        sql = """
            INSERT INTO UserAddresses 
            (User_ID, address, address_detail, postal_code, recipient_name, phone, is_default)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(
            sql,
            (
                address.User_ID,
                address.address,
                address.address_detail,
                address.postal_code,
                address.recipient_name,
                address.phone,
                address.is_default,
            ),
        )
        conn.commit()
        return {"message": "Address created successfully."}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail="Database error")
    finally:
        conn.close()


@router.put("/addresses/{address_id}")
async def update_address(address_id: int, address: Address):
    """
    주소 정보 수정
    """
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        # 기본주소로 설정 시, 다른 주소들을 False 처리
        if address.is_default:
            cursor.execute(
                "UPDATE UserAddresses SET is_default = FALSE WHERE User_ID = %s",
                (address.User_ID,),
            )

        sql = """
            UPDATE UserAddresses
            SET address = %s,
                address_detail = %s,
                postal_code = %s,
                recipient_name = %s,
                phone = %s,
                is_default = %s
            WHERE Address_ID = %s
        """
        cursor.execute(
            sql,
            (
                address.address,
                address.address_detail,
                address.postal_code,
                address.recipient_name,
                address.phone,
                address.is_default,
                address_id,
            ),
        )
        conn.commit()
        return {"message": "Address updated successfully."}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail="Database error")
    finally:
        conn.close()


@router.delete("/addresses/{address_id}")
async def delete_address(address_id: int):
    """
    주소 삭제
    """
    conn = connect_to_mysql()
    cursor = conn.cursor()
    try:
        sql = "DELETE FROM UserAddresses WHERE Address_ID = %s"
        cursor.execute(sql, (address_id,))
        conn.commit()
        return {"message": "Address deleted successfully."}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail="Database error")
    finally:
        conn.close()
