require_relative '../lib/sk-daemons/worker'

class MyFailingWorker < EasyDaemons::Worker
    def do_work
        5.times do
            raise 'Bla !!!!!'
        end
    end
end

name = ARGV[0] || 'my_failing_background_worker'
w = MyFailingWorker.new(name)
w.start