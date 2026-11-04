from django.urls import path, include

urlpatterns = [
    path('', include('apps.authentication.presentation.urls')),
]