module EasyDaemons
    
    PROC_GREP_CMD_REPLACE_STR = '?'
    PROCESS_GREP_CMD = "ps aux | grep -w '#{PROC_GREP_CMD_REPLACE_STR}' | grep -v grep | tr -s ' ' | cut -d ' ' -f 2,15"
    
    # daemon statuses
    DEAD_STATUS      = :dead
    EXITED_STATUS    = :exited
    NOT_OWNED_STATUS = :not_owned
    RUNNING_STATUS   = :running
end