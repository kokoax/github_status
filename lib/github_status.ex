defmodule GithubStatus do
  @moduledoc """
  """

  @doc """

  ## Examples
  """
  def main(opts) do
    {options, _, _} = OptionParser.parse(opts,
      switches: [repository: :boolean, user: :string],
      aliases:  [r: :repository, u: :user]
    )
    IO.inspect options
    if options |> Dict.has_key?(:user) do
      repos = GithubRepository.new(options[:user])
      IO.inspect "Number ofo Repository #{repos |> Enum.count |> Integer.to_string}"
      IO.inspect repos
    end
  end
end

defmodule GithubRepository do
  defstruct [:name, :language, :stargazer]
  def new(user) do
    url = "https://api.github.com/users/#{user}/repos"
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(url)
    Poison.Parser.parse!(body)
      |> Enum.map(&(
          %GithubRepository {
            name: &1["full_name"],
            language: &1["language"],
            stargazer: &1["stargazers_count"],
          })
        )
  end
end

