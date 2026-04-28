from rest_framework import serializers

from .models import Quota


class QuotaSerializer(serializers.ModelSerializer):
    plate_number = serializers.CharField(source="vehicle.plate_number", read_only=True)

    class Meta:
        model = Quota
        fields = [
            "id",
            "vehicle",
            "plate_number",
            "daily_limit_liters",
            "weekly_limit_liters",
            "remaining_daily_liters",
            "remaining_weekly_liters",
            "updated_at",
        ]
