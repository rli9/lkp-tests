require 'spec_helper'

describe 'require order' do
  files = Dir.glob("#{LKP_SRC}/**/*.rb").reject { |f| f.include?('/vendor/') } +
          Dir.glob("#{LKP_SRC}/{bin,sbin,daemon,tools,programs,stats,filters,monitors,lkp-exec}/*").select { |f| File.file?(f) && File.read(f, 100) =~ /ruby/ }

  files.each do |file_path|
    describe file_path do
      let(:content) { File.read(file_path) }
      let(:lines) { content.lines }

      it 'has sorted require statements' do
        require_lines = lines.grep(/^require /)

        sorted_lines = require_lines.sort_by do |line|
          if line.include?('LKP_SRC')
            [1, line]
          elsif line.include?('LKP_CORE_SRC')
            [2, line]
          else
            [0, line]
          end
        end

        expect(require_lines).to eq(sorted_lines)
      end

      it 'does not have empty lines between require statements' do
        first_require_index = lines.index { |l| l =~ /^require / }
        last_require_index = lines.rindex { |l| l =~ /^require / }

        if first_require_index && last_require_index
          require_block = lines[first_require_index..last_require_index]
          expect(require_block.grep(/^\s*$/)).to be_empty
        end
      end
    end
  end
end
