module GitRDoc
  module Git
    class Repository
      def self.clone(repository_url, repository_path)
        system("git clone #{repository_url} #{repository_path}")
      end

      def self.pull(repository_path)
        system("cd #{repository_path} && git pull origin master")
      end

      def self.revision(repository_path)
        IO.popen("cd #{repository_path} && git rev-parse HEAD").read.strip
      end
    end
  end
end