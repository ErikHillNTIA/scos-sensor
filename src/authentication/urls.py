from django.urls import path

from .views import UserListView, UserInstanceView

urlpatterns = (
    path('', UserListView.as_view(), name='user-list'),
    path('me/', UserInstanceView.as_view(), name='user-detail'),
    path('<int:pk>/', UserInstanceView.as_view(), name='user-detail'),
)
