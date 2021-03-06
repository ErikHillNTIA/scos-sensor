from rest_framework import permissions


class IsAdminOrOwnerOrReadOnly(permissions.BasePermission):
    """Only allow an admin or a result's owner to edit it."""

    def has_permission(self, request, view):
        user = request.user
        result = view.queryset.first()

        if result is None:
            return True

        if result.schedule_entry.is_private and not user.is_staff:
            return False

        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to the owner or an admin
        # or if the aquisition doesn't exists (leading to 404).
        if result.schedule_entry.owner == user:
            return True

        return user.is_staff

    def has_object_permission(self, request, view, obj):
        user = request.user

        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to the owner or an admin
        return obj.schedule_entry.owner == user or user.is_staff
