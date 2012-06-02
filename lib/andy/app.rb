require 'andy'
require 'yaml'

class Andy::App < ::Sinatra::Base
  set :haml, {:format => :html5}
  set :root, Andy::ROOT_DIR
  set :views, File.expand_path('views', settings.root)
  set :config, YAML::load(open(File.expand_path('config/config.yml', settings.root)))

  get '/:repo' do
    @repo_name = params[:repo]
    repo_config = settings.config['repositories'][@repo_name]
    @repo = ::Grit::Repo.new(repo_config['url'])
    @branches = @repo.branches
    haml :repo
  end

  get '/' do
    @repos = settings.config['repositories']
    haml :index
  end
end
