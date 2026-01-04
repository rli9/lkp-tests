LKP_SRC ||= ENV['LKP_SRC'] || File.dirname(__dir__)

require 'fileutils'

module LKP
  module Dirable
    def exist?
      Dir.exist?(path)
    end

    def content_path(*names)
      File.join(path, *names)
    end

    def content_size?(*names)
      File.size?(content_path(*names))
    end

    def content_exist?(*names)
      File.exist?(content_path(*names))
    end

    def to_s
      path
    end

    def chmod(mode)
      FileUtils.chmod(mode, path)
    end

    def touch(*names)
      FileUtils.touch(content_path(*names))
    end

    def glob(*patterns)
      Dir.glob(content_path(*patterns))
    end

    class << self
      def included(mod)
        class << mod; include ClassMethods; end
      end
    end

    module ClassMethods
      def probe_content_path(content_path)
        ['', '.xz', '.gz'].map { |suffix| content_path + suffix }
                          .find { |path| File.exist? path }
      end

      def open_content(content_path, &)
        if content_path.end_with? '.gz'
          Zlib::GzipReader.open(content_path, &)
        elsif content_path.end_with? '.xz'
          IO.popen("xzcat #{content_path}", &)
        else
          File.open(content_path, &)
        end
      end
    end
  end
end
