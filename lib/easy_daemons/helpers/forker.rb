require 'easy_daemons/helpers/pid_file_manager'
require 'easy_daemons/helpers/status_check'

module EasyDaemons
    module Helper
        module Forker
            include EasyDaemons::Helper::PidFileManager
            include EasyDaemons::Helper::StatusChecks
        
            def fork_worker(worker)
                fork do
                    logger = worker.instance_variable_get(:@logger)
                    logger.info "Starting #{worker.name} worker in the background ..."
                    Process.setproctitle(worker.name)
                    Process.setsid
                    pid = curr_pid
                    logger.info "#{worker.name} worker successfully started in the background (pid=#{pid})."
                    logger.info "Refreshing #{worker.pid_file_path} file with #{pid}."
                    refresh_pid_file(worker.pid_file_path, pid)
                    logger.info "#{worker.pid_file_path} successfully created with #{pid}."
                    worker.run
                end
            end
        end
    end
end