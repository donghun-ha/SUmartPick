# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from users import router as users_router
# from products import router as products_router
# from fastapi.orders import router as orders_router
# from fastapi.dashboard import router as dashboard_router
# from fastapi.inventories import router as inventories_router

# app = FastAPI()

# # CORS 설정
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=['*'], # 모든 도메인 허용
#     allow_credentials=True,
#     allow_methods=['*'], # 모든 http 메서드 허용
#     allow_headers=['*'], # 모든 헤더 허용
#     expose_headers=["Authorization"],
# )

# app.include_router(users_router, prefix="/users", tags=["users"])
# app.include_router(products_router, prefix="/products", tags=["products"])
# app.include_router(orders_router, prefix="/orders", tags=["orders"])
# app.include_router(inventories_router, prefix="/inventories", tags=["inventories"])
# app.include_router(dashboard_router, prefix="/dashboard", tags=["dashboard"])


# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host = "127.0.0.1", port = 8000)