defmodule GithubStatus do
  @moduledoc """
  """

  @doc """

  ## Examples
  """
  def main(opts) do
    {options, _, _} = opts |> OptionParser.parse(
      switches: [repository: :boolean, help: :boolean],
      aliases:  [r: :repository, h: :help]
    )

    help = """
        Usage: github_status
        -r, --repository\t-- Output of Lang: RepoName
    """

    cond do
      options[:help] ->
        IO.puts help
      options[:repository] ->
        repos = GithubRepository.new()
        repos |> Commands.repository
      true ->
        IO.puts help
    end
  end
end

# Fix: Commandsからもっといい感じにする
defmodule Commands do
  def repository(repos) do
    repos
    |> Enum.map(fn(repo) ->
      IO.puts "#{if repo.language == nil, do: "unknown", else: repo.language} #{repo.name}"
    end)
  end
end

defmodule GithubRepository do
  defstruct [:name, :language, :stargazer]
  def new() do
    Application.get_env(:user, :username)
    |> Enum.map(fn(user) ->
      url = "https://api.github.com/users/#{user}/repos"
      header  = ["Authorization": "token #{Application.get_env(:user, :token)}"]
      option = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 1000]
      %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(url, header, option)
      Poison.Parser.parse!(body)
      |> Enum.map(fn(repo) ->
        %GithubRepository {
          name:      repo["full_name"],
          language:  repo["language"],
          stargazer: repo["stargazers_count"],
        }
      end)
    end)
    |> List.flatten
  end
end

