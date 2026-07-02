



docker run -d --name dragonwilds \
    -p 7777:7777/udp \
    -p 7778:7778/udp \
    --restart unless-stopped \
    -v /gameservermounts/dragonwilds:/opt/dragonwildsserver/RSDragonwilds/Saved:rw \  
    $REPO_NAME/dragonwilds:latest 