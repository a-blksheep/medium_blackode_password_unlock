defmodule PasswordLogger do
  @moduledoc """
  Documentation for `PasswordLogger`.

  Logs failed password attempts.
  """

  use GenServer

  @log_file "/tmp/password_logs"

  ### Client API ###

  @doc """
  Initial with a given file logger and log file.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, @log_file, [])
  end

  @doc """
  Log incorrect password attempts.

  Makes an async call which will trigger
  a the `handle_cast/2` function.
  """
  def log_incorrect(pid, msg) do
    GenServer.cast(pid, {:log, msg})
  end

  ### Server API ###

  @impl true
  @doc """
  Required implementation.

  Used to provide an initial state.
  Will be passed the log file name used in
  `start_link/0`.
  """
  def init(logfile) do
    {:ok, logfile}
  end

  @impl true
  @doc """
  Callback function. Handles async casts.
  """
  def handle_cast({:log, msg}, file_name) do
    if File.exists?(file_name) == false,
      do: File.touch!(file_name)

    File.chmod!(file_name, 0o755)

    {:ok, file} = File.open(file_name, [:append])
    IO.binwrite(file, msg <> "\n")
    File.close(file)

    # Because this is async, we don't
    # return back to the client.
    {:noreply, file_name}
  end
end
