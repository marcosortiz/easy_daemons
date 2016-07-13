require 'easy_daemons/exceptions'
require 'easy_daemons/helper'
require 'easy_daemons/worker'
require 'easy_daemons/manager/workers_factory'
require 'easy_daemons/manager/workers_registry'
require 'easy_daemons/manager/workers_shutdown'

module EasyDaemons
    class Manager < EasyDaemons::Worker
        include EasyDaemons::Helper
        include EasyDaemons::WorkersRegistry
        include EasyDaemons::WorkersFactory
        include EasyDaemons::WorkersShutdown

        DEFAULT_CHECK_PERIOD = 15 # seconds
        
        def initialize(name, opts={})
            super(name, opts)
            @check_period = opts[:check_period].to_i
            @check_period = DEFAULT_CHECK_PERIOD if @check_period <= 0
        end
        
        def do_work
            schedule_periodic_work
        end
        
        def on_stop
            available_workers.each do |worker_name|
                if is_already_running?(worker_name)
                    stop_worker(worker_name)
                end
            end
        end
        
        private
        
        def schedule_periodic_work
            while true
                check_workers
                sleep @check_period
            end
        end
        
        def check_workers
            available_workers.each do |worker_name|
                if enabled_workers.include?(worker_name)
                    unless is_already_running?(worker_name)
                        log(:info, "Starting #{worker_name} worker ...")
                        start_worker(worker_name)
                        log(:info, "Worker #{worker_name} successfully started.")
                    end
                else
                    if is_already_running?(worker_name)
                        log(:info, "Stopping #{worker_name} worker ...")
                        stop_worker(worker_name)
                        log(:info, "Worker #{worker_name} successfully stopped.")
                    end
                end
            end
        end
        
        def start_worker(worker_name)
            worker = build_worker(worker_name)
            validate_worker(worker)
            Process.detach(fork_worker(worker))
        end
        
        def validate_worker(worker)
            raise InvalidWorkerClass unless worker.respond_to?(:run)
        end
        
    end
end