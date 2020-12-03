# Embers

> AVISO: La aplicación se encuentra en etapas tempranas de desarrollo y es INESTABLE

Embers está escrito en Elixir.

La capa web del sistema está basado en Phoenix Framework.

## Instalación

### Requisitos previos

- [Elixir](https://elixir-lang.org/) (y Erlang)
- Servidor [PostgreSQL](https://www.postgresql.org/)
- [NodeJS](https://nodejs.org)
- Un registro de sitio en [Google Recaptcha](https://developers.google.com/recaptcha/) con dominio localhost

### Backend

- Crear un archivo `config/ENV.secret.exs` y completar la configuración de acuerdo al entorno actual(ENV puede ser `dev`, `prod`, `test`), como las credenciales de la base de datos y de recaptcha.

  ```elixir
  use Mix.Config

  # Configure your database
  config :embers, Embers.Repo,
    username: "nombre_de_usuario_en_postgres",
    password: "contraseña_de_usuario_en_postgres",
    database: "nombre_de_base_de_datos",
    hostname: "localhost"

  config :recaptcha,
    public_key: "xxxxxxxxxxxxxxx",
    secret: "xxxxxxxxxxxxxxx"
  ```

- Instalar las dependencias con `mix deps.get`
- Crear y migrar la base de datos con `mix ecto.create && mix ecto.migrate`. Si este paso falla, intentar con `mix ecto.reset`.
- Insertar los datos iniciales a la base con `mix run priv/repo/seeds.exs`
- Iniciar el servidor con `mix phx.server`, o `iex -S mix phx.server` para poder usar `iex`.

### Frontend

Los archivos estáticos(léase css, javascript, etc) se encuentran en el directorio `/static`.

Los archivos que deben ser compilados se encuentran en `/assets`. Los archivos ya compilados son enviados a `/priv/static`. Si hay archivos que no necesitan ser compilados, ponerlos en `/assets/static` ya que el directorio `/priv/static` es ignorado por git.

Para compilar el frontend:

- Instalar dependencias `npm install`.
- Copiar assets/static a priv, ej. `cp -R assets/static priv`
- Compilar el frontend con `npm run dev`

Ahora se puede acceder a Embers entrando a [`localhost:4000`](http://localhost:4000).

## Links adicionales

### Phoenix Framework

- Sitio oficial: <http://www.phoenixframework.org/>
- Guías: <http://phoenixframework.org/docs/overview>
- Documentación: <https://hexdocs.pm/phoenix>
