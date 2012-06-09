class Andy::Branch
  attr_reader :path

  def initialize(project, path, root = ::Andy::ROOT_DIR)
    @project = project
    @path    = path
    @root    = root
  end

  def absolute_path
    @project.absolute_path + @path
  end

  def tmp_dir
    File.expand_path("tmp/repos/#{@project.id}/#{@project.repo.hash}#{path}", @root)
  end

  def apk_files
    Dir.glob(tmp_dir + "/bin/*.apk").map {|f| f.gsub(%r{^.*/}, '') }
  end

  def no_apk_files?
    apk_files.empty?
  end
end
