from django.db.models import Sum
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.transactions.models import Transaction


class SummaryReportView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        total_liters = Transaction.objects.filter(status="approved").aggregate(total=Sum("liters"))["total"] or 0
        total_tx = Transaction.objects.count()
        return Response({
            "total_transactions": total_tx,
            "total_liters_distributed": total_liters,
        })
