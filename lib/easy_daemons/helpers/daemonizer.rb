require 'easy_daemons/constants'

module EasyDaemons
    module Helper
        module Daemonizer
     
            def daemonize(name, output = '/dev/null')
                Process.setproctitle(name)
            
                # Fork returns twice, once in the parent process and once in the
                # child process. In the parent process it returns the child pid
                # and in the child process it returns nil.

                # The return value will be truth-y for the parent and false-y 
                # for the child. This means that the parent process will exit,
                # and as we know, orphan child processes carry on as normal.
                exit if fork
            
                # This causes the terminal that invoked this script to think 
                # the command is done, returning control to the terminal and 
                # taking it out of the equation.
                # Calling Process.setsid does 3 things:
                # 1) The process becomes a session leader of a new session.
                # 2) The process becomes the process group leader of a new process group.
                # 3) The process has no controlling terminal.
                Process.setsid
            
                # The forked process that had just becoe a process group and 
                # session group leader forks again and then exits.
                exit if fork
            
                # Changes the current working directory to the root directory
                # for the system. This isn't stricly necessary ut it's an extra
                # step to ensure that current working directory of the daemon
                # doesn't disappear during its eecution.
                #
                # This avoids problems where the directory that the daemon was
                # started from gets deleted or unmounted for any reason.
                # Dir.chdir "/"
            
                # This sets all the standard streams to go do /dev/null, a.k.a
                # to be ignored. Since the daemon is no longer attached to a
                # terminal session these are of no use anyway. They can't simply
                # be closed because some programs expect them to always be available.
                # Redirecting them to /dev/null ensures that they're still available
                # to the program but have no effect.
                STDIN.reopen output
                STDOUT.reopen output, "a"
                STDERR.reopen output, "a"
            end
        end
    end
end