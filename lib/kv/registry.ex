defmodule KV.Registry do
  @moduledoc """
  Implements a bucket registry, using GenServer
  """
  use GenServer

  @type registry :: atom | pid | {atom, any} | {:via, atom, any}

  ## Client API

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  @doc """
  Starts the registry
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec lookup(registry(), String.t()) :: :error | {:ok, pid}
  @doc """
    Looks up the bucket pid for `name` stored in `server`.

    Returns `{:ok, pid}` if the bucket exists, :error otherwise
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @spec create(registry(), String.t()) :: :ok
  @doc """
    Ensures there is a bucket associated with the given 'name' in 'server'.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  # region [ callbacks ]

  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  @doc """
  Handle lookup a bucket by name
  """
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  # for illustration, in a real app this would probably also be synchronous
  @doc """
  Handle creating a bucket by name
  """
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  @impl true
  @doc """
    Handle monitoring messages from bucket
  """
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  # Handle other monitoring messages we don't care about at present
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # endregion [callbacks]
end
