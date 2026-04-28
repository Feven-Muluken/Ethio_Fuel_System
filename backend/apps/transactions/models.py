from django.db import models

from apps.stations.models import Station
from apps.vehicles.models import Vehicle


class Transaction(models.Model):
    STATUS_CHOICES = [
        ("approved", "Approved"),
        ("rejected", "Rejected"),
    ]

    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name="transactions")
    station = models.ForeignKey(Station, on_delete=models.CASCADE, related_name="transactions")
    liters = models.DecimalField(max_digits=8, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="approved")
    rejection_reason = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"{self.vehicle.plate_number} @ {self.station.code}"
