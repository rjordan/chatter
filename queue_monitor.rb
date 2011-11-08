require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

EventMachine.run do
    connection = AMQP.connect(:host => '127.0.0.1')
    channel  = AMQP::Channel.new(connection)
    queue = channel.queue("spikes.chatter.#{rand(10000)}", :auto_delete => true)
    exchange = channel.fanout("amq.fanout")
    queue.bind(exchange)
   
    queue.subscribe do |payload|
      puts payload
    end
end

