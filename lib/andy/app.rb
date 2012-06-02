require 'andy'
require 'yaml'

class Andy::App < ::Sinatra::Base
  set :haml, {:format => :html5}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))
  set :repos, settings.config['repositories']

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
end
