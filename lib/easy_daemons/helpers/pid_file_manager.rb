require 'easy_daemons/constants'

module EasyDaemons
    module Helper
        module PidFileManager
        
            def refresh_pid_file(pid_file_path, pid)
                check_dir(pid_file_path)
                file = File.open(pid_file_path, 'w') do |f|
                    f.write("#{pid}")
                end
            end
        
            def remove_pid_file(pid_file_path)
                if File.exists?(pid_file_path)
                    File.delete(pid_file_path) 
                end
            end
        
            private
        
            def check_dir(pid_file_path)
                FileUtils.mkdir_p(File.dirname(pid_file_path))
            end

        end
    end
end