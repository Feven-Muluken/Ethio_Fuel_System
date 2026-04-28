from django.contrib.auth import get_user_model
from rest_framework import serializers

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "national_id", "phone_number", "is_station_operator", "is_regulator"]


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    is_station_operator = serializers.BooleanField(required=False, default=False)
    is_regulator = serializers.BooleanField(required=False, default=False)

    class Meta:
        model = User
        fields = [
            "username",
            "password",
            "national_id",
            "phone_number",
            "is_station_operator",
            "is_regulator",
        ]

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user
