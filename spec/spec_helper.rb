require 'logger'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'easy_daemons'

TEST_LOGS_PATH = "test_logs"

def clean_logs
    FileUtils.rm_rf TEST_LOGS_PATH if File.exist? TEST_LOGS_PATH
end

def check_log_dir
    FileUtils.mkdir TEST_LOGS_PATH unless File.exist? TEST_LOGS_PATH    
end


RSpec.configure do |config|
    config.before(:all) do
        clean_logs
        check_log_dir
    end
end

class MyWorker < EasyDaemons::Worker
    def do_work
        while true
            t = Time.now.utc
            log(:info, "#{t}")
            sleep 1
        end
    end
end

def start_background_worker(name)
    logger = Logger.new("#{TEST_LOGS_PATH}/my_test_manager")
    m = EasyDaemons::Manager.new( 'my_test_manager',logger: logger)
    logger = Logger.new("#{TEST_LOGS_PATH}/#{name}")
    w = MyWorker.new(name, logger: logger)
    m.fork_worker(w)
end

def check_proc_running(m, name)
    pids = m.pids_by_name(name)
    expect(pids).not_to be nil
    expect(pids).to be_an Array
    expect(pids.count).to eq 1
    expect(pids.first).to be_a Fixnum
    pids.first
end

def check_proc_stopped(m, name)
    i = 0
    begin
        expect(m.is_stopped?(name)).to be true
    rescue Exception =>  e
        i += 1
        sleep 0.01
        retry unless i > 5
        raise e
    end
end

def check_pid_file(m, name, pid_file_path, exists)
    i = 0
    begin
        expect(File.exist?("#{pid_file_path}")).to eq exists
        if exists
            pid_from_file = File.read("#{pid_file_path}").to_i
            expect(pid_from_file).to eq check_proc_running(m, name)
        end
    rescue Exception => e
        i += 1
        sleep 1
        retry unless i > 5
        raise e
    end
    pid_from_file
end