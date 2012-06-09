class Andy::Project
  attr_reader :id, :name
  attr_accessor :repo

  def initialize(id, config)
    @id   = id
    @name = config['name']
  end
end
