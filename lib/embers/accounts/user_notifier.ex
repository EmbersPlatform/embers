defmodule Embers.Accounts.UserNotifier do
  # This shouldn't be here but until I figure out where to keep gettext, it will
  # do
  import EmbersWeb.Gettext

  alias Embers.Mailer

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
    import Swoosh.Email

    new()
    |> to(to)
    |> from("noreply@#{email_host()}")
    |> subject(subject)
    |> html_body(body)
    |> Mailer.deliver()

    {:ok, %{to: to, body: body}}
  end

  defp email_host do
    Application.get_env(:embers, Embers.Email)[:host]
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(
      user.email,
      dgettext("emails", "Confirm your Embers account"),
      dgettext(
        "emails",
        """
        Hi %{username},

        You can confirm your account by visiting the URL below:

        %{url}

        If you didn't create an account with us, please ignore this.
        """,
        username: user.username,
        url: url
      )
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(
      user.email,
      dgettext("emails", "Reset your password"),
      dgettext(
        "emails",
        """
        Hi ${username},

        You can reset your password by visiting the URL below:

        %{url}

        If you didn't request this change, please ignore this.
        """,
        username: user.username,
        url: url
      )
    )
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(
      user.email,
      dgettext("emails", "Confirm your new email"),
      dgettext(
        "emails",
        """
        Hi %{username},

        You can change your email by visiting the URL below:

        %{url}

        If you didn't request this change, please ignore this.
        """,
        username: user.username,
        url: url
      )
    )
  end
end
