defmodule EmbersWeb.Admin.AuditView do
  use EmbersWeb, :view
  import Scrivener.HTML

  def format_audit(audit) do
    action = action_text(audit.action)

    if is_nil(audit.user_id) do
      action
    else
      "#{action} por <strong>#{audit.user.username}</strong>"
    end
  end

  defp action_text(action) do
    case action do
      "ban_user" -> "<strong>Usuario</strong> suspendido"
      "delete_post" -> "<strong>Post</strong> eliminado"
      "disable_post" -> "<strong>Post</strong> deshabilitado"
      "restore_post" -> "<strong>Post</strong> restaurado"
      "update_post" -> "<strong>Post</strong> Actualizado"
      "tags_updated" -> "Tags de un post actualizados"
      "tags_added" -> "Tags agregados"
      "tags_removed" -> "Tags removidos"
      "marked_as_nsfw" -> "Marcado como nsfw"
      _ -> action
    end
  end

  defp format_detail(%{source: source} = _audit, %{action: "in_post"}) do
    id = String.to_integer(source)
    hash = Embers.Helpers.IdHasher.encode(id)
    {:safe, link} = link(hash, to: "/post/#{hash}", target: "_blank")
    "En el post #{link}"
  end

  defp format_detail(%{source: _source} = _audit, %{action: "in_user"} = detail) do
    {:safe, link} = link(detail.description, to: "/@#{detail.description}", target: "_blank")
    "Al usuario #{link}"
  end

  defp format_detail(_audit, detail) do
    action = action_text(detail.action)
    "<strong>#{action}</strong> #{detail.description}"
  end
end
