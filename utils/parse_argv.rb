require 'slop'
require 'paint'

def parse_argv
  options = Slop::Options.new
  options.banner = <<~EOF
    Usage: #{Paint["ruby", :red, :bold]} slowloris.rb [host] [options]

    -p --port          Port of webserver usually 80
    -s --socketcount   Number of sockets to use in the test
    -u --randuseragent Randomizes user-agents with each request
    --https            Use HTTPS for the requests
    --sleeptime        Time to sleep between each header sent.
  EOF
  options.on "-h", "--help" do
    puts options.banner
    exit
  end
  options.string "--host", required: true
  options.integer "-p", "--port", default: 80
  options.integer "-s", "--socketcount", default: 150
  options.bool "-u", "--randuseragent", default: false
  options.bool "--https", default: false
  options.integer "--sleeptime", default: 15
  
  Slop::Parser.new(options).parse(ARGV)
end
