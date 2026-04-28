from django.conf import settings
from django.db import models


class Station(models.Model):
    name = models.CharField(max_length=120)
    code = models.CharField(max_length=32, unique=True)
    location = models.CharField(max_length=255)
    operator = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return self.name
