#  __  __       _         __ _ _
# |  \/  | __ _| | _____ / _(_) | ___
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
#
#

DOTPATH     := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
DIRECTORIES := .vim .vim/syntax bin
CANDIDATES  := $(shell find .* -maxdepth 0 -type f) $(foreach val, $(DIRECTORIES), $(shell find $(val) -maxdepth 1 -type f))
EXCLUSIONS  := .DS_Store .git .gitmodules .travis.yml $(wildcard .*.swp)
DOTFILES    := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

# same as 'all: help'
.DEFAULT_GOAL := help
.PHONY: all list deploy init update install clean help test

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), ls -dF $(val);)

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DIRECTORIES), test ! -d $(abspath $(val)) && mkdir $(abspath $(val)); :;)
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/etc/init/initialize

update: ## Fetch changes for this repo
	@git pull origin master
	@git submodule init
	@git submodule update
	@git submodule foreach git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTPATH)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## Execute serverspec
	@cd $(DOTPATH)/etc && bundle && rake spec:localhost

