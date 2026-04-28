from rest_framework.routers import DefaultRouter

from .views import QuotaViewSet

router = DefaultRouter()
router.register(r"", QuotaViewSet, basename="quota")

urlpatterns = router.urls
