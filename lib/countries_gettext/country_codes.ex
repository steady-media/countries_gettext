defmodule CountriesGettext.CountryCodes do
  @country_codes_input_json_path to_string(:code.priv_dir(:countries_gettext)) <> "/iso-codes/data/iso_3166-1.json"
  @country_codes_json_path to_string(:code.priv_dir(:countries_gettext)) <> "/country_codes.json"

  @external_resource @country_codes_input_json_path


  unless File.exists?(@country_codes_json_path) do
    codes = @country_codes_input_json_path
    |> File.read!
    |> Poison.decode!
    |> Map.get("3166-1")
    |> Enum.map(&(Map.get(&1, "alpha_2")))
    |> Enum.map(&String.downcase/1)

    file_content = Poison.encode!(codes)
    File.write(@country_codes_json_path, file_content)
  end

  @country_codes @country_codes_json_path
  |> File.read!
  |> Poison.decode!

  def all do
    @country_codes
  end
end
