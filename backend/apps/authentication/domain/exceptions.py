class AuthException(Exception):
    """Excepción base del dominio de autenticación"""
    pass


class InvalidCredentialsException(AuthException):
    """Lanzada cuando el usuario o contraseña son incorrectos"""
    pass


class UserAlreadyExistsException(AuthException):
    """Lanzada al intentar registrar un email o username ya tomado"""
    pass


class UserNotFoundException(AuthException):
    """Lanzada cuando no se encuentra al usuario"""
    pass