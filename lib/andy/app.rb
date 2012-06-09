# coding: utf-8
require 'andy'
require 'yaml'
require 'digest/sha1'

class Andy::App < ::Sinatra::Base
  register Padrino::Helpers

  set :haml, {:format => :html5, :encoding => 'utf-8', :escape_html => true}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))
  set :repos, settings.config['repositories']

  ['/projects/:project_id', '/projects/:project_id/*'].each do |path|
    before path do
      config        = settings.config['projects'][params[:project_id]]
      @project      = ::Andy::Project.new(params[:project_id], config)
      @project.repo = ::Andy::Repository::Svn.new(config['repo']['url'])
      @repo         = @project.repo
    end
  end

  get '/projects/:project_id/*/:file.apk' do
    @path = "/" + params['splat'].join('/')
    dir = ::File.expand_path("tmp/repos/#{@project.id}/#{@repo.hash}#{@path}/bin", settings.root)
    send_file "#{dir}/#{params[:file]}.apk", :type => 'application/vnd.android.package-archive'
  end

  get '/projects/:project_id/*' do
    @path = "/" + params['splat'].join('/')
    if params['build']
      builder = ::Andy::ApkBuilder.new
      builder.build(@project, @path, settings.config['android']['sdk_dir'])
      redirect "/projects/#{@project.id}#{@path}"
    end
    @apks = apks(@project, @path)
    haml :'projects/branch', :locals => {:title => @project.name + " - " + @path}
  end

  get '/projects/:project_id' do
    haml :'projects/index', :locals => {:title => @project.name}
  end

  get '/' do
    @projects = settings.config['projects'].map {|id, config| ::Andy::Project.new(id, config) }
    haml :index
  end

  def apks(project, path)
    repo = project.repo
    dir = ::File.expand_path("tmp/repos/#{project.id}/#{repo.hash}#{path}/bin", settings.root)
    Dir.glob(dir + "/*.apk").map {|f| f.gsub(%r{^.*/}, '') }
  end
end
