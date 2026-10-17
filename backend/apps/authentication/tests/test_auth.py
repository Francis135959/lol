from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.authentication.domain.entities import UserEntity
from apps.authentication.infrastructure.repositories import DjangoUserRepository

UserModel = get_user_model()


class DjangoUserRepositoryTestCase(TestCase):
    def setUp(self):
        self.repository = DjangoUserRepository()

    def test_create_and_verify_user(self):
        user_entity = UserEntity(
            id=None,
            username="testuser",
            email="test@example.com",
            first_name="Test",
            last_name="User",
        )
        created = self.repository.create(user_entity, "securepassword123")
        self.assertIsNotNone(created.id)
        self.assertEqual(created.username, "testuser")

        verified = self.repository.verify_credentials("testuser", "securepassword123")
        self.assertIsNotNone(verified)