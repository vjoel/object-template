require 'object-template'

Gem::Specification.new do |s|
  s.name = "object-template"
  s.version = ObjectTemplate::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.authors = ["Joel VanderWerf"]
  s.date = Time.now.strftime "%Y-%m-%d"
  s.description = "Templates for matching objects."
  s.email = "vjoel@users.sourceforge.net"
  s.extra_rdoc_files = ["README.md", "COPYING"]
  s.files = Dir[
    "README.md", "COPYING", "Rakefile",
    "lib/**/*.rb",
    "bench/**/*.rb",
    "test/**/*.rb"
  ]
  s.test_files = Dir["test/*.rb"]
  s.homepage = "https://github.com/vjoel/object-template"
  s.license = "BSD"
  s.rdoc_options = [
    "--quiet", "--line-numbers", "--inline-source",
    "--title", "object-template", "--main", "README.md"]
  s.require_paths = ["lib", "ext"]
  s.summary = "Templates for matching objects"
end
