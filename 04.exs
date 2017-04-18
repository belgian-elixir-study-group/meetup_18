# a parent process is configured to intercept child process exits as messages
# a parent process spawns a child and establishes a link
# that child process crashes, which causes a message to be sent to the parent process:
# {:EXIT, pid, reason}

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
    Process.flag(:trap_exit, true) # Main difference from previous examples
    child_pid = Child.start_link
    loop(child_pid)
  end

  def loop(child_pid) do
    receive do
      :report ->
        IO.puts("<report>")
        IO.puts(["  child ", inspect(child_pid), " alive: ", child_pid |> Process.alive? |> inspect ])
        IO.puts(["  ", self() |> Process.info(:links) |> inspect])
        IO.puts("</report>")

        loop(child_pid)

      :tell_child_to_crash ->
        send(child_pid, :crash)
        loop(child_pid)

      {:EXIT, pid_that_died, reason} ->
        IO.puts("   ================")
        IO.puts("linked child process #{inspect(pid_that_died)} has exited abnormally because of:")
        IO.inspect reason
        IO.puts("   ================")

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
      :crash ->
        _a = 1 / 0
        loop()
    end
  end
end

parent_pid = Parent.start_link
send(parent_pid, :report)

send(parent_pid, :tell_child_to_crash)

receive do
  after 500 -> :ok
end

send(parent_pid, :report)

IO.puts("parent alive: #{Process.alive?(parent_pid)}")

