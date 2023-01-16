defmodule Glimesh.ChatUserDetailsCache do
  @moduledoc """
  Wrapper functions for caching query results for read-only non-user-specific queries.
  """

  @doc """
  Atom used for refencing the query cache
  """
  @spec name :: :glimesh_chat_user_details_cache
  def name, do: :glimesh_chat_user_details_cache

  @doc """
  Retrieves the item from the cache, or inserts the new item. Will raise if the
  called lambda function does not return {:ok, val}

  If the item exists in the cache, it is retrieved. Otherwise, the lambda
  function is executed and its result is stored under the given key.

  ## Examples

      iex> get_and_store!("some_key", fn x -> :timer.sleep(1000) end)
      # ... 1 second pause
      :ok

      iex> get_and_store!("some_key", fn x -> :timer.sleep(1000) end)
      # ... immediate return
      :ok
  """

  def get_active_chatters(%Glimesh.Streams.Channel{} = channel, minutes \\ 15) do
    active_chatter_keys = Glimesh.Chat.get_active_chatters_ids(channel, minutes)
    if(not is_nil(active_chatter_keys) and Enum.count(active_chatter_keys) > 0) do
      not_cached_keys = Enum.filter(active_chatter_keys, fn id -> is_nil(ConCache.get(name(), channel.id <> id)) end)

      Enum.each(Glimesh.Chat.get_chatter_details(channel, not_cached_keys), fn entry ->
        ConCache.put(name(), channel.id <> entry[:user].id, entry)
      end)

      Enum.reduce(active_chatter_keys, [], fn (key, acc) ->
        [acc | ConCache.get(name(), channel.id <> key)]
      end)
    else
      []
    end
  end

  def get_inactive_chatters(%Glimesh.Streams.Channel{} = channel, limit \\ 100) do
    inactive_chatter_keys = Glimesh.Chat.get_inactive_chatters_ids(channel, limit)
    if(not is_nil(inactive_chatter_keys) and Enum.count(inactive_chatter_keys) > 0) do
      not_cached_keys = Enum.filter(inactive_chatter_keys, fn id -> is_nil(ConCache.get(name(), channel.id <> id)) end)

      Enum.each(Glimesh.Chat.get_chatter_details(channel, not_cached_keys), fn entry ->
        ConCache.put(name(), channel.id <> entry[:user].id, entry)
      end)

      Enum.reduce(inactive_chatter_keys, [], fn (key, acc) ->
        [acc | ConCache.get(name(), channel.id <> key)]
      end)
    else
      []
    end
  end
end
