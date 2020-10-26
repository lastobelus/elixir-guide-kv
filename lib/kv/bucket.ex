defmodule KV.Bucket do
  @moduledoc """
  Implements an instance of a key-value store using Agent
  """
  use Agent

  @type bucket :: atom | pid | {atom, any} | {:via, atom, any}

  @doc """
  Starts a new bucket.
  """
  @spec start_link(map()) :: {:error, any} | {:ok, bucket()}
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`
  """
  @spec get(bucket(), atom) :: any
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  @spec put(bucket(), atom, any) :: :ok
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end
