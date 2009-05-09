require "rdoc"
require "rdoc/rdoc"

module GitRDoc
  module RDoc
    def self.generate(src_path, dest_path, title, url)
      options = []
      options << "-q"                     # quite
      options << "--op=\"#{dest_path}\""  # output directory
      options << "-S"                     # inline source
      options << "--title=\"#{title}\""   # title
      options << "--webcvs=\"#{url}\""    # URL
      options << "--format=html"          # HTML format
      options << "--template=hanna"       # hanna template

      system("cd #{src_path} && rdoc #{options.join(' ')}")
    end
  end
end