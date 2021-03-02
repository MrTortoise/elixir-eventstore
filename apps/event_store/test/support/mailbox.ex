defmodule MailBox do
  def wait_until_empty(pid) do
    {:message_queue_len, length} = Process.info(pid, :message_queue_len)
    if length > 0 do
      Process.sleep(100)
      wait_until_empty(pid)
    end

  end
end
