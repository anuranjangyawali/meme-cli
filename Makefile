SRC=meme-cli

install: 
	@echo "You have to run this command as root"
	sudo cp $SRC /usr/bin/
uninstall:
	@echo "You have to run this command as root"
	sudo rm /usr/bin/$SRC
