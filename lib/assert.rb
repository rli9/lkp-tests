#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(__dir__)

require "#{LKP_SRC}/lib/log"

# rli9 FIXME: leverage an existing lib
def assert(cond, message)
  return if cond

  message = "ASSERT fail: #{message} (#{called_from})"

  log_error message
  raise message
end

def called_from(start = 2)
  caller_location = caller_locations(start, 1).first

  "called from #{caller_location.base_label} at #{caller_location.path}:#{caller_location.lineno}"
end

def assert_not_nil(var)
  if var.instance_of? Hash
    return if var.values.none?(&:nil?)

    assert false, "variable (#{var.reject { |k, _v| k }.keys.join(', ')}) cannot be nil"
  else
    assert var, 'variable cannot be nil'
  end
end

def assert_dir_exist(dir)
  assert Dir.exist?(dir), "#{dir} doesn't exist"
end
