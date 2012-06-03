require 'andy'
require 'yaml'
require 'digest/sha1'

class Andy::App < ::Sinatra::Base
  set :haml, {:format => :html5}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))
  set :repos, settings.config['repositories']

  get '/:repo/*.apk' do
    branch = params[:splat].join('/')
    setup_worktree(params[:repo], branch)
  end

  get '/:repo' do
    @repo_name = params[:repo]
    @title = @repo_name
    @branches = repo.branches
    haml :repo
  end

  get '/' do
    @repos = settings.config['repositories']
    haml :index
  end

  def repo_config
    settings.repos[params[:repo]]
  end

  def repo
    ::Grit::Repo.new(repo_config['url'])
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
