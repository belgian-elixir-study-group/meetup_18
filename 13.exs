# Let's add strategy one_for_all to our incomplete and super naïve supervisor

defmodule SuperNaiveSupervisor do
  use GenServer

  defstruct pid_and_child_specs_map: Map.new, strategy: :one_for_one

  # API

  # if a child process terminates, only that process is restarted.
  def start_link(child_specifications, strategy: :one_for_one) do
    GenServer.start_link(__MODULE__, {child_specifications, :one_for_one})
  end
  # if a child process terminates, all other child processes are
  # terminated and then all child processes (including the terminated one) are restarted.
  def start_link(child_specifications, strategy: :one_for_all) do
    GenServer.start_link(__MODULE__, {child_specifications, :one_for_all})
  end

  # Callbacks

  def init({child_specifications, strategy}) do
    Process.flag(:trap_exit, true)

    pid_and_child_specs_map = start_children(child_specifications)

    state = %SuperNaiveSupervisor{strategy: strategy, pid_and_child_specs_map: pid_and_child_specs_map}

    {:ok, state}
  end

  defp start_children(child_specifications) do
    # TODO: start all children with start_child() and return a map
    # where keys are pids and values are MFAs
  end

  defp start_child(spec = {mod, fun, args}) do
    # TODO: run the given MFA (module.fuction(arguments))
    # don't spawn a process, the convention in
    # OTP is that spawning happens in the module,
    # usually in start_link.

    # TODO: return a tuple with a pid and the spec
  end

  def handle_info({:EXIT, pid_just_exited, :normal}, state) do
    IO.puts(["child ", inspect(pid_just_exited), " has exited normally"])
    # TODO: remove the pid key and its value from the state
    # Remember that the state is a tad more complex than in assignment 12
    {:noreply, new_state}
  end

  def handle_info({:EXIT, pid_just_exited, :killed}, state) do
    # TODO: remove the pid key and its value from the state
    # Remember that the state is a tad more complex than in assignment 12

    {:noreply, new_state}
  end

  def handle_info({:EXIT, pid_just_exited, _reason}, state) do

    case Map.fetch(state.pid_and_child_specs_map, pid_just_exited) do
      {:ok, child_spec_just_died} ->

        new_state = case state.strategy do
          :one_for_one -> process_for_one_for_one(pid_just_exited, child_spec_just_died, state)

          :one_for_all -> process_for_one_for_all(pid_just_exited, state)
        end

        {:noreply, new_state}
      _ -> {:noreply, state}
    end
  end

  defp process_for_one_for_all(pid_just_exited, state) do

    # TODO: kill all processes which are alive (i.e. all but pid_just_exited)

    IO.puts(["one_for_all, restarting all: ", inspect(specs, charlists: :as_lists)])

    # TODO: restart all processes

    %SuperNaiveSupervisor{
      strategy: state.strategy,
      pid_and_child_specs_map: new_pid_and_child_specs_map
    }
  end

  defp process_for_one_for_one(pid_just_exited, child_spec_just_died, state) do
    IO.puts(["one_for_one, restarting", inspect(child_spec_just_died)])

    # TODO: start the child again

    # TODO: remove the old pid key and its value from the state
    # TODO: add the new pid key with the spec value to the state


    %{ state | pid_and_child_specs_map: new_pid_and_child_specs_map }
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

# SuperNaiveSupervisor.start_link([
#   {CountDown, :start_link, [10]}
# ], strategy: :one_for_one)

# SuperNaiveSupervisor.start_link([
#   {CountDown,    :start_link, [100]},
#   {BadCountDown, :start_link, [10]}
# ], strategy: :one_for_one)


SuperNaiveSupervisor.start_link([
  {CountDown,    :start_link, [100]},
  {BadCountDown, :start_link, [10]}
], strategy: :one_for_all)


receive do
  after 7000 -> :ok
end
