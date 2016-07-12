require 'easy_daemons/constants'

module EasyDaemons
    module Helper
        module StatusChecks
        
            def pids_by_name(search_name)
                cmd = cmd_by_process_name(search_name)
                pids = `#{cmd}`.split("\n").map{ |x| x.to_i } rescue []
                pids = pids.delete_if { |x| x == 0 || x == curr_pid }
                pids = nil if pids.empty?
                pids
            end
    
            def is_already_running?(search_name)
                arr = pids_by_name(search_name)
                if arr
                    if arr.count == 1
                        arr.first != curr_pid
                    else
                        arr.count > 1
                    end
                else
                    false
                end
            end
    
            def is_stopped?(search_name)
                !is_already_running?(search_name)
            end
        
            private
    
            def cmd_by_process_name(search_name)
                EasyDaemons::PROCESS_GREP_CMD.gsub(EasyDaemons::PROC_GREP_CMD_REPLACE_STR, search_name)
            end
    
            def curr_pid
                Process.pid
            end
        
        end
    end
end