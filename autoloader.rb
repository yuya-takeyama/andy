module Andy
  autoload :ApkBuilder, 'andy/apk_builder'
  autoload :App, 'andy/app'
  module CommandInvoker
    autoload :Git, 'andy/command_invoker/git'
    autoload :Svn, 'andy/command_invoker/svn'
  end
  module Repository
    autoload :Svn, 'andy/repository/svn'
  end
  autoload :Repository, 'andy/repository'
end
autoload :Andy, 'andy'
