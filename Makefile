SRC=meme-cli
CONFIG=cred.json

install: 
	@echo "You have to run this command as root"
	sudo cp ${SRC} /usr/bin/
	@echo "Writing config file"
	cp example-cred.json ${XDG_CONFIG_HOME}/${CONFIG}

uninstall:
	@echo "You have to run this command as root"
	sudo rm /usr/bin/${SRC}
	@echo "Cleaning"
	rm ${XDG_CONFIG_HOME}/${CONFIG}
