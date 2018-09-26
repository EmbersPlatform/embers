# Embers

Embers está escrito en Elixir.
La capa web del sistema está basado en Phoenix Framework.

## Instalación

### Backend

- Instalar las dependencias con `mix deps.get`
- Crear y migrar la base de datos con `mix ecto.create && mix ecto.migrate`
- Iniciar el servidor con `mix phx.server`

### Frontend

Los archivos estáticos(léase css, javascript, etc) se encuentran en el directorio `/static`
Los archivos que deben ser compilados se encuentran en `/assets`

Para compilar el frontend:

- Instalar dependencias de Node.js con `cd assets && npm install`

Ahora se puede acceder a Embers entrando a [`localhost:4000`](http://localhost:4000) desde el buscador.

## Links adicionales

### Phoenix Framework

- Sitio oficial: <http://www.phoenixframework.org/>
- Guías: <http://phoenixframework.org/docs/overview>
- Documentación: <https://hexdocs.pm/phoenix>
