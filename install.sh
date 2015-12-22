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

install_ubuntu()
{
    debs="ack-grep build-essential cmake cmake-data git libcapstone-dev libcapstone3 linux-headers-`uname -r` python3 python3-pip tmux vim"
    sudo apt-get install $debs > /dev/null
    if [ $? -eq 0 ];
    then
        echo "[+] Installed $debs"
    else
        echo "[X] Could not install debs!"
    fi
}

install_linux()
{
	distro=`cat /etc/os-release | grep NAME | grep -v CPE_NAME | grep -v PRETTY_NAME | cut -d '=' -f 2 | tr -d \"`
	case $distro in
		Ubuntu)
			install_ubuntu
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

os=`uname`
xcode_themes=$HOME/Library/Developer/Xcode/FontAndColorThemes

case $os in
	Linux)
		install_linux
		files=(bashrc gdbinit vimrc vim tmux.conf)
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
		files=(bashrc gdbinit vimrc vim tmux.conf)
		;;

	*)
	;;
esac

for f in ${files[@]}
do
	install $f
done

source $HOME/.bashrc
