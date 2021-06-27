# Deletes

Embers soporta _soft deletes_ y _hard deletes_ para las principales entidades que pueden ser guardadas en la base de datos, tales como `Embers.Feed.Post` o `Embers.Media.MediaItem`.

## Hard delete

**hard delete** es cuando la entrada es eliminada completamente de la base de datos.
Entidades triviales como una reaccion o un follow son casos de entidades que pueden ser eliminadas de esta forma ya que no es necesario mantenerlas en la base de datos a modo de archivo, ni es necesaria su rehabilitacion a futuro.

## Soft delete

**soft delete** es cuando la entrada no es eliminada de la base de datos, sino que se le asigna la fecha en que fue eliminado en su columna `deleted_at`.
Esto significa que para obtener las entradas que no han sido borradas con este metodo, es necesario incluir `WHERE deleted_at IS NULL` en la consulta:

### Ejemplo

    from(
      Embers.Feed.Post as post,
      where: is_nil(post.deleted_at)
    )
    |> Repo.all()
