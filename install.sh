#!/usr/bin/env sh

repo=$HOME/dotfiles.git
ssh_dir="$HOME/.ssh"
cur_dir="$PWD"
py=""
distro=""

detect_distro ()
{
    if [ -e "/etc/os-release" ];
    then
        distro_name="`cat /etc/os-release | grep -w NAME | cut -d'"' -f 2`"
    else
        echo "[X] Could not find /etc/os-release. Run again with INSTALL_OS environment variable set to appropriate OS"
        exit 1
    fi
}


clone_repo()
{
    git clone https://github.com/pwmoore/dotfiles.git $repo
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

install_pyenv()
{
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
}

install_python()
{
    install_pyenv
    pip3 install IPython
}

get_python()
{
	py=`which python`	
	if [ $? -ne 0 ];
	then
		py=`which python3`
	fi
}

install_rhel()
{
	packages="git zsh ack cmake kernel-headers-`uname -r` tmux python python-pip ctags vim"
    sudo dnf install -y $packages
    if [ $? -eq 0 ];
    then
        echo "[+] Installed $packages"
    else
        echo "[X] Could not install packages!"
        exit 1
    fi
    clone_repo
}

install_debian()
{
    linux_headers=""
    apt-cache search "linux-headers-`uname -r`" | grep linux-headers
    if [ $? -eq 0 ];
    then 
        linux_headers="linux-headers-`uname -r`"
    fi

    sudo apt update
    debs="git build-essential clang libclang-dev libncurses-dev libz-dev cmake xz-utils libpthread-workqueue-dev cmake-data python3 python3-dev python3-pip tmux vim curl universal-ctags zsh gparted openssh-server htop libbsd-dev swig libedit-dev libreadline-dev doxygen libglib2.0-dev libgraphite2-dev libxml2-dev mercurial subversion graphviz libpixman-1-dev bison flex ripgrep $linux_headers"
    sudo apt install -y $debs
    if [ $? -eq 0 ];
    then
        echo "[+] Installed $debs"
    else
        echo "[X] Could not install debs!"
        exit 1
    fi
    clone_repo
}

install_linux()
{
	case $distro in
		"Ubuntu"|"Debian GNU/Linux"|"Linux Mint")
			install_debian
			;;
		"Fedora"|"Rocky Linux"|"Red Hat Enterprise Linux")
			install_rhel
			;;
		*)
			echo "[X] $distro is not supported"
            exit 1
			;;
	esac
}

install_freebsd()
{
    pkg -y
    pkg install -y sudo python3 vim git zsh wget htop ripgrep bat rust delta duf cmake tmux bison flex py39-setuptools py39-pip
}

install_openbsd()
{
    pkg_add install python3 vim git zsh wget colorls htop ripgrep bat rust delta duf
}

install_darwin()
{
    xcode-select --install
    xcode_themes=$HOME/Library/Developer/Xcode/FontAndColorThemes
    clone_repo
    if [ -e $xcode_themes ];
    then
        cp $repo/Xcode.dvtcolortheme $xcode_themes
    else
        "[!] No $xcode_themes directory! Could not install Xcode.dvtcolortheme!"
    fi
	install_homebrew
	if [ $? -ne 0 ];
	then
		ret=$?
		echo "[!] Could not install homebrew!"
		exit $ret
	fi

	formulae="zsh reattach-to-user-namespace libimobiledevice cmake cscope ctags tmux qemu usbmuxd ripgrep go universal-ctags wget htop subversion mercurial"

	brew install $formulae
}

install_vim()
{
    mkdir -p $HOME/.vim/autoload
	mkdir -p $HOME/.vim/bundle
	mkdir -p $HOME/.vim/colors
    cp $repo/phil.vim $HOME/.vim/colors/phil.vim
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
}

install_ycm()
{
    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --clang-completer
    cd $cur_dir
}

install_tpm()
{
	mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_omz()
{ 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    cp $repo/zshrc $HOME/.zshrc
    cp $repo/phil.zsh-theme ~/.oh-my-zsh/themes
    source $HOME/.zshrc
}

install_gef()
{
    wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh
}

install_rust()
{
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
}

install_unix_tools()
{
    cargo install git-delta procs fd-find du-dust bat
    go install github.com/rs/curlie@latest
    go install github.com/muesli/duf@latest

}

install_ipsw()
{
    echo "[+] Attempting to install ipsw"
    case $os in
        Linux)
            which snap
            if [ $? -eq 0 ];
            then
                sudo snap install ipsw
            fi
            ;;
        Darwin)
            brew install blacktop/tap/ipsw
            ;;
        *)
        ;;
    esac
}

if [ ! -e $ssh_dir ];
then
    mkdir -p $ssh_dir
fi

if [ ! -e $ssh_dir/id_rsa ];
then
    ssh-keygen -f $ssh_dir/id_rsa -N ""
fi


if [ -z "$INSTALL_OS" ];
then
    os=`uname`
else
    os=$INSTALL_OS
fi

if [ $os = "Darwin" ];
then
    install_darwin
elif [ $os = "Linux" ];
then
    detect_distro
    install_linux
elif [ $os = "OpenBSD" ];
then
    install_openbsd
elif [ $os = "FreeBSD" ];
then
    install_freebsd
else
    echo "[X] Unknown OS $os"
    exit 1
fi


case $os in
	Linux)
		files=(zshrc bashrc gdbinit vimrc tmux.conf ycm_extra_conf.py)
		install_linux
        install_gef
		;;
	Darwin)
		install_darwin
        files=(zshrc bashrc profile vimrc xvimrc tmux.conf ycm_extra_conf.py)
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
	install $repo/$f
done

install_vim
install_ycm
install_tpm
install_omz
install_python
install_rust
install_unix_tools
install_ipsw
git config --global core.editor "vim"

source $HOME/.zshrc
cd $cur_dir
