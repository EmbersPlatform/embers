defmodule EmbersWeb.Cldr do
  use Cldr,
    default_locale:
      Application.get_env(:embers, EmbersWeb.Gettext, [])
      |> Keyword.get(:default_locale, "en"),
    locales: ["en", "es"],
    gettext: EmbersWeb.Gettext,
    data_dir: "./priv/cldr",
    otp_app: :embers,
    precompile_number_formats: ["¤¤#,##0.##"],
    providers: [Cldr.Number, Cldr.DateTime],
    generate_docs: true,
    force_locale_download: false
end
