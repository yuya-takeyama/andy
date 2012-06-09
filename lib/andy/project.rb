class Andy::Project
  attr_reader :id, :name, :keystore_config
  attr_accessor :repo

  def initialize(id, config)
    @id              = id
    @name            = config['name']
    @keystore_config = config['keystore'] || {}
  end

  def absolute_path
    "/projects/#{@id}"
  end
end
