"""
author: "하동훈"
Description: FASTAPI 연동
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from user import router as user_router
from product import router as product_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 허용할 도메인 리스트
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class HealthCheckResponse(BaseModel):
    status: str
    message: str
    uptime: str

@app.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """
    Health check endpoint
    """
    return {
        "status": "healthy",
        "message": "The server is running fine!",
        "uptime": "100%"  # Example additional info
    }

app.include_router(user_router, tags=["User Login"])
app.include_router(product_router, tags=["Products"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "0.0.0.0", port = 8000)