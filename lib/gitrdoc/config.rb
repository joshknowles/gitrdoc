module GitRDoc
  class Config
    attr_accessor :repository_root
    attr_accessor :rdoc_root

    def initialize
      self.repository_root  = File.join(RAILS_ROOT, "tmp", "repositories")
      self.rdoc_root        = File.join(RAILS_ROOT, "tmp", "rdoc")
    end
  end
end