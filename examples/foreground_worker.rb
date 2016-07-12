require_relative '../lib/sk-daemons/worker'

class MyWorker < EasyDaemons::Worker
    def do_work
        while true
            log(:info, "#{Time.now.utc}")
            sleep 1
        end
    end
end

name = ARGV[0] || 'basic_worker'
log_path = ARGV[1]
opts = { :log_path => log_path }
w = MyWorker.new(name, opts)
w.run