# Arquitectura del proyecto

## Estructura

Cada feature se organiza de la siguiente manera:

* presentation/ → UI, widgets y ViewModels
* domain/ → logica de negocio, entidades y casos de uso
* data/ → acceso a datos (API, DTOs, repositorios)

---

## Flujo que siguen los datos

UI → ViewModel → UseCase → Repository → DataSource → API

---

## Reglas

* La UI no accede directamente a servicios o APIs
* Los DTOs no se usan en la UI
* Cada feature es independiente

---
