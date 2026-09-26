from typing import Optional
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.models import AbstractBaseUser  # <- Agregar este import
from apps.authentication.domain.entities import UserEntity
from apps.authentication.domain.interfaces import IUserRepository

UserModel = get_user_model()


class DjangoUserRepository(IUserRepository):
    """Implementación concreta del repositorio usando Django ORM y Postgres"""

    def _to_entity(self, user_obj: AbstractBaseUser) -> UserEntity:
        return UserEntity(
            id=user_obj.id,
            username=user_obj.get_username(),
            email=getattr(user_obj, 'email', ''),
            first_name=getattr(user_obj, 'first_name', ''),
            last_name=getattr(user_obj, 'last_name', ''),
            is_active=user_obj.is_active,
            is_staff=getattr(user_obj, 'is_staff', False),
            date_joined=getattr(user_obj, 'date_joined', None),
        )