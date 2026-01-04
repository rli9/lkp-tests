#!/usr/bin/env ruby

LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(__dir__, 2)

require 'git'

module Git
  class Author
    def formatted_name
      "#{@name} <#{@email}>"
    end
  end
end
