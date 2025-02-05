# Dockerfile 설명!
## 1. FROM python:3.12-slim
    # python 3.12가 설치된 가벼운(슬림) 버전의 Linux를 사용하겠다는 뜻
    # 이 줄은 Python을 미리 설치해둔 컴퓨터(이미지)를 사용해서 시작할거야! 라고 생각하면 됨
## 2. WORKDIR/SumartPick
    # /SumartPick이라는 폴더를 만들고, 그 안에서 작업을 하겠다는 뜻
    # 컴퓨터에서 특정 폴더를 정해두고 모든 작업을 그 안에서 하는 것처럼 생각하면 됨
## 3. COPY ./fastapi ./fastapi
    # 내 컴퓨터에 있는 Develop 폴더를 컨테이너 안으로 복사하겠다는 뜻
    # 즉, 이 폴더를 컨테이너(작업공간)로 가져가! 라고 하는 것
## 4. WORKDIR /SUmartPick/fastapi
    # 이제 컨테이너 안의 /SumartPick/fastapi 폴더를 작업 폴더로 사용하겠다는 뜻
    # 이전에 정한 /SumartPick 안으로 들어가서, 더 구체적인 폴더에서 작업을 시작하는 것
## 5. COPY ./fastapi/requirements.txt ./requirements.txt
    # 내 컴퓨터에 있는 requirements.txt 파일을 컨테이너 안으로 복사하겠다는 뜻
    # 이 파일은 “이 앱을 실행하려면 이 프로그램들이 필요해!“라고 알려주는 파일 => 패키지 버전 맞춰주기
## 6. RUN pip install --no-cache-dir -r requirements.txt
    # 컨테이너 안에서 Python의 **pip**라는 도구를 사용해서, **requirements.txt**에 적힌 프로그램들을 설치하겠다는 뜻
    # 즉, 앱을 실행하는 데 필요한 프로그램들을 다운로드해서 설치하는 작업..

FROM python:3.12-slim

# Set the working directory
WORKDIR /SUmartPick

# Copy the application folder
COPY ./fastapi ./fastapi

# Set the working directory for the app
WORKDIR /SUmartPick/fastapi

# Install dependencies
COPY ./fastapi/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt && rm -rf /root/.cache/pip

# Expose the port the app runs on
EXPOSE 6003

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "6003"]
