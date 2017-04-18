# A LINK SET
# a parent process spawns a child and establishes a link
# the child process spawns yet another process (grandchild process) and establishes a link
# that grandchild process crashes in a while, which causes the child process to crash, which causes the parent process to crash

defmodule Parent do
  def start_link do
    spawn(Parent, :init, [])
  end

  def init() do
    child_pid = Child.start_link
    IO.puts(["child started ", inspect(child_pid), ", alive: ", child_pid |> Process.alive? |> inspect ])
    IO.inspect Process.info(self(), :links)
    IO.puts(" ===== ")
  end

  def loop(child_pid) do
    receive do
      _msg -> loop(child_pid)
    end
  end
end

defmodule Child do
  def start_link do
    spawn_link(Child, :init, [])
  end

  def init() do
    grandchild_pid = GrandChild.start_link
    IO.puts(["grandchild started", inspect(grandchild_pid), ", alive: ", grandchild_pid |> Process.alive? |> inspect ])
    IO.inspect Process.info(self(), :links)
    loop()
  end

  def loop do
    receive do
      _msg -> loop()
    end
  end
end

defmodule GrandChild do
  def start_link do
    spawn_link(GrandChild, :loop, [])
  end

  def loop do
    receive do
      after 300 -> :ok
    end
    _a =  1 / 0
    loop()
  end
end

parent_pid = Parent.start_link
send(parent_pid, :report)

receive do
  after 1_000 -> :ok
end

IO.puts("parent alive: #{Process.alive?(parent_pid)}")

