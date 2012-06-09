# coding: utf-8
require 'andy'
require 'yaml'
require 'digest/sha1'

class Andy::App < ::Sinatra::Base
  set :haml, {:format => :html5, :encoding => 'utf-8'}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))
  set :repos, settings.config['repositories']

  ['/projects/:project_id', '/projects/:project_id/*'].each do |path|
    before path do
      @project_id = params[:project_id]
      @project    = settings.config['projects'][@project_id]
      @repo       = ::Andy::Repository::Svn.new(@project['repo']['url'])
    end
  end

  get '/projects/:project_id/*/:file.apk' do
    @path = "/" + params['splat'].join('/')
    repo_hash = ::Digest::SHA1.hexdigest(@project['repo']['url'])
    dir = ::File.expand_path("tmp/repos/#{@project_id}/#{repo_hash}#{@path}/bin", settings.root)
    send_file "#{dir}/#{params[:file]}.apk", :type => 'application/vnd.android.package-archive'
  end

  get '/projects/:project_id/*' do
    @path = "/" + params['splat'].join('/')
    if params['build']
      builder = ::Andy::ApkBuilder.new
      builder.build(@repo, @project_id, @project, @path, settings.config['android']['sdk_dir'])
      redirect "/projects/#{@project_id}#{@path}"
    end
    @apks = apks(@project_id, @project, @path)
    haml :'projects/branch', :locals => {:title => @project['name'] + " - " + @path}
  end

  get '/projects/:project_id' do
    haml :'projects/index', :locals => {:title => @project['name']}
  end

  get '/' do
    @projects = settings.config['projects']
    haml :index
  end

  def apks(project_id, project, path)
    repo_hash = ::Digest::SHA1.hexdigest(project['repo']['url'])
    dir = ::File.expand_path("tmp/repos/#{project_id}/#{repo_hash}#{path}/bin", settings.root)
    Dir.glob(dir + "/*.apk").map {|f| f.gsub(%r{^.*/}, '') }
  end
end
