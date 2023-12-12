defmodule CountriesGettext.GenerateFiles do
  @country_codes_input_json_path to_string(:code.priv_dir(:countries_gettext)) <>
                                   "/iso-codes/data/iso_3166-1.json"

  @codes_by_name @country_codes_input_json_path
                 |> File.read!()
                 |> Jason.decode!()
                 |> Map.get("3166-1")
                 |> Enum.map(fn %{"alpha_2" => code, "name" => name} = map ->
                   name = map["common_name"] || name
                   {name, String.downcase(code)}
                 end)
                 |> Enum.into(%{})

  def generate_pot(output_dir) do
    content =
      @codes_by_name
      |> Enum.map(&pot_entry_for_country/1)
      |> Enum.join("\n")

    File.mkdir_p!(output_dir)
    File.write!(pot_path(output_dir), content)

    en_po_content =
      @codes_by_name
      |> Enum.map(&en_po_entry_for_country/1)
      |> Enum.join("\n")

    File.mkdir_p!(po_directory(output_dir, "en"))
    File.write!(po_path(output_dir, "en"), en_po_content)
  end

  def generate_po(output_dir, locale) do
    input =
      locale
      |> po_input_json_path()
      |> File.read!()

    content = Regex.replace(~r/msgid "([^"]+)"/, input, &replace_name_by_code/2)

    File.mkdir_p!(po_directory(output_dir, locale))
    File.write!(po_path(output_dir, locale), content)
  end

  def replace_name_by_code(str, name) do
    case Map.fetch(@codes_by_name, name) do
      :error -> str
      {:ok, code} -> String.replace(str, name, code)
    end
  end

  def pot_entry_for_country({_name, code}) do
    ~s"""
    msgid "#{String.downcase(code)}"
    msgstr ""
    """
  end

  def en_po_entry_for_country({name, code}) do
    ~s"""
    msgid "#{String.downcase(code)}"
    msgstr "#{name}"
    """
  end

  defp pot_path(output_dir) do
    Path.join([output_dir, "countries.pot"])
  end

  defp po_directory(output_dir, locale) do
    Path.join([output_dir, locale, "LC_MESSAGES"])
  end

  defp po_path(output_dir, locale) do
    Path.join([output_dir, locale, "LC_MESSAGES", "countries.po"])
  end

  def po_input_json_path(locale) do
    :code.priv_dir(:countries_gettext)
    |> to_string()
    |> Path.join(Path.join(["iso-codes", "iso_3166-1", "#{locale}.po"]))
  end
end
