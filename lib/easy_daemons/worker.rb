require 'easy_daemons/helper'
require 'easy_daemons/utils'


module EasyDaemons
    class Worker
        DEFAULT_SIGNALS = [:INT, :QUIT, :TERM]
        
        include EasyDaemons::Utils
        include EasyDaemons::Helper
        
        attr_reader :name, :pid_file_path, :pid, :logger
        
        def initialize(name, opts={})
            @name = name
            set_opts(opts)
        end
        
        #
        # Implement this method in your subclasses. This is where your main logic should go.
        #            
        def do_work
        end
        
        #
        # Register signals and setup shutdown hooks before executing do_work in the foreground.
        #
        def run
            log(:info, "Registering trap signals for #{@name} worker ...")
            register_signals
            log(:info, "Executing do_work logic for #{@name} worker ...")
            begin
                do_work
            rescue SystemExit => e
                if e.success?
                    log(:info, "Gracefully stopped #{@name}.")
                else
                    log_exception(e)
                    raise e
                end
            rescue Exception => e
                log_exception(e)
                raise e
            end
        end
        
        #
        # This method simply runs the run method as a daemon background process.
        #
        def start
            # check_pid(@pid_file_path, @name)
            if is_already_running?(@name)
                log(:info, "Process #{@name} is already running.")
                # return
                exit(1)
            end
            log(:info, "Starting #{@name} worker in the background ...")
            daemonize(@name)
            @pid = curr_pid
            log(:info, "#{@name} worker successfully started in the background (pid=#{@pid}).")
            log(:info, "Refreshing #{@pid_file_path} file with #{@pid}.")
            refresh_pid_file(@pid_file_path, @pid)
            log(:info, "#{@pid_file_path} successfully created with #{@pid}.")
            run
        end
        
        # Called Before grafecull shutdown. Put your cleanup code here.
        # Make sure any code you put here doesn't log anything to a log file,
        # otherwise you will get an error: https://bugs.ruby-lang.org/issues/7917 .
        def on_stop
            # close any open files, sockets, etc.
        end
        
        private
        
        def set_opts(opts)
            @logger = opts[:logger]
            @pid_file_path = opts[:pid_file_path] || "pids/#{@name}.pid"
        end
        
        def register_signals
            DEFAULT_SIGNALS.each do |signal|
                Signal.trap(signal) do
                    on_stop
                    remove_pid_file(@pid_file_path)
                    exit
                end
            end
        end
        
        def log_exception(e)
            log(:error, "#{e.class}: #{e.message}")
            log(:error, e.backtrace.join("\n"))
        end
        
    end
end