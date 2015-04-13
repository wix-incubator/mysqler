module ChefHelper
  extend self

  def wait_for_pid_to_die(pid, seconds)
    retrying(seconds) do
      run do
        begin
          Process.kill(0, pid)
          true
        rescue Errno::ESRCH
          false
        end
      end

      condition do |is_process_alive|
        is_process_alive
      end

      on_retry do
        sleep 1
      end
    end
  end

  def restart!
    pid = Process.pid
    client_fork = Chef::Config[:client_fork]
    parent_pid = client_fork ? Process.ppid : nil

    child_pid = fork {
      if client_fork
        is_process_alive = wait_for_pid_to_die(pid, 30)
        Process.kill(9, pid) if is_process_alive

        Process.kill(15, parent_pid)
        is_parent_process_alive = wait_for_pid_to_die(parent_pid, 30)
        Process.kill(9, parent_pid) if is_parent_process_alive
      else
        sleep 5 # wait for chef to complete...

        Process.kill(15, pid)
        is_process_alive = wait_for_pid_to_die(pid, 30)
        Process.kill(9, pid) unless is_process_alive
      end
      exec 'service chef-client restart'
    }
    Process.detach(child_pid)

    raise 'Restarting chef-client'
  end
end
