#!/bin/bash
################################################################################
# Original Author: Euno DevTeam
# Github: https://github.com/Euno/install-wallet
# Web: https://euno.co/
# Version: 1.0
#
# Usage: ./install-wallet.sh 
# 
# Tested on:
# Ubuntu 16.04
# Raspberry PI 2 & 3 with Raspbian Stretch
#
################################################################################

# Backup wallet.dat

    if [[ -d ~/.euno ]]; then
          cd ~/.euno
          cp wallet.dat walletSAVE.save 2>/dev/null && cd
    fi

show_menu(){
	NORMAL=`echo "\033[m"`
    	MENU=`echo "\033[36m"` #Blue
    	NUMBER=`echo "\033[33m"` #yellow
    	FGRED=`echo "\033[41m"`
    	RED_TEXT=`echo "\033[31m"`
    	YELLOW=`echo "\033[33m"`

	echo ""
    	echo -e "${MENU}** EUNO - A privacy based cryptocurrency | https://euno.co/ **${NORMAL}"
    	echo ""
    	echo -e "${MENU}****************************************************${NORMAL}"
    	echo -e "${MENU}**${NUMBER} 1)${MENU} Install EUNO CLI Wallet on Ubuntu LTS 16.04 **${NORMAL}"
    	echo -e "${MENU}**${NUMBER} 2)${MENU} Install EUNO GUI Wallet on Ubuntu LTS 16.04 **${NORMAL}"
    	echo -e "${MENU}**${NUMBER} 3)${MENU} Install EUNO CLI Wallet on Raspberry Pi     **${NORMAL}"
    	echo -e "${MENU}**${NUMBER} 4)${MENU} Install EUNO GUI Wallet on Raspberry Pi     **${NORMAL}"
    	echo -e "${MENU}****************************************************${NORMAL}"
    	echo -e "${YELLOW}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    	read opt
}
function option_picked() {
	COLOR='\033[01;33m' # bold yellow
	RESET='\033[00;00m' # normal white
	MESSAGE=${@:-"${RESET}Error: No message passed"}
	echo -e "${COLOR}${MESSAGE}${RESET}"
}


euno_ubuntu_cli(){
	option_picked "Install EUNO CLI Wallet on Ubuntu LTS 16.04";
	isOS=$(cat /etc/os-release 2>/dev/null |grep ^ID= | awk -F= '{print $2}')
	if [[ "$isOS" == "ubuntu" ]];
	   then
		echo -e "${MENU}** Install all necessary packages for building EUNO ** ${NORMAL}"
		sudo apt-get install -y automake dnsutils
		sudo apt-get install -y build-essential libssl-dev libboost-all-dev git
		sudo apt-get install -y libdb5.3++-dev libminiupnpc-dev screen autoconf
		sudo apt-get install -y unzip

		lineSwap=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)

		if [ $lineSwap -le 1200000 ] ;
 		   then
   			echo -e "${MENU} ** Not enought RAM, so creating a 2 Gb swap file ** ${NORMAL}"
   			sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
   			sudo /sbin/mkswap /var/swap.1
   			sudo chmod 600 /var/swap.1
   			sudo /sbin/swapon /var/swap.1
    			sudo echo "/var/swap.1 swap swap defaults 0 0" >> /etc/fstab
		fi
		
		echo ""
		echo -e "${MENU} ** Downloading EUNO source code from Github ** ${NORMAL}"
		cd ~
		
		if [[ -d ~/eunowallet ]]; then
			cd ~/eunowallet
			echo -e "${MENU} ** Git pull ** ${NORMAL}"
			git pull
		else
			git clone https://github.com/Euno/eunowallet.git
		fi

		echo ""
		echo -e "${MENU} ** Compiling LevelDB ** ${NORMAL}"
		cd ~/eunowallet/src/leveldb
		make clean
		chmod +x build_detect_platform
		make libleveldb.a libmemenv.a

		echo ""
		echo -e "${MENU} ** Compiling SECP256 ** ${NORMAL}"
		cd ~/eunowallet/src/secp256k1
		make clean
		chmod +x autogen.sh
		./autogen.sh
		./configure --prefix=/usr
		make
		sudo make install

		echo ""
		echo -e "${MENU} ** Compiling EUNO Wallet (may take a while) ** ${NORMAL}"
		mkdir ~/.euno/ 2>/dev/null
		cd ~/eunowallet/src/
		sudo make -f makefile.unix
		cp eunod ~/eunowallet/;

		if [[ -f ~/.euno/euno.conf ]]; then
			echo -e "${MENU} ** euno.conf already exists! ** ${NORMAL}";
		   else
			rpcuservar=$(date +%s | sha256sum | base64 | head -c 32)
			rpcpassvar=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
			echo ""
			echo -e "${MENU} ** Creating default euno.conf file! ** ${NORMAL}"
			echo "rpcallowip=127.0.0.1" >> ~/.euno/euno.conf
			echo "rpcuser=${rpcuservar}" >> ~/.euno/euno.conf
			echo "rpcpassword=${rpcpassvar}" >> ~/.euno/euno.conf
			echo "listen=1" >> ~/.euno/euno.conf
			echo "server=1" >> ~/.euno/euno.conf
			curl https://euno.co/nodes.txt >> ~/.euno/euno.conf
		fi
	   else
		echo ""
		echo -e "${RED_TEXT}OS is not Ubuntu ${NORMAL}";
		exit 1;
	fi
	
	if [[ -f ~/eunowallet/eunod ]]; then
		echo ""
		echo -e "${MENU} ** Done! ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Daemon: ~/eunowallet/eunod ** ${NORMAL}"
		echo -e "${MENU} ** Euno Data Folder: cd ~/.euno/ ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Default Config File: cd ~/.euno/euno.conf ** ${NORMAL}"
		echo -e "${YELLOW} ** To Start: ~/eunowallet/eunod -daemon -start ** ${NORMAL}"
		exit 0;
	else
		echo ""
		echo -e "${RED_TEXT}ERROR! Scroll up for details. ${NORMAL}"
		exit 1;

	fi
}

euno_ubuntu_gui(){
	option_picked "Install EUNO GUI Wallet on Ubuntu LTS 16.04";
	isOS=$(cat /etc/os-release 2>/dev/null |grep ^ID= | awk -F= '{print $2}')
	if [[ "$isOS" == "ubuntu" ]];
	   then
		echo -e "${MENU}** Install all necessary packages for building EUNO ** ${NORMAL}"
		sudo apt-get install -y automake dnsutils
		sudo apt-get install -y build-essential libssl-dev libboost-all-dev git
		sudo apt-get install -y libdb5.3++-dev libminiupnpc-dev screen autoconf
		sudo apt-get install -y unzip
		sudo apt-get install -y qt5-default qttools5-dev-tools

		lineSwap=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)

		if [ $lineSwap -le 1200000 ] ;
 		   then
   			echo -e "${MENU} ** Not enought RAM, so creating a 2 Gb swap file ** ${NORMAL}"
   			sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
   			sudo /sbin/mkswap /var/swap.1
   			sudo chmod 600 /var/swap.1
   			sudo /sbin/swapon /var/swap.1
    			sudo echo "/var/swap.1 swap swap defaults 0 0" >> /etc/fstab
		fi
		
		echo ""
		echo -e "${MENU} ** Downloading EUNO source code from Github ** ${NORMAL}"
		cd ~

                if [[ -d ~/eunowallet ]]; then
                        cd ~/eunowallet
                        echo -e "${MENU} ** Git pull ** ${NORMAL}"
                        git pull
                else
                        git clone https://github.com/Euno/eunowallet.git
                fi

		echo ""
		echo -e "${MENU} ** Compiling LevelDB ** ${NORMAL}"
		cd ~/eunowallet/src/leveldb
		make clean
		chmod +x build_detect_platform
		make libleveldb.a libmemenv.a

		echo ""
		echo -e "${MENU} ** Compiling SECP256 ** ${NORMAL}"
		cd ~/eunowallet/src/secp256k1
		make clean
		chmod +x autogen.sh
		./autogen.sh
		./configure --prefix=/usr
		make
		sudo make install

		echo ""
		echo -e "${MENU} ** Compiling EUNO Wallet (may take a while) ** ${NORMAL}"
		mkdir ~/.euno/ 2>/dev/null
		cd ~/eunowallet/
		qmake -o Makefile euno.pro
		make

		if [[ -f ~/.euno/euno.conf ]]; then
			echo -e "${MENU} ** euno.conf already exists! ** ${NORMAL}";
		   else
			rpcuservar=$(date +%s | sha256sum | base64 | head -c 32)
			rpcpassvar=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
			echo ""
			echo -e "${MENU} ** Creating default euno.conf file! ** ${NORMAL}"
			echo "rpcallowip=127.0.0.1" >> ~/.euno/euno.conf
			echo "rpcuser=${rpcuservar}" >> ~/.euno/euno.conf
			echo "rpcpassword=${rpcpassvar}" >> ~/.euno/euno.conf
			echo "listen=1" >> ~/.euno/euno.conf
			echo "server=1" >> ~/.euno/euno.conf
			curl https://euno.co/nodes.txt >> ~/.euno/euno.conf
		fi
	   else
		echo ""
		echo -e "${RED_TEXT}OS is not Ubuntu ${NORMAL}";
		exit 1;
	fi
	
	if [[ -f ~/eunowallet/euno-qt ]]; then
		echo ""
		echo -e "${MENU} ** Done! ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Daemon: ~/eunowallet/euno-qt ** ${NORMAL}"
		echo -e "${MENU} ** Euno Data Folder: cd ~/.euno/ ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Default Config File: cd ~/.euno/euno.conf ** ${NORMAL}"
		echo -e "${YELLOW} ** To Start: ~/eunowallet/euno-qt ** ${NORMAL}"
		exit 0;
	else
		echo ""
		echo -e "${RED_TEXT}ERROR! Scroll up for details. ${NORMAL}"
		exit 1;

	fi
}

euno_raspberry_cli(){
	option_picked "Install EUNO CLI Wallet on Raspberry Pi";
	isOS=$(cat /etc/os-release 2>/dev/null |grep ^ID= | awk -F= '{print $2}')
	if [[ "$isOS" == "raspbian" ]];
	   then
		echo -e "${MENU}** Install all necessary packages for building EUNO ** ${NORMAL}"
		sudo apt-get install -y automake dnsutils
		sudo apt-get install -y build-essential libboost-all-dev git
		sudo apt-get install -y libdb5.3++-dev libminiupnpc-dev screen autoconf
		sudo apt-get install -y unzip

    		echo -e "${MENU}** Raspberry Pi detected; modifying libssl-dev repository ** ${NORMAL}"
    		sudo apt-get remove -y libssl-dev
    		sudo apt-get install -y zlib1g-dev
    		sudo sed -i -e 's/stretch/jessie/g' /etc/apt/sources.list
    		sudo apt-get -y update
    		sudo apt-get install -y libssl-dev
    		sudo sed -i -e 's/jessie/stretch/g' /etc/apt/sources.list
  	        sudo apt-get -y update

		lineSwap=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)

		if [ $lineSwap -le 1200000 ] ;
 		   then
   			echo -e "${MENU} ** Not enought RAM, so creating a 1 Gb swap file ** ${NORMAL}"
   			sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
   			sudo /sbin/mkswap /var/swap.1
   			sudo chmod 600 /var/swap.1
   			sudo /sbin/swapon /var/swap.1
    			sudo echo "/var/swap.1 swap swap defaults 0 0" >> /etc/fstab
		fi
		
		echo ""
		echo -e "${MENU} ** Downloading EUNO source code from Github ** ${NORMAL}"
		cd ~

                if [[ -d ~/eunowallet ]]; then
                        cd ~/eunowallet
                        echo -e "${MENU} ** Git pull ** ${NORMAL}"
			git pull
                else
                        git clone https://github.com/Euno/eunowallet.git
                fi

		echo ""
		echo -e "${MENU} ** Compiling LevelDB ** ${NORMAL}"
		cd ~/eunowallet/src/leveldb
		make clean
		chmod +x build_detect_platform
		make libleveldb.a libmemenv.a

		echo ""
		echo -e "${MENU} ** Compiling SECP256 ** ${NORMAL}"
		cd ~/eunowallet/src/secp256k1
		make clean
		chmod +x autogen.sh
		./autogen.sh
		./configure --prefix=/usr
		make
		sudo make install

		echo ""
		echo -e "${MENU} ** Compiling EUNO Wallet (may take a while) ** ${NORMAL}"
		mkdir ~/.euno/ 2>/dev/null
		cd ~/eunowallet/src/
		sudo make -f makefile.unix
		cp eunod ~/eunowallet/;

		if [[ -f ~/.euno/euno.conf ]]; then
			echo -e "${MENU} ** euno.conf already exists! ** ${NORMAL}";
		   else
			rpcuservar=$(date +%s | sha256sum | base64 | head -c 32)
			rpcpassvar=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
			echo ""
			echo -e "${MENU} ** Creating default euno.conf file! ** ${NORMAL}"
			echo "rpcallowip=127.0.0.1" >> ~/.euno/euno.conf
			echo "rpcuser=${rpcuservar}" >> ~/.euno/euno.conf
			echo "rpcpassword=${rpcpassvar}" >> ~/.euno/euno.conf
			echo "listen=1" >> ~/.euno/euno.conf
			echo "server=1" >> ~/.euno/euno.conf
			curl https://euno.co/nodes.txt >> ~/.euno/euno.conf
		fi
	   else
		echo ""
		echo -e "${RED_TEXT}OS is not Raspbian ${NORMAL}";
		exit 1;
	fi
	
	if [[ -f ~/eunowallet/eunod ]]; then
		echo ""
		echo -e "${MENU} ** Done! ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Daemon: ~/eunowallet/eunod ** ${NORMAL}"
		echo -e "${MENU} ** Euno Data Folder: cd ~/.euno/ ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Default Config File: cd ~/.euno/euno.conf ** ${NORMAL}"
		echo -e "${YELLOW} ** To Start: ~/eunowallet/eunod -daemon -start ** ${NORMAL}"
		exit 0;
	else
		echo ""
		echo -e "${RED_TEXT}ERROR! Scroll up for details. ${NORMAL}"
		exit 1;

	fi
}

euno_raspberry_gui(){
option_picked "Install EUNO GUI Wallet on Raspberry Pi";
	isOS=$(cat /etc/os-release 2>/dev/null |grep ^ID= | awk -F= '{print $2}')
	if [[ "$isOS" == "raspbian" ]];
	   then
		echo -e "${MENU}** Install all necessary packages for building EUNO ** ${NORMAL}"
		sudo apt-get install -y automake dnsutils
		sudo apt-get install -y build-essential libboost-all-dev git
		sudo apt-get install -y libdb5.3++-dev libminiupnpc-dev screen autoconf
		sudo apt-get install -y unzip
		sudo apt-get install -y qt5-default qttools5-dev-tools

    		echo -e "${MENU}** Raspberry Pi detected; modifying libssl-dev repository ** ${NORMAL}"
    		sudo apt-get remove -y libssl-dev
    		sudo apt-get install -y zlib1g-dev
    		sudo sed -i -e 's/stretch/jessie/g' /etc/apt/sources.list
    		sudo apt-get -y update
    		sudo apt-get install -y libssl-dev
    		sudo sed -i -e 's/jessie/stretch/g' /etc/apt/sources.list
  	        sudo apt-get -y update

		lineSwap=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)

		if [ $lineSwap -le 1200000 ] ;
 		   then
   			echo -e "${MENU} ** Not enought RAM, so creating a 1 Gb swap file ** ${NORMAL}"
   			sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
   			sudo /sbin/mkswap /var/swap.1
   			sudo chmod 600 /var/swap.1
   			sudo /sbin/swapon /var/swap.1
    			sudo echo "/var/swap.1 swap swap defaults 0 0" >> /etc/fstab
		fi
		
		echo ""
		echo -e "${MENU} ** Downloading EUNO source code from Github ** ${NORMAL}"
		cd ~

                if [[ -d ~/eunowallet ]]; then
                        cd ~/eunowallet
                        echo -e "${MENU} ** Git pull ** ${NORMAL}"
			git pull
                else
                        git clone https://github.com/Euno/eunowallet.git
                fi

		echo ""
		echo -e "${MENU} ** Compiling LevelDB ** ${NORMAL}"
		cd ~/eunowallet/src/leveldb
		make clean
		chmod +x build_detect_platform
		make libleveldb.a libmemenv.a

		echo ""
		echo -e "${MENU} ** Compiling SECP256 ** ${NORMAL}"
		cd ~/eunowallet/src/secp256k1
		make clean
		chmod +x autogen.sh
		./autogen.sh
		./configure --prefix=/usr
		make
		sudo make install

		echo ""
		echo -e "${MENU} ** Compiling EUNO Wallet (may take a while) ** ${NORMAL}"
		mkdir ~/.euno/ 2>/dev/null
		cd ~/eunowallet/
		qmake -o Makefile euno.pro
		make

		if [[ -f ~/.euno/euno.conf ]]; then
			echo -e "${MENU} ** euno.conf already exists! ** ${NORMAL}";
		   else
			rpcuservar=$(date +%s | sha256sum | base64 | head -c 32)
			rpcpassvar=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
			echo ""
			echo -e "${MENU} ** Creating default euno.conf file! ** ${NORMAL}"
			echo "rpcallowip=127.0.0.1" >> ~/.euno/euno.conf
			echo "rpcuser=${rpcuservar}" >> ~/.euno/euno.conf
			echo "rpcpassword=${rpcpassvar}" >> ~/.euno/euno.conf
			echo "listen=1" >> ~/.euno/euno.conf
			echo "server=1" >> ~/.euno/euno.conf
			curl https://euno.co/nodes.txt >> ~/.euno/euno.conf
		fi
	   else
		echo ""
		echo -e "${RED_TEXT}OS is not Ubuntu ${NORMAL}";
		exit 1;
	fi
	
	if [[ -f ~/eunowallet/euno-qt ]]; then
		echo ""
		echo -e "${MENU} ** Done! ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Daemon: ~/eunowallet/euno-qt ** ${NORMAL}"
		echo -e "${MENU} ** Euno Data Folder: cd ~/.euno/ ** ${NORMAL}"
		echo -e "${MENU} ** Euno Wallet Default Config File: cd ~/.euno/euno.conf ** ${NORMAL}"
		echo -e "${YELLOW} ** To Start: ~/eunowallet/euno-qt ** ${NORMAL}"
		
		cp ~/eunowallet/contrib/Euno.desktop ~/Desktop/
		sudo cp ~/eunowallet/src/qt/res/icons/eunoicon.png /usr/share/pixmaps/eunoicon.png
		exit 0;
	else
		echo ""
		echo -e "${RED_TEXT}ERROR! Scroll up for details. ${NORMAL}"
		exit 1;

	fi
}

clear
show_menu
while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then 
            exit;
    else
        case $opt in
        1) clear;
	    euno_ubuntu_cli;
            ;;

        2) clear;
	    euno_ubuntu_gui;
            ;;

        3) clear;
            euno_raspberry_cli;
            ;;

        4) clear;
	    euno_raspberry_gui;
            ;;

        x)exit;
        ;;

        \n)exit;
        ;;

        *)clear;
        option_picked "Pick an option from the menu";
        show_menu;
        ;;
    esac
fi
done


