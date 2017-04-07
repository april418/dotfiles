require 'serverspec'
require 'yaml'
require "itamae/node"

set :backend, :exec

def node
  return @node if @node
  yaml = YAML.load_file("#{Dir.pwd}/node.yml")
  @node = Itamae::Node.new(yaml, Specinfra.backend)
end

