module EasyDaemons
    
    #
    # Raised when trying to use a worker object that is not a subclass of 
    # {EasyDaemons::Worker}
    #
    class InvalidWorkerClass < StandardError
    end
    
end