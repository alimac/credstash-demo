#!/usr/bin/ruby

require 'fileutils'
require 'syslog/logger'

def show_secret
  secret = ENV.fetch('SECRET')

  Time.now.to_s + " secret=#{secret}"
end

def graceful_exit
  exit
end

def main
  app_name = File.basename $PROGRAM_NAME
  log = Syslog::Logger.new app_name

  while true
    trap("QUIT") { graceful_exit }
    log.info show_secret
    sleep 10
  end

end

main if __FILE__==$PROGRAM_NAME