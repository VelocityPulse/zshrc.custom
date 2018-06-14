rm ~/.zshrc.custom
ln -s `pwd`/.zshrc.custom ~/
echo "source ~/.zshrc.custom" >> ~/.zshrc
source ~/.zshrc

