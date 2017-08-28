require 'spec_helper'

describe file("#{HOME}/\.rbenv/libexec/rbenv") do
  it { should be_file }
  it { should be_owned_by USER }
  it { should be_grouped_into USER }
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
end

describe file("#{HOME}/.rbenv/plugins/ruby-build") do
  it { should be_directory }
  it { should be_owned_by USER }
  it { should be_grouped_into USER }
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

