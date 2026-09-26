from dataclasses import dataclass
from apps.authentication.domain.entities import UserEntity
from apps.authentication.domain.interfaces import IUserRepository
from apps.authentication.domain.exceptions import (
    InvalidCredentialsException,
    UserAlreadyExistsException,
)


@dataclass
class RegisterUserDTO:
    username: str
    email: str
    password: str
    first_name: str = ""
    last_name: str = ""


class RegisterUserUseCase:
    def __init__(self, user_repository: IUserRepository):
        self.user_repository = user_repository

    def execute(self, dto: RegisterUserDTO) -> UserEntity:
        if self.user_repository.get_by_email(dto.email):
            raise UserAlreadyExistsException("El correo electrónico ya está registrado.")

        if self.user_repository.get_by_username(dto.username):
            raise UserAlreadyExistsException("El nombre de usuario ya está registrado.")

        new_user = UserEntity(
            id=None,
            username=dto.username,
            email=dto.email,
            first_name=dto.first_name,
            last_name=dto.last_name,
        )
        return self.user_repository.create(new_user, dto.password)


class LoginUseCase:
    def __init__(self, user_repository: IUserRepository):
        self.user_repository = user_repository

    def execute(self, username_or_email: str, password: str) -> UserEntity:
        user = self.user_repository.verify_credentials(username_or_email, password)
        if not user:
            raise InvalidCredentialsException("Credenciales inválidas.")
        return user