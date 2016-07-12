require 'fileutils'
require 'logger'
require_relative '../lib/easy_daemons/worker'

class MyWorker < EasyDaemons::Worker
    def do_work
        while true
            t = Time.now.utc
            log(:info, "#{t}")
            sleep 1
        end
    end
end


log_path = 'logs/background_worker.log'
log_dir = File.dirname(log_path)
FileUtils.mkdir_p log_dir unless File.exist? log_dir

name = ARGV[0] || 'my_background_worker'
opts = { :logger => Logger.new(log_path) }
w = MyWorker.new(name, opts)
w.start