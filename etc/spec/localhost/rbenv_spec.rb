require 'spec_helper'

%w(gcc gcc-c++ openssl-devel readline-devel zlib-devel libyaml-devel).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe command('which rbenv') do
  its(:stdout) { should match %r[#{HOME}/\.rbenv/libexec/rbenv] }
end

describe file("#{HOME}/.bash_profile") do
  its(:content) { should match(%r[^\s*export PATH="\$HOME/\.rbenv/bin:\$PATH"$]) }
  its(:content) { should match(%r[^\s*eval "\$\(\$HOME/\.rbenv/bin/rbenv init -\)"$]) }
end

describe file("#{HOME}/.zshenv") do
  its(:content) { should match(%r[^\s*export PATH="\$HOME/\.rbenv/bin:\$PATH"$]) }
  its(:content) { should match(%r[^\s*eval "\$\(\$HOME/\.rbenv/bin/rbenv init -\)"$]) }
end

describe file("#{HOME}/.rbenv/plugins") do
  it { should be_directory }
  it { should be_owned_by USER }
  it { should be_grouped_into USER }
  it { should be_mode 775 }
end

describe file("#{HOME}/.rbenv/plugins/ruby-build") do
  it { should be_directory }
  it { should be_owned_by USER }
  it { should be_grouped_into USER }
  it { should be_mode 755 }
end

#%w(2.2.2).each do |version|
#  describe command("rbenv versions | grep #{version}") do
#    its(:stdout) { should match(/#{Regexp.escape(version)}/) }
#  end
#end
#
#describe command('rbenv global') do
#  its(:stdout) { should match(/2.2.2/) }
#end

