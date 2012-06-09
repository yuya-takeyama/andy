require 'shellwords'

module Andy
  module CommandInvoker
    class Svn
      def invoke(*cmds)
        %x{svn #{cmds.shelljoin}}
      end
    end
  end
end
