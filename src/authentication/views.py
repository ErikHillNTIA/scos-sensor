from __future__ import absolute_import

from rest_framework.generics import get_object_or_404
from rest_framework.generics import (
    ListAPIView, ListCreateAPIView, RetrieveAPIView,
    RetrieveUpdateDestroyAPIView)
from rest_framework.permissions import IsAdminUser
from rest_framework.settings import api_settings
from rest_framework.views import APIView

from .models import User
from .serializers import UserProfileSerializer, UserDetailsSerializer


class UserListView(APIView):
    """Information on users.

    Post is only available to admin users. The fields `email`, `server_url`,
    `auth_token`, `has_usable_password`, and `is_admin` are only visible to
    admin users. For more information on user fields, see Django's
    documentation on custom user models.

    """

    def dispatch(self, request, *args, **kwargs):
        if request.user.is_staff:
            return UserDetailsListView.as_view()(request, *args, **kwargs)
        else:
            return UserProfilesListView.as_view()(request, *args, **kwargs)


class UserDetailsListView(ListCreateAPIView):
    """View user details and create users."""
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserDetailsSerializer
    permission_classes = api_settings.DEFAULT_PERMISSION_CLASSES + [
        IsAdminUser,
    ]


class UserProfilesListView(ListAPIView):
    """View public profiles of all registered users."""
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserProfileSerializer


class UserInstanceView(APIView):
    def dispatch(self, request, *args, **kwargs):
        kwargs.pop('version', None)
        if not kwargs:  # /users/me
            kwargs = {'pk': request.user.pk}

        requested_user = get_object_or_404(User.objects.all(), **kwargs)
        if request.user.is_staff or request.user == requested_user:
            return UserDetailsView.as_view()(request, *args, **kwargs)
        else:
            return UserProfileView.as_view()(request, *args, **kwargs)


class UserDetailsView(RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserDetailsSerializer


class UserProfileView(RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserProfileSerializer
