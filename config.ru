require 'bundler'
Bundler.require

require './app.rb'
run Rack::Cascade.new [Deposit, Withdraw]
