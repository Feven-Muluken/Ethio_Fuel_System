from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    national_id = models.CharField(max_length=32, unique=True)
    phone_number = models.CharField(max_length=20, blank=True)
    is_station_operator = models.BooleanField(default=False)
    is_regulator = models.BooleanField(default=False)

    def __str__(self) -> str:
        return f"{self.username} ({self.national_id})"
