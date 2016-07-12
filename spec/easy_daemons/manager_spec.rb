require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'easy_daemons', 'helper')

describe EasyDaemons::Helper do

    let :name do
        'my_test_worker'
    end

    let(:helper) do
        Class.new do
            include EasyDaemons::Helper
        end
    end

    before :each do
        m = helper.new
        pids = m.pids_by_name(name)
        pids ||= []
        pids.each do |pid|
            m.kill(pid)
        end
    end

    def stop_proc(m, pid)
        expect(m.kill(pid)).to eq 1
    end

    def check_proc_stopped(m, name)
        i = 0
        begin
            expect(m.pids_by_name(name)).to be nil
        rescue Exception =>  e
            i += 1
            sleep 0.01
            retry unless i > 5
            raise e
        end
    end
    
    context 'status_check' do
        describe 'pids_by_name' do
            it 'must return all matching pids, if any' do
                m = helper.new
                expect(m.pids_by_name(name)).to be nil

                start_background_worker(name)
                pid = check_proc_running(m, name)

                stop_proc(m, pid)
                check_proc_stopped(m, name)
            end
        end
        describe 'is_already_running?' do

            def check_proc_not_running(m, name)
                i = 0
                begin
                    expect(m.is_already_running?(name)).to be false
                rescue Exception =>  e
                    i += 1
                    sleep 0.01
                    retry unless i > 5
                    raise e
                end
            end

            it 'must return true or false' do
                m = helper.new
                expect(m.is_already_running?(name)).to be false

                start_background_worker(name)
                expect(m.is_already_running?(name)).to be true

                pid = check_proc_running(m, name)
                stop_proc(m, pid)
                check_proc_not_running(m, name)
            end
        end
        describe 'is_stopped?' do
            it 'must return true or false' do
                m = helper.new
                expect(m.is_stopped?(name)).to be true

                start_background_worker(name)
                expect(m.is_stopped?(name)).to be false

                pid = check_proc_running(m, name)
                stop_proc(m, pid)
                check_proc_stopped(m, name)
            end
        end
    end
    context 'shutdown_tasks' do
        it 'must properly kill the process' do
            m = helper.new
            expect(m.is_stopped?(name)).to be true

            2.times do |i|
                force = i == 1 ? true : false

                start_background_worker(name)
                expect(m.is_stopped?(name)).to be false

                pid = check_proc_running(m, name)
                m.kill(pid, force)
                check_proc_stopped(m, name)
            end
        end
    end
    context 'check_workers' do
        
        let :manager_name do
            'my_test_manager'
        end
        
        let :workers_count do
            3
        end
        
        let :workers do
            workers = []
            workers_count.times do |i|
                workers << "my_worker#{i+1}"
            end
            workers
        end
                
        let(:my_manager) do
            Class.new(EasyDaemons::Manager) do
                attr_reader :workers_started, :workers_stopped
                
                def initialize(name, opts)
                    @workers = opts[:workers]
                    @workers_started = []
                    @workers_stopped = []
                    super(name, opts)
                end
                
                def available_workers
                    @workers
                end

                def enabled_workers
                    available_workers
                end

                def build_worker(worker_name)
                    MyWorker.new(worker_name, :log_path => "#{TEST_LOGS_PATH}/#{worker_name}")
                end
                
                def start_worker(worker_name)
                    @workers_started << worker_name
                    super(worker_name)
                end
                
                def stop_worker(worker_name)
                    @workers_stopped << worker_name
                    super(worker_name)
                end
                
            end
        end
        
        def manager
            my_manager.new(manager_name, :log_path => "#{TEST_LOGS_PATH}/#{manager_name}", :workers => workers)
        end
        
        context 'starting workers' do
            it 'must start all enabled workers' do
                m =  manager
                expect(m.workers_started).to be_empty
                expect(m.workers_stopped).to be_empty
                2.times do
                    m.send(:check_workers)
                    expect(m.workers_started).to eq workers
                    expect(m.workers_stopped).to be_empty
                end
                m.on_stop
                expect(m.workers_started).to eq workers
                expect(m.workers_stopped).to eq workers
            end
        end
        context 'stopping workers' do
            it 'must stop all disabled workers' do
                m =  manager
                expect(m.workers_started).to be_empty
                expect(m.workers_stopped).to be_empty
                m.send(:check_workers)
                expect(m.workers_started).to eq workers
                expect(m.workers_stopped).to be_empty
                
                
                allow(m).to receive(:enabled_workers) { [] }
                2.times do
                    m.send(:check_workers)
                    expect(m.workers_started).to eq workers
                    expect(m.workers_stopped).to eq workers
                end
                
                m.on_stop
                expect(m.workers_started).to eq workers
                expect(m.workers_stopped).to eq workers
            end
        end
    end
    
end
