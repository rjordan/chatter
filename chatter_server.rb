require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

RABBIT_HOST=ENV.fetch('RABBIT_HOST', '127.0.0.1')
WS_HOST=ENV.fetch('WS_HOST', '127.0.0.1:3001')

def run(app)
  EventMachine.run do
  
    dispatch = Rack::Builder.app do
      map '/' do
        run app
      end
    end
    
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 3001) do |ws|
      user_id = SecureRandom.uuid
      connection = AMQP.connect(:host =>RABBIT_HOST)
      channel  = AMQP::Channel.new(connection)
      queue = channel.queue("spikes.chatter.#{user_id}", :auto_delete => true)
      exchange = channel.fanout("amq.fanout")
     
      queue.bind(exchange).subscribe do |payload|
        ws.send payload
      end

      ws.onopen {
        # publish message to the queue
        exchange.publish "#{user_id} has joined the chat." #, :routing_key => queue.name
      }

      ws.onclose { 
        # publish message to the queue
        exchange.publish "#{user_id} has left the chat." #, :routing_key => queue.name
      }
        
      ws.onmessage { |msg|
        # publish message to the queue
        exchange.publish "#{user_id}: #{msg}" #, :routing_key => queue.name
      }
   end
   
   Rack::Server.start({
      app:    app,
      server: 'thin',
      Host:   '0.0.0.0',
      Port:   '3000',
      signals: false,
    })
  end
end

class Application < Sinatra::Base
  get '/' do
    erb :index
  end
end

run Application.new

