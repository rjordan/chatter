require "rubygems"
require "bundler/setup"
Bundler.require(:default)

EventMachine.run {
    EventMachine::WebSocket.start(:host => "127.0.0.1", :port => 8080) do |ws|

      connection = AMQP.connect(:host => '127.0.0.1')
      channel  = AMQP::Channel.new(connection)
      queue = channel.queue("spikes.chatter", :auto_delete => true)
      exchange = channel.fanout("amq.fanout")
     
      queue.bind(exchange).subscribe do |payload|
        ws.send payload
      end

      ws.onopen {
        # publish message to the queue
        exchange.publish "{{user}} has joined the chat.", :routing_key => queue.name
      }

      ws.onclose { 
        # publish message to the queue
        exchange.publish "{{user}} has left the chat.", :routing_key => queue.name
      }
        
      ws.onmessage { |msg|
        # publish message to the queue
        exchange.publish "{{user}}: #{msg}", :routing_key => queue.name
      }
   end
}
