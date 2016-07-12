require File.join(File.dirname(__FILE__), 'constants')
require File.join(File.dirname(__FILE__), 'helpers', 'daemonizer')
require File.join(File.dirname(__FILE__), 'helpers', 'forker')
require File.join(File.dirname(__FILE__), 'helpers', 'pid_file_manager')
require File.join(File.dirname(__FILE__), 'helpers', 'shutdown_tasks')
require File.join(File.dirname(__FILE__), 'helpers', 'status_check')

module EasyDaemons
    module Helper
        include EasyDaemons::Helper::Daemonizer
        include EasyDaemons::Helper::Forker
        include EasyDaemons::Helper::PidFileManager
        include EasyDaemons::Helper::ShutdownTasks
        include EasyDaemons::Helper::StatusChecks
    end
end