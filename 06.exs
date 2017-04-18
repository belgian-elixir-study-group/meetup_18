# In addition to the two ways for a process to die we've seen (error and a normal termination)
# there is a third one: Process.exit(pid, reason_to_die)
# A process not trapping exit signals will die no matter which reason is sent

defmodule P do
  def start_link do
    spawn(P, :loop, [])
  end

  def loop do
    receive do
      any_message ->
        IO.puts "received a message"
        IO.inspect(any_message)
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
