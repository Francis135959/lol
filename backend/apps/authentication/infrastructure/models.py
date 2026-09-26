from django.db import models
from django.contrib.auth import get_user_model

# Obtenemos el modelo de usuario activo en Django (soporta User por defecto o Custom User)
UserModel = get_user_model()


class UserProfile(models.Model):
    """Extensión de datos adicionales del usuario para el negocio"""
    user = models.OneToOneField(UserModel, on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=20, blank=True, null=True, verbose_name="Teléfono")
    rut = models.CharField(max_length=12, blank=True, null=True, unique=True, verbose_name="RUT")

    def __str__(self):
        return f"Perfil de {self.user.username}"