from django.db import transaction as db_transaction
from rest_framework import permissions, viewsets

from apps.quotas.models import Quota

from .models import Transaction
from .serializers import TransactionSerializer


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ["vehicle__plate_number", "station__code", "status"]
    search_fields = ["vehicle__plate_number", "station__name"]

    def get_queryset(self):
        return (
            Transaction.objects
            .select_related("vehicle", "station")
            .filter(vehicle__owner=self.request.user)
            .order_by("-created_at")
        )

    @db_transaction.atomic
    def perform_create(self, serializer):
        tx = serializer.save(status="approved")
        quota = Quota.objects.select_for_update().get(vehicle=tx.vehicle)
        quota.remaining_daily_liters -= tx.liters
        quota.remaining_weekly_liters -= tx.liters
        quota.save(update_fields=["remaining_daily_liters", "remaining_weekly_liters", "updated_at"])
