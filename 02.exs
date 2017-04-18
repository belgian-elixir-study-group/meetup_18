# A LINK SET
# a parent process spawns a child and establishes a link
# that child process crashes, which causes the parent to crash, too

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
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
    end
  end
end

defmodule Child do
  def start_link do
    spawn_link(Child, :loop, []) # spawn_link instead of link!
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

IO.puts("parent alive: #{Process.alive?(parent_pid)}")
send(parent_pid, :report)

send(parent_pid, :tell_child_to_crash)

receive do
  after 500 -> :ok
end

IO.puts("parent alive: #{Process.alive?(parent_pid)}")


