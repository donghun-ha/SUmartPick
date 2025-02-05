import firebase_admin
from firebase_admin import credentials, storage
import mysql.connector

# Firebase Admin SDK 초기화
cred = credentials.Certificate("sumartpick-firebase-adminsdk-v701f-ad1da0148c.json")  # Firebase 서비스 계정 키 경로
firebase_admin.initialize_app(cred, {
    'storageBucket': 'sumartpick.firebasestorage.app'  # Firebase Storage 버킷 이름
})

# MySQL 연결 설정
db = mysql.connector.connect(
    host="192.168.50.71",          # MySQL 호스트
    user="sumartpick",      # MySQL 사용자 이름
    password="qwer1234",  # MySQL 비밀번호
    database="sumartpick"   # MySQL 데이터베이스 이름
)
cursor = db.cursor()

# Firebase Storage에서 파일 가져오기
bucket = storage.bucket()
blobs = bucket.list_blobs()  # Storage에 있는 모든 파일 가져오기

# 카테고리 매핑 로직
category_map = {
    "가구" : 4,
    "기타" : 5,
    "도서" : 6,
    "미디어" : 7,
    "뷰티" : 8,
    "스포츠" : 9,
    "식품_음료" : 10,
    "유아_애완" : 11,
    "전자제품" : 12,
    "패션" : 13
}

# MySQL에 데이터 삽입
for blob in blobs:
    # 경로 분석
    path_parts = blob.name.split('/')  # '/'로 경로 분리
    if len(path_parts) < 3:  # 카테고리, 하위 카테고리, 파일 이름이 없는 경우 건너뛰기
        continue

    category = path_parts[1]  # 첫 번째 카테고리
    file_name = path_parts[-1]  # 파일 이름
    public_url = blob.public_url  # 이미지 URL

    # Category_ID 매핑
    category_id = category_map.get(category, None)
    if not category_id:  # 매핑되지 않은 카테고리는 건너뛰기
        print(f"카테고리 '{category}'가 매핑되지 않았습니다. 건너뜁니다.")
        continue

    # MySQL 삽입
    try:
        cursor.execute(
            "INSERT INTO Products (Category_ID, name, preview_image) VALUES (%s, %s, %s)",
            (category_id, file_name, public_url)
        )
        print(f"저장 완료: 카테고리 {category}, 파일명 {file_name}, URL {public_url}")
    except Exception as e:
        print(f"오류 발생: {e}")

# 변경사항 저장 및 연결 종료
db.commit()
cursor.close()
db.close()

print("모든 이미지 URL과 카테고리 정보가 저장되었습니다!")