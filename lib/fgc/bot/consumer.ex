defmodule Fgc.Bot.Consumer do
    use Nostrum.Consumer

    alias Nostrum.Struct.Message
    alias Nostrum.Struct.Guild.Role
    alias Nostrum.Api

    import Ecto.Query

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    defp find_role_by_name(guild_id, name) do
        case Api.get_guild_roles(guild_id) do
           {:ok, roles} ->
              case Enum.find(roles, fn %Role{name: role_name} -> role_name == name end) do
                nil -> {:error, :not_found}
                role -> {:ok, role}
              end
           _ -> {:error, :cant_retrieve_roles}
        end
    end

    def handle_event({:MESSAGE_CREATE, message, _ws}) do
        case command(message) do
            :ok -> :noop
            {:ok, response} -> Api.create_message!(message.channel_id, response)
            {:error, error} -> Api.create_message!(message.channel_id, error)
        end
    end

    def handle_event(_) do
        :noop
    end

    defp command(%Message{guild_id: guild_id, content: "!showroles" <> _}) do
        role_ids = Fgc.Repo.all(from r in Fgc.Bot.Role, where: r.guild == ^(guild_id |> to_string))
        |> Enum.map(fn %Fgc.Bot.Role{role_id: role_id} -> role_id end)

        {:ok, roles} = Api.get_guild_roles(guild_id)

        msg = roles
        |> Enum.filter(fn %Role{id: id} -> Enum.member?(role_ids, id |> to_string) end)
        |> Enum.map(fn %Role{name: name} -> "!iam " <> name end)
        |> Enum.join("\n")

        msg = with "" <- msg do
            "no roles set up, use !addrole to add one"
        end

        {:ok, msg}
    end

    defp command(%Message{guild_id: guild_id, content: "!addrole " <> new_role}) do
        IO.inspect(find_role_by_name(guild_id, new_role))
        case find_role_by_name(guild_id, new_role) do
         {:ok, role} ->
            Fgc.Repo.insert(%Fgc.Bot.Role{guild: guild_id |> to_string, role_id: role.id |> to_string})
            :ok
         {:error, :not_found} ->
            role = Api.create_guild_role(guild_id, name: new_role)
            IO.inspect(role)
            Fgc.Repo.insert(%Fgc.Bot.Role{guild: guild_id |> to_string, role_id: role.id |> to_string})
            :ok
         _ -> true
        end
    end

    defp command(%Message{guild_id: guild_id, content: "!removerole " <> to_remove}) do
        with {:ok, role} <- find_role_by_name(guild_id, to_remove) do
            from(r in Fgc.Bot.Role,
                where: r.role_id == ^(role.id |> to_string))
            |> Fgc.Repo.delete_all
            :ok
        end
    end

    defp command(%Message{guild_id: guild_id, content: "!iam " <> to_set, author: %{id: author_id}}) do
        with {:ok, role} <- find_role_by_name(guild_id, to_set) do
            case Api.add_guild_member_role(guild_id, author_id, role.id) do
                {:ok} -> {:ok, "role added"}
                {:error, _error} -> {:error, "couldn't add role, possibly missing permissions"}
            end
        end
    end

    defp command(%Message{guild_id: guild_id, content: "!iamn " <> to_unset, author: %{id: author_id}}) do
        with {:ok, role} <- find_role_by_name(guild_id, to_unset) do
            case Api.remove_guild_member_role(guild_id, author_id, role.id) do
                {:ok} -> {:ok, "role removed"}
                {:error, _error} -> {:error, "couldn't add role, possibly missing permissions"}
            end
        end
    end

    defp command(_), do: :ok
end
