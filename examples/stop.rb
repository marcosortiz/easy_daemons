require_relative '../lib/sk-daemons/helper'

class MyManager
    extend EasyDaemons::Helper
end

name = ARGV[0] || 'my_manager'

pids = MyManager.pids_by_name(name)
if pids.nil?
    puts "No #{name} process running."
else
    pids.each do |pid|
        puts "Stopping #{name} worker with pid=#{pid}."
        MyManager.kill(pid)
    end
end