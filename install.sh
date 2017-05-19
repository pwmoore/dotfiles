#!/usr/bin/env bash

repo_dir="$HOME/git/dotfiles"
install_repo()
{
    
    mkdir -p $HOME/git
    cd $HOME/git
    git clone https://github.com/pwmoore/dotfiles.git
}

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
	packages="git ack cmake capstone capstone-devel kernel-headers-`uname -r` tmux python python-pip ctags vim"
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
    debs="git ack-grep build-essential libclang-3.9-dev libncurses-dev libz-dev cmake xz-utils libpthread-workqueue-dev cmake-data libcapstone-dev libcapstone3 linux-headers-`uname -r` python-dev python3 python3-dev python3-pip tmux vim zsh liblua5.1-0-dev liblua5.2-dev liblua5.3-dev lua5.1 lua5.2 lua5.3 curl"
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
		Ubuntu|debian|LinuxMint)
			install_debian
			;;
		Fedora)
			install_fedora
			;;
		*)
			echo "[X] $distro is not supported"
			;;
	esac
    install_repo
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
    xcode-select --install
	install_homebrew
	if [ $? -ne 0 ];
	then
		ret=$?
		echo "[!] Could not install homebrew!"
		exit $ret
	fi

	formulae="git vim llvm libimobiledevice cmake python python3 ctags tmux qemu usbmuxd ack-grep ack"

	brew install $formulae
    install_repo
}

install_vim()
{
    mkdir -p $HOME/.vim/autoload
	mkdir -p $HOME/.vim/bundle
	mkdir -p $HOME/.vim/colors
    cp philcolors.vim $HOME/.vim/colors
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
}

install_ycm()
{
    cwd=$PWD
    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --clang-completer
    cd $cwd
}

install_color_coded()
{
    cwd=$PWD
    cd ~/.vim/bundle/color_coded
	mkdir build && cd build
	cmake ..
	make && make install
	make clean && make clean_clang
    cd $cwd
}

install_tpm()
{
	mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_omz()
{ 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    cp zshrc $HOME/.zshrc
    cp phil.zsh-theme ~/.oh-my-zsh/themes
    source $HOME/.zshrc
}

get_python
cur_dir="$PWD"

os=`$py -c "import platform; print(platform.platform().split('-')[0])"`
xcode_themes=$HOME/Library/Developer/Xcode/FontAndColorThemes

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
		files=(zshrc bashrc gdbinit vimrc tmux.conf)
		install_linux
		;;
	Darwin)
		install_darwin
		files=(zshrc bashrc profile vimrc xvimrc tmux.conf)
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
		files=(bashrc profile gdbinit vimrc tmux.conf)
		;;

	*)
	;;
esac

for f in ${files[@]}
do
	install $f
done

git config --global core.editor "vim"
install_vim
install_ycm
#install_color_coded
install_tpm
install_omz

source $HOME/.zshrc
cd $cur_dir
