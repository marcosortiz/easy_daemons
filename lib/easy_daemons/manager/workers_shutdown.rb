module EasyDaemons
    module WorkersShutdown
        
        def stop_worker(search_name)
            pids = pids_by_name(search_name)
            stopped = []
            if pids.nil? || pids.empty?
                stopped = true
            else
                pids.count.times do
                    stopped << false
                end
            
                pids.each_with_index do |pid, i|
                    begin
                        num_processes_killed = kill(pid)
                        stopped[i] = (num_processes_killed.nil? || num_processes_killed >= 1) ? true : false
                    rescue Errno::ESRCH
                        stopped << true
                    end
                end
                stopped.all? { |e| e == true}
            end
        end
    end
end