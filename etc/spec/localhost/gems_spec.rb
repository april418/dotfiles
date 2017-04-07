require 'spec_helper'

%w(bundler).each do |pkg|
  describe package(pkg) do
    it { should be_installed.by(:gem) }
  end
end

