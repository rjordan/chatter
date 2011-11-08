require 'amqp'

EventMachine.run do
  connection = AMQP.connect(:host => '127.0.0.1')
  channel  = AMQP::Channel.new(connection)
  exchange = channel.fanout("amq.fanout")
  #queue = channel.queue("spikes.chatter", :auto_delete => true)
  #queue.bind(exchange)
 
  exchange.publish "Hello"
  exchange.publish "World"

   show_stopper = Proc.new { connection.close { EventMachine.stop } }

   Signal.trap "TERM", show_stopper
   EventMachine.add_timer(3, show_stopper)
end

