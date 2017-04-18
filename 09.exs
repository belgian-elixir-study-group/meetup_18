# When a process is killed with the kill signal, the exit reason is :killed, not :kill.
# This is important, as sending a :kill process would unconditionally take down the whole link set

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
    Process.flag(:trap_exit, true)
    child_pid = Child.start_link
    IO.puts(["child: pid: ", inspect(child_pid)])
    loop(child_pid)
  end

  def loop(child_pid) do
    receive do

      {:EXIT, pid_that_died, reason} ->
        IO.puts("   ================")
        IO.puts("linked child process #{inspect(pid_that_died)} has exited abnormally because of:")
        IO.inspect reason
        IO.puts("   ================")

        loop(child_pid)

      {:get_child_pid, from} ->
        send(from, {:child_pid, child_pid})
        loop(child_pid)
    end
  end
end

defmodule Child do
  def start_link do
    spawn_link(Child, :loop, [])
  end

  def loop do
    receive do
      _ -> loop()
    end
  end
end

pid = Parent.start_link
IO.puts("parent alive: #{Process.alive?(pid)}")

send(pid, {:get_child_pid, self()})

receive do
  {:child_pid, child_pid} ->
    IO.puts(["about to kill pid ", inspect(child_pid)])
    Process.exit(child_pid, :kill)
end

IO.puts("parent alive: #{Process.alive?(pid)}")

receive do
  after 100 -> :ok
end
