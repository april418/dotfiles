require 'spec_helper'

%w(git).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

