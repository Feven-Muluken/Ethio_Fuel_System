from django.contrib import admin
from django.urls import include, path
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class HealthView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({"status": "ok", "service": "ethio-fuel-pass-backend"})


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", HealthView.as_view(), name="health"),
    path("api/auth/", include("apps.accounts.urls")),
    path("api/vehicles/", include("apps.vehicles.urls")),
    path("api/quotas/", include("apps.quotas.urls")),
    path("api/transactions/", include("apps.transactions.urls")),
    path("api/stations/", include("apps.stations.urls")),
    path("api/reports/", include("apps.reporting.urls")),
]
