# let's change how the child process terminates: it will just exit normally
#
# a parent process is configured to intercept child process exits as messages
# a parent process spawns a child and establishes a link
# that child process terminates normally, which causes a message to be sent to
# the parent process with reason being :normal:
# {:EXIT, pid, :normal}

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
    Process.flag(:trap_exit, true)
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

      {:EXIT, pid_that_died, :normal} ->
        IO.puts("   ================")
        IO.puts("linked child process #{inspect(pid_that_died)} has exited normally")
        IO.puts("   ================")

        loop(child_pid)


      {:EXIT, pid_that_died, reason} -> # will not be executed
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
      after 100 -> :ok
    end
  end
end

parent_pid = Parent.start_link
send(parent_pid, :report)

receive do
  after 500 -> :ok
end

send(parent_pid, :report)

IO.puts("parent alive: #{Process.alive?(parent_pid)}")

