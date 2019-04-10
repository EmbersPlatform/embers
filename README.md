# Embers

> AVISO: La aplicación se encuentra en etapas tempranas de desarrollo y es INESTABLE

Embers está escrito en Elixir.

La capa web del sistema está basado en Phoenix Framework.

## Instalación

### Requisitos previos

- Base de datos PostgreSQL funcionando

### Backend

- Instalar las dependencias con `mix deps.get`
- Crear un archivo `config/ENV.secret.exs` y completar la configuración de acuerdo al entorno actual(ENV puede ser `dev`, `prod`, `test`), como las credenciales de la base de datos.
- Crear y migrar la base de datos con `mix ecto.create && mix ecto.migrate`. Si este paso falla, intentar con `mix ecto.reset`.
- Iniciar el servidor con `mix phx.server`, o `iex -S mix phx.server` para poder usar `iex`.

### Frontend

Los archivos estáticos(léase css, javascript, etc) se encuentran en el directorio `/static`.

Los archivos que deben ser compilados se encuentran en `/assets`. Los archivos ya compilados son enviados a `/priv/static`. Si hay archivos que no necesitan ser compilados, ponerlos en `/assets/static` ya que el directorio `/priv/static` es ignorado por git.

Para compilar el frontend:

- Instalar dependencias de Node.js con `cd assets && npm install`.
- Si se esta trabajando en Windows, instalar cross-env con `npm install cross-env`.
- Crear las carpetas `priv/static/css` y `priv/static/js`.
- Correr `mix embers.static` para mover los archivos estaticos en `assets/static` a `priv/static`.
- Compilar el frontend con `npm run dev`, o `npm run watch` para compilar cuando un archivo cambia.

Ahora se puede acceder a Embers entrando a [`localhost:4000`](http://localhost:4000) desde el buscador.

## Links adicionales

### Phoenix Framework

- Sitio oficial: <http://www.phoenixframework.org/>
- Guías: <http://phoenixframework.org/docs/overview>
- Documentación: <https://hexdocs.pm/phoenix>
