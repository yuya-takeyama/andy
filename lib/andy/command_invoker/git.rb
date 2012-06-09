require 'shellwords'

module Andy
  module CommandInvoker
    class Git
      def invoke(*cmds)
        %x{git #{cmds.shelljoin}}
      end
    end
  end
end
