module EasyDaemons
    module Helper
        module ShutdownTasks
        
            def send_signal(pid, signal)
                return unless pid
                return unless pid.is_a?(Integer)
                Process.kill(signal, pid) rescue nil
            end
    
            def kill(pid, force=false)
                signal = force ? 9 : :QUIT
                send_signal(pid, signal)
            end
        
        end
    end
end