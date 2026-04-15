SRC=meme-cli

install: 
	@echo "Installing script..."
	install -m 755 ./${SRC} /usr/local/bin/${SRC}

uninstall:
	@echo "Uninstalling script..."
	rm -f /usr/local/bin/${SRC}
clean:
	@echo "Removing .json response, and .png files"
	rm -f response.json
