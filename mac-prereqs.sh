# First install Homebrew if you don't have it already with a:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install python
brew install python
# Install Node & NPM
brew install nodejs
# Install kubectl
brew install kubectl
# Install the CDK
npm install -g aws-cdk
# Install fluxctl
brew install fluxctl
# Install Helm
brew install helm
# Install the AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /