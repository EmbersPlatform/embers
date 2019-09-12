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
      "disabled_post" -> "<strong>Post</strong> deshabilitado"
      "restore_post" -> "<strong>Post</strong> restaurado"
      "update_post" -> "<strong>Post</strong> Actualizado"
      _ -> action
    end
  end
end
