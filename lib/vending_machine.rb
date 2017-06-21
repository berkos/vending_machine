# frozen_string_literal: true
# For arbitrary-precision floating point decimal arithmetic as we use money.
require 'bigdecimal'
require 'bigdecimal/util'
Dir[File.expand_path 'lib/**/*.rb'].each { |file| require_relative(file) }
