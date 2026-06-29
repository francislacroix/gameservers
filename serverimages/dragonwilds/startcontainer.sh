# Take the repository name as an argument
REPO_NAME=$1

docker pull $REPO_NAME/dragonwilds:latest
docker run -d --name dragonwilds -p 7777:7777/udp -p 7778:7778/udp $REPO_NAME/dragonwilds:latest --restart unless-stopped