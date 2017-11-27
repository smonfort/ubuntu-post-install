#!/bin/bash

#Update and Upgrade
echo "Updating and Upgrading"
sudo apt update && sudo apt upgrade -y

sudo apt install dialog
cmd=(dialog --separate-output --checklist "Selectionner les logiciels à installer:" 22 76 16)
options=(	10 "Base - Prérequis" off
			11 "Base - Clé SSH personnelle" off
			20 "IDE - Sublime Text 3" off
			21 "IDE - Visual Studio Code" off
			22 "IDE - Android Studio" off
			23 "IDE - Eclipse for Java Developer" off
			30 "Language - Node.js" off
			31 "Language - Node.js tooling" off			
			32 "Language - Java toolchain" off
			40 "Browser - Google Chrome" off
			50 "Cloud - Docker / Docker Compose" off
			51 "Cloud - Kubernetes - Helm CLI" off
			52 "Cloud - AWS / Google CLI" off
			53 "Cloud - Kops" off
			60 "Tools - Postman" off
		)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

for choice in $choices
do
	case $choice in
		10)
			# Install Build Essentials
			echo "Installing Build Essentials"
			sudo add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y
			sudo apt update
			sudo apt install -y libssl-dev libffi-dev build-essential python-setuptools python-dev python-pip git curl ubuntu-make
			;;

		11)
			echo "Generating SSH keys"
			ssh-keygen -t rsa -b 4096
			;;

		############################################
		# IDE
		############################################

		20)
			# Install Sublime Text 3*
			echo "Installing Sublime Text"
			sudo add-apt-repository ppa:webupd8team/sublime-text-3 -y
			sudo apt update
			sudo apt install -y sublime-text-installer
			;;	
		21)
			# Install Visual Studio Code
			echo "Installing Visual Studio Code"
			umake web visual-studio-code ${HOME}/vscode
			echo "PATH=$PATH:${HOME}/vscode/bin" >> ~/.profile
			source ~/.profile
			;;
		22)
			# Install Android Studio
			echo "Installing Android Studio"
			sudo add-apt-repository ppa:paolorotolo/android-studio -y
			sudo apt update
			sudo apt install -y android-studio
			;;
		23)
			# Install Eclipse
			echo "Installing Eclipse"
			umake ide eclipse ${HOME}/eclipse
			;;

		############################################
		# Language
		############################################

		30)
			# Install Nodejs
			echo "Installing Nodejs"
			umake nodejs ${HOME}/nodejs
			;;
		31)
			# Node tools
			echo "Installing node tooling"
			npm install -g grunt gulp
			;;
		32)
			# Java toolchain : JDK 8 + Maven + Gradle
			echo "Installing JDK 8 / Maven / Gradle"
			sudo apt install python-software-properties -y
			sudo add-apt-repository ppa:webupd8team/java -y
			sudo apt update
			sudo apt install maven gradle oracle-java8-installer -y
			;;

		############################################
		# Browser
		############################################

		40)
			# Chrome
			echo "Installing Google Chrome"
			wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
			sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
			sudo apt update && sudo apt install -y google-chrome-stable
			;;

		############################################
		# Cloud
		############################################

		50) # Docker
			echo "Install docker"
			sudo apt install -y apt-transport-https ca-certificates software-properties-common
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
			sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
			sudo apt update
			sudo apt -y install docker-ce
			sudo usermod -aG docker $USER
			sudo systemctl enable docker
			# docker-compose
			echo "Install docker-compose"			
			sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
			sudo chmod +x /usr/local/bin/docker-compose
			;;

		51) # Kubernetes & Helm CLI
			echo "Install kubectl command line"
			sudo snap install kubectl --classic
			echo "Install Helm"
			curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
			;;

		52)
			# AWS CLI
			echo "Install AWS CLI"
			pip install awscli --upgrade --user

			# Google CLI
			export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
			echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
			curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
			sudo apt update && sudo apt install -y google-cloud-sdk
			;;

		53)
			# Kops
			echo "Installing kops"
			curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
			chmod +x kops-linux-amd64
			sudo mv kops-linux-amd64 /usr/local/bin/kops
			;;

		############################################
		# Tools
		############################################

		60)
			# Install Postman
			echo "Installing Postman"
			wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
			sudo tar -xvf postman.tar.gz -C /opt
			rm postman.tar.gz
			sudo ln -s /opt/Postman/Postman /usr/bin/postman			
			;;
			
	esac
done
