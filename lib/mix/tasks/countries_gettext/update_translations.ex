defmodule Mix.Tasks.CountriesGettext.UpdateTranslations do
  use Mix.Task

  @shortdoc "Generate or update pot and po files"

  @moduledoc ~s"""
  Generates `priv/gettext/countries.pot` and for every locale
  `priv/gettext/LOCALE/LC_MESSAGES/countries.po`.
  Invoke with `mix countries_gettext.update_translations de es ...`
  Note that en for english is not a valid locale, as it is included in the countries.pot as default.
  """

  def run(locales) do
    output_dir = Path.join(["priv", "gettext"])
    IO.puts("Generating countries.pot")
    CountriesGettext.GenerateFiles.generate_pot(output_dir)

    Enum.each(locales, fn locale ->
      IO.puts("Generating countries.po for locale \"#{locale}\"")
      CountriesGettext.GenerateFiles.generate_po(output_dir, locale)
    end)
  end
end
