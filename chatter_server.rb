require "rubygems"
require "bundler/setup"
Bundler.require(:default)

EventMachine.run {
    EventMachine::WebSocket.start(:host => "127.0.0.1", :port => 8080) do |ws|
        ws.onopen {
          # publish message to the queue
          puts "{{user}} has joined the chat."
        }

        ws.onclose { 
          # publish message to the queue
 	  puts "{{user}} has left the chat." 
	}
        
        ws.onmessage { |msg|
          # publish message to the queue
          puts "{{user}}: #{msg}"
          ws.send "{{user}}: #{msg}"
        }
    end
}
