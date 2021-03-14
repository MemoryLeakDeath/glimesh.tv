defmodule Glimesh.SchemaNext.AccountTypes do
  @moduledoc false
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers

  alias Glimesh.Avatar
  alias Glimesh.Repo
  alias Glimesh.ResolversNext.AccountResolver

  object :accounts_queries do
    @desc "Get yourself"
    field :myself, :user do
      resolve(&AccountResolver.myself/3)
    end

    @desc "List all users"
    connection field :users, node_type: :user, paginate: :forward do
      resolve(&AccountResolver.all_users/2)
    end

    @desc "Query individual user"
    field :user, :user do
      arg(:id, :integer)
      arg(:username, :string, deprecate: "Use ids for future as these will be removed later")
      resolve(&AccountResolver.find_user/2)
    end

    @desc "List all follows or followers"
    connection field :followers, node_type: :follower, paginate: :forward do
      arg(:streamer_username, :string,
        deprecate: "Use ids for future as these will be removed later"
      )

      arg(:user_username, :string, deprecate: "Use ids for future as these will be removed later")
      arg(:streamer_id, :integer)
      arg(:user_id, :integer)
      resolve(&AccountResolver.all_followers/2)
    end
  end

  object :account_subscriptions do
    field :followers, :follower do
      arg(:streamer_id, :id)

      config(fn args, _ ->
        case Map.get(args, :streamer_id) do
          nil ->
            {:ok, topic: [Glimesh.AccountFollows.get_subscribe_topic(:follows)]}

          streamer_id ->
            {:ok, topic: [Glimesh.AccountFollows.get_subscribe_topic(:follows, streamer_id)]}
        end
      end)
    end
  end

  @desc "A user of Glimesh, can be a streamer, a viewer or both!"
  object :user do
    field :id, :id

    field :username, :string, description: "Lowercase user identifier"

    field :displayname, :string,
      description: "Exactly the same as the username, but with casing the user prefers"

    # field :email, :string, let's hide this for now :)
    field :confirmed_at, :naive_datetime

    field :avatar, :string do
      # Need to strip the asset_host url from this property
      resolve(fn user, _, _ ->
        avatar_path =
          case Application.get_env(:waffle, :asset_host) do
            nil ->
              Avatar.url({user.avatar, user})

            asset_host ->
              asset_host = String.trim_trailing(asset_host, "/")
              full_url = Avatar.url({user.avatar, user})
              String.replace(full_url, asset_host, "")
          end

        {:ok, avatar_path}
      end)
    end

    field :avatar_url, :string do
      resolve(fn user, _, _ ->
        avatar_url =
          case Application.get_env(:waffle, :asset_host) do
            nil ->
              GlimeshWeb.Router.Helpers.static_url(
                GlimeshWeb.Endpoint,
                Avatar.url({user.avatar, user})
              )

            _ ->
              Avatar.url({user.avatar, user})
          end

        {:ok, avatar_url}
      end)
    end

    field :socials, list_of(:user_social),
      resolve: dataloader(Repo),
      description: "A list of linked social accounts for the user"

    field :social_twitter, :string,
      description: "Qualified URL for the user's Twitter account",
      deprecate: "Use the socials field instead"

    field :social_youtube, :string, description: "Qualified URL for the user's YouTube account"

    field :social_instagram, :string,
      description: "Qualified URL for the user's Instagram account"

    field :social_discord, :string, description: "Qualified URL for the user's Discord server"

    field :social_guilded, :string, description: "Qualified URL for the user's Guilded server"

    field :youtube_intro_url, :string, description: "YouTube Intro URL for the user's profile"
    field :profile_content_md, :string, description: "Markdown version of the user's profile"

    field :profile_content_html, :string,
      description: "HTML version of the user's profile, should be safe for rendering directly"
  end

  connection node_type: :user do
    field :count, :integer do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
      field :node, :user do
        resolve(fn %{node: message}, _args, _info ->
          {:ok, message}
        end)
      end
    end
  end

  @desc "A linked social account for a Glimesh user."
  object :user_social do
    field :id, :id

    field :platform, :string, description: "Platform that is linked, eg: twitter"

    field :identifier, :string,
      description: "Platform unique identifier, usually a ID, made into a string"

    field :username, :string, description: "Username for the user on the linked platform"

    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

  @desc "A follower is a user who subscribes to notifications for a particular user's channel."
  object :follower do
    field :id, :id
    field :has_live_notifications, :boolean

    field :streamer, non_null(:user), resolve: dataloader(Repo)
    field :user, non_null(:user), resolve: dataloader(Repo)

    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  connection node_type: :follower do
    field :count, :integer do
      resolve(fn
        _, %{source: conn} ->
          {:ok, length(conn.edges)}
      end)
    end

    edge do
      field :node, :follower do
        resolve(fn %{node: message}, _args, _info ->
          {:ok, message}
        end)
      end
    end
  end
end
