from rest_framework import serializers

from apps.quotas.models import Quota

from .models import Transaction


class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = [
            "id",
            "vehicle",
            "station",
            "liters",
            "status",
            "rejection_reason",
            "created_at",
        ]
        read_only_fields = ["status", "rejection_reason", "created_at"]

    def validate(self, attrs):
        vehicle = attrs["vehicle"]
        liters = attrs["liters"]
        quota = Quota.objects.filter(vehicle=vehicle).first()
        if quota is None:
            raise serializers.ValidationError("No quota is configured for this vehicle.")
        if liters > quota.remaining_daily_liters or liters > quota.remaining_weekly_liters:
            raise serializers.ValidationError("Quota exceeded for this transaction.")
        return attrs
