require 'rubygems'
require 'bundler/setup'
Bundler.require

$LOAD_PATH << File.expand_path('../lib', __FILE__)
require './autoloader.rb'
run Andy::App
