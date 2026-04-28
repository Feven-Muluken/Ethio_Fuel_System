from django.conf import settings
from django.db import models


class Vehicle(models.Model):
    VEHICLE_TYPES = [
        ("private", "Private"),
        ("taxi", "Taxi"),
        ("public", "Public Transport"),
        ("government", "Government"),
    ]

    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="vehicles")
    plate_number = models.CharField(max_length=20, unique=True)
    vehicle_type = models.CharField(max_length=20, choices=VEHICLE_TYPES)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return self.plate_number
