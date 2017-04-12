require 'spec_helper'

%w(.bash_profile .gitconfig .screenrc .vimrc .zshrc .zshenv).each do |file|
  describe file("#{HOME}/#{file}") do
    it { should exist }
    it { should be_symlink }
    it { should be_mode 777 }
    it { should be_owned_by USER }
    it { should be_grouped_into USER }
    it { should be_linked_to "#{HOME}/.dotfiles/#{file}" }
  end
end

