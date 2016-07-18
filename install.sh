#!/usr/bin/env bash
install_file ()
{
	old_file=$HOME/.$1
	backup=${old_file}.bak_
	if [ -e $old_file ];
	then
		cp $old_file $backup
	fi

	cp $1 $old_file
	echo "[+] Installed $1 to $old_file"
}

install_dir()
{
	old_dir=$HOME/.$1
	backup=${old_dir}.bak
	if [ -e $old_dir ];
	then
		mv $old_dir $backup
	fi

	cp -r $1 $HOME
	mv $HOME/$1 $old_dir
	echo "[+] Installed $1 to $old_dir"
}

install()
{
	if [ -d $1 ];
	then
		install_dir $1
	else
		install_file $1
	fi
}

install_homebrew()
{
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

install_python()
{
	echo "[X] Unsupported"
}

fn_distro(){
	arch=$(uname -m)
	kernel=$(uname -r)
	if [ -f /etc/lsb-release ]; then
			os=$(lsb_release -s -d)
	elif [ -f /etc/debian_version ]; then
			os="Debian $(cat /etc/debian_version)"
	elif [ -f /etc/redhat-release ]; then
			os=`cat /etc/redhat-release`
	else
			os="$(uname -s) $(uname -r)"
	fi
}
py=""
get_python()
{
	py=`which python`	
	if [ $? -ne 0 ];
	then
		py=`which python3`
	fi
}

install_fedora()
{
	packages="ack cmake capstone capstone-devel kernel-headers-`uname -r` tmux python python-pip ctags vim"
    sudo dnf install -y $packages
    if [ $? -eq 0 ];
    then
        echo "[+] Installed $packages"
    else
        echo "[X] Could not install debs!"
    fi
}

install_debian()
{
    sudo apt update
    debs="ack-grep build-essential cmake cmake-data git libcapstone-dev libcapstone3 linux-headers-`uname -r` python3 python3-pip tmux vim"
    sudo apt install -y $debs
    if [ $? -eq 0 ];
    then
        echo "[+] Installed $debs"
    else
        echo "[X] Could not install debs!"
    fi
}

install_linux()
{
    distro=`"$py" -c "import platform; print(platform.linux_distribution()[0])"`
	case $distro in
		Ubuntu|debian)
			install_debian
			;;
		Fedora)
			install_fedora
			;;
		*)
			echo "[X] $distro is not supported"
			;;
	esac
}

install_freebsd()
{
	echo "[X] FreeBSD is not supported"
}

install_openbsd()
{
    echo "[X] OpenBSD is not supported"
}

install_darwin()
{
	install_homebrew
	if [ $? -ne 0 ];
	then
		ret=$?
		echo "[!] Could not install homebrew!"
		exit $ret
	fi

	formulae="git vim llvm libimobiledevice cmake python python3 ctags tmux qemu usbmuxd ack-grep ack"

	brew install $formulae
}

get_python

os=`$py -c "import platform; print(platform.platform().split('-')[0])"`
xcode_themes=$HOME/Library/Developer/Xcode/FontAndColorThemes
git config --global core.editor "vim"

ssh_dir="$HOME/.ssh"
if [ ! -e $ssh_dir ];
then
    mkdir -p $ssh_dir
fi

if [ ! -e $ssh_dir/id_rsa ];
then
    ssh-keygen -f $ssh_dir/id_rsa -N ""
fi

case $os in
	Linux)
		files=(bashrc gdbinit vimrc vim tmux.conf)
		install_linux
		;;
	Darwin)
		install_darwin
		files=(bashrc profile vim vimrc xvimrc tmux.conf)
        cp phil.vim $HOME/.vim/colors
        "[+] Copied OS X vim colorscheme to $HOME/.vim/colors"
		if [ -e $xcode_themes ];
		then
			cp Xcode.dvtcolortheme $xcode_themes
		else
			"[!] No $xcode_themes directory! Could not install Xcode.dvtcolortheme!"
		fi
		;;
	FreeBSD)
		install_freebsd
		files=(bashrc profile gdbinit vimrc vim tmux.conf)
		;;

	*)
	;;
esac

for f in ${files[@]}
do
	install $f
done

source $HOME/.bashrc
