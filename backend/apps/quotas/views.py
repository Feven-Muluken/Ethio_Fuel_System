from rest_framework import permissions, viewsets

from .models import Quota
from .serializers import QuotaSerializer


class QuotaViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = QuotaSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ["vehicle__plate_number"]

    def get_queryset(self):
        return Quota.objects.filter(vehicle__owner=self.request.user).select_related("vehicle")
