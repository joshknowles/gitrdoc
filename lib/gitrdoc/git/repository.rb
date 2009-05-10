module GitRDoc
  module Git
    class Repository
      def self.clone(repository_url, repository_path)
        system("git clone #{repository_url} #{repository_path}")
      end

      def self.pull(repository_path)
        system("cd #{repository_path} && git pull origin master")
      end

      def self.revision(repository_path, reference_name)
        if reference_name == "master"
          IO.popen("cd #{repository_path} && git rev-parse origin/master").read.strip
        else
          revision = IO.popen("cd #{repository_path} && git rev-parse #{reference_name}").read.strip
          revision.starts_with?(reference_name) ? nil : revision
        end
      end

      def self.reset(repository_path, reference_name)
        if reference_name == "master"
          system("cd #{repository_path} && git reset --hard origin/master")
        else
          system("cd #{repository_path} && git reset --hard #{reference_name}")
        end
      end
    end
  end
end