from rest_framework import serializers

from .models import Vehicle


class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = ["id", "owner", "plate_number", "vehicle_type", "is_active", "created_at"]
        read_only_fields = ["owner", "created_at"]
