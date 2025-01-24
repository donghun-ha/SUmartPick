"""
author: "하동훈"
Description: FASTAPI 연동
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from user import router as user_router
from product import router as product_router
from orders import router as orders_router
from inventories import router as inventories_router
from dashboard import router as dashboard_router

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

app.include_router(user_router, tags=["Users"])
app.include_router(product_router, tags=["Products"])
app.include_router(orders_router, prefix="/orders", tags=["orders"])
app.include_router(inventories_router, prefix="/inventories", tags=["inventories"])
app.include_router(dashboard_router, prefix="/dashboard", tags=["dashboard"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
