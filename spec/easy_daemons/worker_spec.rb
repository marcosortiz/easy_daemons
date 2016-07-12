require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'easy_daemons', 'worker')

describe EasyDaemons::Worker do


    let :name do
        'my_test_worker'
    end
    
    let :opts do
        { :log_path => "#{TEST_LOGS_PATH}/#{name}" }
    end
    
    before :each do
        w = EasyDaemons::Worker.new(name, opts)
        pids = w.pids_by_name(name)
        pids ||= []
        pids.each do |pid|
            w.kill(pid)    
        end 
    end
    
    def spawn_background_worker(name)
        cmd = "bundle exec ruby examples/background_worker.rb #{name} #{TEST_LOGS_PATH}/#{name}"
        spawn cmd, :chdir => File.join(File.dirname(__FILE__), '..', '..')
    end
            
    context 'daemonizer' do
        
        before :each do
            w = EasyDaemons::Worker.new(name, opts)
            pids = w.pids_by_name(name)
            pids ||= []
            pids.each do |pid|
                w.kill(pid)
            end
            check_proc_stopped(w, name)
        end
        
        context 'worker not running yet' do
            it 'must properly start it' do
                spawn_background_worker(name)
                
                w = EasyDaemons::Worker.new(name, opts)
                pid = check_proc_running(w, name)
                
                w.kill(pid)
                check_proc_stopped(w, name)
            end
        end
        
        context 'worker already running' do
            
            let :name do
                'my_test_worker2'
            end
            it 'must not start a second daemon' do
                w = EasyDaemons::Worker.new(name, opts)
                pid = nil
                prev_pid = nil
                3.times do
                    spawn_background_worker(name)
                    sleep 1
                    pid = check_proc_running(w, name)
                    expect(pid).to eq prev_pid if prev_pid
                    prev_pid = pid
                end
                w.kill(pid)
                check_proc_stopped(w, name)
            end
        end
    end
    context 'pid_file_manager' do
        
        let :name do
            'my_test_worker3'
        end

        def pid_file_path(name)
            "pids/#{name}.pid"
        end
        
        context 'no pid file in place' do
            it 'must properly create the pid file' do
                w = EasyDaemons::Worker.new(name, opts)
                expect(w.pid_file_path).to eq pid_file_path(name)
                check_pid_file(w, name, w.pid_file_path, false)

                spawn_background_worker(name)                                
                pid = check_pid_file(w, name, w.pid_file_path, true)

                w.kill(pid)
                check_proc_stopped(w, name)
                check_pid_file(w, name, w.pid_file_path, false)
            end
        end
        
        context 'pid file in place with wrong pid' do
            
            let :name do
                'my_test_worker4'
            end
            
            let :wrong_pid do
                -99
            end
            
            def create_wrong_pid(w, pid)
                w.refresh_pid_file(w.pid_file_path, pid)
                expect(File.exist?(w.pid_file_path)).to be true
                expect(File.read("#{w.pid_file_path}").to_i).to eq pid
            end
            
            it 'must properly refresh the pid file' do
                w = EasyDaemons::Worker.new(name, opts)
                create_wrong_pid(w, wrong_pid)
                
                spawn_background_worker(name)                                
                pid = check_pid_file(w, name, w.pid_file_path, true)
                
                w.kill(pid)
                check_proc_stopped(w, name)
                check_pid_file(w, name, w.pid_file_path, false)
            end
        end
    end

end