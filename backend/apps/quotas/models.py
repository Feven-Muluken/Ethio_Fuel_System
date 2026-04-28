from django.db import models

from apps.vehicles.models import Vehicle


class Quota(models.Model):
    vehicle = models.OneToOneField(Vehicle, on_delete=models.CASCADE, related_name="quota")
    daily_limit_liters = models.DecimalField(max_digits=8, decimal_places=2)
    weekly_limit_liters = models.DecimalField(max_digits=8, decimal_places=2)
    remaining_daily_liters = models.DecimalField(max_digits=8, decimal_places=2)
    remaining_weekly_liters = models.DecimalField(max_digits=8, decimal_places=2)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"Quota for {self.vehicle.plate_number}"
