defmodule EmbersWeb.Admin.AuditView do
  @moduledoc false
  use EmbersWeb, :view
  import Scrivener.HTML

  def format_audit(audit) do
    action = action_text(audit)

    if is_nil(audit.user_id) do
      action
    else
      ~E"""
      <%= action %> por <strong><%= link(
        audit.user.username,
        to: "/@#{audit.user.username}",
        target: "_blank"
      ) %></strong>
      """
    end
  end

  defp action_text(nil), do: ""

  defp action_text(audit) do
    case audit.action do
      "ban_user" ->
        ~E"""
          <strong>Usuario</strong> suspendido
        """

      "delete_post" ->
        ~E"""
          <strong><%= link("Post",
            to: "/post/#{audit.source |> String.to_integer()}",
            target: "_blank"
          ) %></strong> eliminado
        """

      "disable_post" ->
        ~E"""
          <strong><%= link("Post",
            to: "/post/#{audit.source |> String.to_integer()}",
            target: "_blank"
          ) %></strong> deshabilitado
        """

      "restore_post" ->
        ~E"""
          <strong><%= link("Post",
            to: "/post/#{audit.source |> String.to_integer()}",
            target: "_blank"
          ) %></strong> restaurado
        """

      "update_post" ->
        ~E"""
          <strong><%= link("Post",
            to: "/post/#{audit.source |> String.to_integer()}",
            target: "_blank"
          ) %></strong> Actualizado
        """

      "tags_updated" ->
        ~E"""
          Tags de un <strong><%= link("post",
            to: "/post/#{audit.source |> String.to_integer()}",
            target: "_blank"
          ) %></strong> actualizados
        """

      "tags_added" ->
        ~E"""
          Tags agregados
        """

      "tags_removed" ->
        ~E"""
          Tags removidos
        """

      "marked_as_nsfw" ->
        ~E"""
          Marcado como nsfw
        """

      _ ->
        audit.action
    end
  end

  defp format_detail(%{source: source} = _audit, %{action: "in_post"}) do
    id = String.to_integer(source)
    {:safe, link} = link(id, to: "/post/#{id}", target: "_blank")
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
