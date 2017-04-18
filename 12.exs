# Let's implement our own super incomplete and super naïve supervisor

defmodule SuperNaiveSupervisor do
  use GenServer

  # API

  # if a child process terminates, only that process is restarted.
  def start_link(child_specifications, strategy: :one_for_one) do
    GenServer.start_link(__MODULE__, child_specifications)
  end

  # Callbacks

  def init(child_specifications) do
    # TODO: set trap exit to true

    state = child_specifications
      |> Enum.map(&start_child/1)
      |> Enum.into(Map.new)

    {:ok, state}
  end

  defp start_child(spec = {mod, fun, args}) do
    # TODO: run the given MFA (module.fuction(arguments))
    # don't spawn a process, the convention in
    # OTP is that spawning happens in the module,
    # usually in start_link.

    # TODO: return a tuple with a pid and the spec
  end

  def handle_info({TODO: pattern match on a normal process exit}, state) do
    IO.puts(["child ", inspect(pid_just_exited), " has exited normally"])

    # TODO: remove the pid key and its value from the state

    {:noreply, new_state}
  end

  def handle_info({TODO: pattern match on a process exit caused by Process.exit(pid, :kill) }, state) do

    # TODO: remove the pid key and its value from the state

    {:noreply, new_state}
  end

  def handle_info({TODO: pattern match on all other exits}, state) do

    case Map.fetch(state, pid_just_exited) do
      {:ok, child_spec} ->

        # TODO: start the child again

        # TODO: remove the old pid key and its value from the state
        # TODO: add the new pid key with the spec value to the state

        IO.puts(["restarting", inspect(child_spec, charlists: :as_lists)])

        {:noreply, new_state}

      _ -> {:noreply, state}
    end
  end
end


defmodule CountDown do
  def start_link(times) when times > 0 do
    spawn(fn -> loop(times) end)
  end

  def loop(0) do
  end

  def loop(times) do
    receive do
      after 100 ->
        IO.puts("good countdown: #{times}")
        loop(times - 1)
    end
  end
end

defmodule BadCountDown do
  def start_link(times) when times > 0 do
    spawn(fn -> loop(times) end)
  end

  def loop(0) do
  end

  def loop(6) do
    1 / 0
  end

  def loop(times) do
    receive do
      after 100 ->
        IO.puts("bad countdown: #{times}")
        loop(times - 1)
    end
  end
end

SuperNaiveSupervisor.start_link([
  {CountDown, :start_link, [10]}
], strategy: :one_for_one)

# SuperNaiveSupervisor.start_link([
#   {CountDown,    :start_link, [10]},
#   {BadCountDown, :start_link, [10]}
# ], strategy: :one_for_one)

receive do
  after 7000 -> :ok
end
