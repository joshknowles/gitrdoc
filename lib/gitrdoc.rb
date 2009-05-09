require "gitrdoc/config"
require "gitrdoc/git"
require "gitrdoc/rdoc"

module GitRDoc
  def self.configure(config = GitRDoc::Config.new)
    yield config if block_given?
    @@config = config
  end

  def self.config
    @@config ||= GitRDoc::Config.new
  end

  def self.method_missing(method, *args)
    if (config.respond_to?(method))
      config.send(method, *args)
    else
      super
    end
  end
end