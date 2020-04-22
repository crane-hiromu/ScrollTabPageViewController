
# Homebrew
brew_install:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


brew_install_carthage:
	brew install carthage

# Carthage
carthage_bootstrap:
	carthage bootstrap --platform iOS --cache-builds --no-use-binaries

carthage_update:
	carthage update --platform iOS --cache-builds --no-use-binaries

carthage_build:
	carthage build --platform iOS --cache-builds --no-use-binaries
