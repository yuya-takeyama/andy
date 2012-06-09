class Andy::Repository::Svn
  def initialize(url)
    @url = url
    @svn = ::Andy::CommandInvoker::Svn.new
  end

  def checkout(path, to)
    @svn.invoke 'co', @url + path, to
  end

  def branches
    @svn.invoke('ls', "#{@url}/branches").split("\n").grep(%r{/$}).map{|r| r.sub(%r{/$}, '') }
  end

  def tags
    @svn.invoke('ls', "#{@url}/tags").split("\n").grep(%r{/$}).map{|r| r.sub(%r{/$}, '') }
  end

  def android_project_root?(path)
    @svn.invoke('ls', @url + path).split("\n").any? {|f| f == "AndroidManifest.xml" }
  end
end
