rm ~/.zshrc.custom
ln -s `pwd`/.zshrc.custom ~/
if [ "`grep -c "source ~/.zshrc.custom" ~/.zshrc`" -gt "0" ]
	then
		cp gitignore ~/.gitignoreSave
		echo "source already installed ; reloading"
	else
		echo "install..."
		cp gitignore ~/.gitignoreSave
		echo "source ~/.zshrc.custom" >> ~/.zshrc
fi
source ~/.zshrc
