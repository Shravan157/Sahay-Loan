from fastapi import APIRouter
from app.api.endpoints import auth, user, admin, provider, common, payments, provider_documents

api_router = APIRouter()

# Public/Common routes
api_router.include_router(common.router, tags=["common"])
api_router.include_router(auth.router, tags=["auth"])

# User routes
api_router.include_router(user.router, tags=["user"])

# Payment routes
api_router.include_router(payments.router, tags=["payments"])

# Admin routes
api_router.include_router(admin.router, prefix="/sahay-admin", tags=["admin"])

# Provider routes
api_router.include_router(provider.router, prefix="/provider-admin", tags=["provider"])
api_router.include_router(provider_documents.router, prefix="/provider-documents", tags=["provider-documents"])
