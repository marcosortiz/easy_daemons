require_relative '../lib/sk-daemons/manager'
require_relative '../lib/sk-daemons/worker'

class MyWorker < EasyDaemons::Worker
    def do_work
        while true
            log(:info, "Doing my work ...")
            sleep 5
        end
    end
end

class MyManager < EasyDaemons::Manager
    def available_workers
        ['my_worker1', 'my_worker2']
    end

    def enabled_workers
        available_workers
    end

    def build_worker(worker_name)
        MyWorker.new(worker_name)
    end
end

m = MyManager.new('my_manager')
m.start