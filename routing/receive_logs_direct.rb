#!/usr/bin/env ruby
require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.direct('logs')
queue = channel.queue('', exclusive: true)

ARGV.each do |severity|
  queue.bind('logs', routing_key: severity)
end

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts " [x] #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close

  exit(0)
end