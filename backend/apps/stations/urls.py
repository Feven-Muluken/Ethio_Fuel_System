from rest_framework.routers import DefaultRouter

from .views import StationViewSet

router = DefaultRouter()
router.register(r"", StationViewSet, basename="station")

urlpatterns = router.urls
