"""API роуты"""

from .rates import router as rates_router
from .stats import router as stats_router
from .admin import router as admin_router

__all__ = ["rates_router", "stats_router", "admin_router"]
