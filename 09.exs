# But...
# There is one special reason even a process trapping exit signals cannot catch: :kill

defmodule P do
  def start_link do
    spawn(P, :init, [])
  end

  def init() do
    Process.flag(:trap_exit, true)
    loop()
  end

  def loop do
    receive do
      any_message ->
        IO.puts("   ================")
        IO.puts "received a message"
        IO.inspect(any_message)
        IO.puts("   ================")
        loop()
    end
  end
end

pid = P.start_link

IO.puts("parent alive: #{Process.alive?(pid)}")

Process.exit(pid, :please_die)

receive do
  after 10 -> :ok
end

IO.puts("parent alive: #{Process.alive?(pid)}")

Process.exit(pid, :kill)

receive do
  after 10 -> :ok
end

IO.puts("parent alive: #{Process.alive?(pid)}")
