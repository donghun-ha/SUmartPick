"""
author: "하동훈"
Description: FASTAPI 연동
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from user import router as user_router
from product import router as product_router

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "The server is running fine!", "uptime": "100%"}

# 라우터 추가
app.include_router(user_router, tags=["user"])
app.include_router(product_router, tags=["product"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
