require 'digest/sha1'

class Andy::ApkBuilder
  ANT_PROPERTIES = {
    'file'           => 'key.store',
    'password'       => 'key.store.password',
    'alias'          => 'key.alias',
    'alias_password' => 'key.alias.password',
  }

  def build(project, path, sdk_dir)
    repo = project.repo
    dir = ::File.expand_path("tmp/repos/#{project.id}/#{repo.hash}#{path}", settings.root)
    ::FileUtils.rm_rf(dir) if File.exist? dir
    ::FileUtils.mkdir_p(dir)
    repo.checkout(path, dir)
    put_local_properties(dir, sdk_dir)
    append_ant_properties(dir, project.keystore_config)
    orig_dir = Dir.pwd
    Dir.chdir(dir)
    java_opt = "_JAVA_OPTIONS='-Dfile.encoding=UTF-8'"
    result = `#{java_opt} ant debug && #{java_opt} ant release`
    Dir.chdir(orig_dir)
    result
  end

  def put_local_properties(dir, sdk_dir)
    open("#{dir}/local.properties", 'w') do |file|
      file.puts "sdk.dir=#{sdk_dir}"
    end
  end

  def append_ant_properties(dir, config)
    open(File.expand_path('ant.properties', dir), 'a') do |file|
      file.print "\n# Appended by Andy\n"
      ANT_PROPERTIES.each do |key, prop|
        file.puts "#{prop}=#{config[key]}" if config.key? key
      end
    end
  end
end
