require 'andy'
require 'yaml'
require 'digest/sha1'

class SvnRepo
  def initialize(url)
    @url = url
  end

  def branches
    `svn ls #{@url}/branches`.split("\n").grep(%r{/$}).map{|r| r.sub(%r{/$}, '') }
  end

  def tags
    `svn ls #{@url}/tags`.split("\n").grep(%r{/$}).map{|r| r.sub(%r{/$}, '') }
  end

  def android_project_root?(path)
    `svn ls #{@url}#{path}`.split("\n").any? {|f| f == "AndroidManifest.xml" }
  end
end

class Andy::App < ::Sinatra::Base
  set :haml, {:format => :html5}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))
  set :repos, settings.config['repositories']

  ['/projects/:project_id', '/projects/:project_id/*'].each do |path|
    before path do
      @project_id = params[:project_id]
      @project    = settings.config['projects'][@project_id]
      @repo       = ::SvnRepo.new(@project['repo']['url'])
    end
  end

  get '/:repo/*.apk' do
    branch = params[:splat].join('/')
    setup_worktree(params[:repo], branch)
  end

  get '/projects/:project_id/*' do
    @path = "/" + params['splat'].join('/')
    haml :'projects/branch', :locals => {:title => @project['name'] + " - " + @path}
  end

  get '/projects/:project_id' do
    haml :'projects/index', :locals => {:title => @project['name']}
  end

  get '/' do
    @projects = settings.config['projects']
    haml :index
  end

  def repo_config
    settings.repos[params[:repo]]
  end

  def repo(project)
    ::Grit::Repo.new(project['repo']['url'])
  end

  def setup_worktree(repo_name, branch)
    repo_hash = ::Digest::SHA1.hexdigest(repo_config['url'])
    dir = ::File.expand_path("tmp/repos/#{repo_name}/#{repo_hash}/#{branch}", settings.root)
    ::FileUtils.rm_rf(dir) if File.exist? dir
    ::FileUtils.mkdir_p(dir)
    grit = ::Grit::Git.new('/tmp')
    clone_option = {:quiet => true, :verbose => false, :progress => false, :branch => branch}
    grit.clone(clone_option, repo_config['url'], dir)
    put_local_properties(dir)
    orig_dir = Dir.pwd
    Dir.chdir(dir)
    result = `ant release`
    Dir.chdir(orig_dir)
    result
  end

  def put_local_properties(dir)
    open("#{dir}/local.properties", 'w') do |file|
      file.puts "sdk.dir=#{settings.config['android']['sdk_dir']}"
    end
  end
end
