defmodule PasswordLock do
  @moduledoc """
  Documentation for `PasswordLock`.
  """
  use GenServer

  ### Client API ###

  @doc """
  Starts an instance of our server.

  Will trigger a callback to `init/1`
  """
  def start_link(password) do
    GenServer.start_link(__MODULE__, password, [])
  end

  @doc """
  Unlocks the server.

  Makes a sync call which will eventually
  trigger the implemented handle_call function.
  """
  def unlock(pid, password) do
    GenServer.call(pid, {:unlock, password})
  end

  @doc """
  Resets the server password.

  Makes a sync call which will eventually
  trigger the implemented handle_call function.
  """
  def reset(pid, {old_password, new_password}) do
    GenServer.call(pid, {:reset, {old_password, new_password}})
  end

  ### Server API ###

  @impl true
  @doc """
  Required implemented function.

  Used to provide an initial state.
  """
  def init(password) do
    {:ok, [password]}
  end

  @impl true
  @doc """
  Callback functions.
  """
  def handle_call({:unlock, password}, _from, current_state) do
    if password in current_state do
      {:reply, :ok, current_state}
    else
      write_to_logfile(password)
      {:reply, {:error, "wrongpassword"}, current_state}
    end
  end

  def handle_call({:reset, {old_password, new_password}}, _from, current_state) do
    if old_password in current_state do
      new_state =
        current_state
        |> List.delete(old_password)

      {:reply, :ok, [new_password | new_state]}
    else
      write_to_logfile(new_password)
      {:reply, {:error, "wrongpassword"}, current_state}
    end
  end

  defp write_to_logfile(text) do
    {:ok, pid} =
      PasswordLogger.start_link()
      |> IO.inspect()

    PasswordLogger.log_incorrect(pid, "wrong_password: #{text}")
  end
end
