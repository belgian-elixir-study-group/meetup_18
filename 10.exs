# * Monitors are not bidirectional like links: there is a monitored process and a monitoring process
# * Monitors do not cause monitoring processes to exit
# * Each monitor has a unique reference and it is possible to stop a monitor using its reference

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
    child_pid = Child.start_link
    _reference = Process.monitor(child_pid)
    send(self(), :report)
    loop(child_pid)
  end

  def loop(child_pid) do
    receive do
      :report ->
        IO.puts(["child ", inspect(child_pid), " alive: ", child_pid |> Process.alive? |> inspect ])
        IO.inspect Process.info(self(), :links)

        loop(child_pid)

      {:DOWN, reference, :process, pid_that_died, reason} ->
        IO.puts("   ================")
        IO.puts("monitor reference: #{inspect(reference)}")
        IO.puts("monitored child process #{inspect(pid_that_died)} has exited because of:")
        IO.inspect(reason)
        IO.puts("   ================")

        loop(child_pid)
    end
  end
end

defmodule Child do
  def start_link do
    spawn(Child, :loop, [])  # spawn, not spawn_link, so there is no link between the child process and the parent process
  end

  def loop do
    receive do
      after 100 -> :ok
    end
    _a = 1 / 0
  end
end

parent_pid = Parent.start_link

receive do
  after 500 -> :ok
end

send(parent_pid, :report)

IO.puts("parent alive: #{Process.alive?(parent_pid)}")

