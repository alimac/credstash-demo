#!/usr/bin/ruby

require 'fileutils'
require 'syslog/logger'
require 'rcredstash'

def show_secret
  demo_secret_1 = ENV.fetch('DEMO_SECRET_1')
  demo_secret_2 = CredStash.get('demo_secret_2', context: { 'env' => 'demo' })

  Time.now.to_s + " demo_secret_1=#{demo_secret_1}, demo_secret_2=#{demo_secret_2}"
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