defmodule KV.Registry do
  @moduledoc """
  Implements a bucket registry, using GenServer
  """
  use GenServer

  ## Client API

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  @doc """
  Starts the registry
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec lookup(KV.Bucket.bucket(), String.t()) :: :error | {:ok, pid}
  @doc """
    Looks up the bucket pid for `name` stored in `server`.

    Returns `{:ok, pid}` if the bucket exists, :error otherwise
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @spec create(KV.Bucket.bucket(), String.t()) :: :ok
  @doc """
    Ensures there is a bucket associated with the given 'name' in 'server'.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # region [ callbacks ]

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  # for illustration, in a real app this would probably also be synchronous
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end

  # endregion [callbacks]
end
