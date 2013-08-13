#!/usr/bin/env ruby
require 'rubygems'
require 'wonga/daemon'
require_relative 'dns_record_created_event_handler/dns_record_created_event_handler'
dir_name = File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)
Wonga::Daemon.load_config(File.expand_path(File.join(dir_name,"config","daemon.yml")))
Wonga::Daemon.run(Wonga::Daemon::DNSRecordCreatedEventHandler.new(Wonga::Daemon.config, Wonga::Daemon.logger))
