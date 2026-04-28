from rest_framework import permissions, viewsets

from .models import Vehicle
from .serializers import VehicleSerializer


class VehicleViewSet(viewsets.ModelViewSet):
    serializer_class = VehicleSerializer
    permission_classes = [permissions.IsAuthenticated]
    search_fields = ["plate_number"]
    filterset_fields = ["vehicle_type", "is_active"]

    def get_queryset(self):
        return Vehicle.objects.filter(owner=self.request.user).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
