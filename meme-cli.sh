# Copyright (c) 2026 Anuranjan Gyawali
# Licensed under the MIT License

#!/bin/sh

#set -x # for debugging information

response_file=./response.json
cred_file=./example-cred.json

username=$(jq -r '.username' "$cred_file")
password=$(jq -r '.password' "$cred_file")

# create the $response_file if it doesn't exist
[ ! -f "$response_file" ] && curl -s 'https://api.imgflip.com/get_memes' > "$response_file"

usage() {
	echo "Usage: meme-cli [OPTION]"
	echo ""
	echo "-l, --list			lists all the memes available"
	echo "-o, --output <filename>		specify output file name"
	echo "-h, --help			prints usage"

}

[ $# -eq 0 ] && usage && exit 0

while [ $# -gt 0 ]
do
	case "$1" in
		--help|-h)
			usage
			shift
			;;
		--list|-l)
			jq -r '.data.memes[].name' $response_file
			shift
			;;
		--output|-o)
			outputfile=$2
			[ -z "$2" ] && usage && exit 0
			shift 2
			;;
		*) 
			echo "Invalid Option $1"
			echo ""
			usage
			exit 0	
			;;
	esac

done

[ -z "$outputfile" ] &&  exit 1

meme=$(jq -r '.data.memes[].name' "$response_file" | fzf) # fzf to fuzzy search/select the meme
[ -z "$meme" ] && exit 0

# query out the meme id & number of text boxes
meme_id=$(jq  --arg nameofDememe "$meme" -r '.data.memes[] | select(.name == $nameofDememe) | .id' "$response_file") 
text_boxes=$(jq --arg nameofDememe "$meme" -r '.data.memes[] | select(.name == $nameofDememe) | .box_count' "$response_file")

# produces '&' seperated key-value pairs. url encoded data of data to be POSTed

i=0
urlencdata=""
while [ "$text_boxes" -gt 0 ] 
do 
	printf "enter text%d: "  "$i"
	read caption
	encoded=$(printf "%s" "$caption" | jq -Rrs @uri)
	urlencdata="$urlencdata&boxes[$i][text]=$encoded"
	i=$(($i+1))
	text_boxes=$(($text_boxes-1))
done


# remove the leading '&' 
# there's probably a better way to do this (shell expansion)
# urlencdata=$(echo $urlencdata | sed 's/^&//')
urlencdata=${urlencdata#&}

# post json response & the image json response
response=$(curl -s --request POST \
		--data "template_id=$meme_id&username=$username&password=$password" \
		--data  "$urlencdata" \
		'https://api.imgflip.com/caption_image')

# print the img url & image page url
echo $response | jq -r '.data.url,.data.page_url' 

# save the meme
img_url=$(echo $response | jq -r '.data.url')
curl -s "$img_url" -o "${outputfile}.png"

