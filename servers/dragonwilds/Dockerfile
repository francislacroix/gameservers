ARG BASE_IMAGE=steamcmd:latest

FROM $BASE_IMAGE

# Create a directory for the server
RUN mkdir -p /opt/dragonwildsserver

# Create a user to run the server and provide it access to the server directory
RUN useradd -m dragonwilds && chown -R dragonwilds:dragonwilds /opt/dragonwildsserver

# Switch to the user that will run the server
USER dragonwilds

# Clear the SteamCMD app cache to prevent issues with updates
RUN steamcmd +quit && rm -rf /home/dragonwilds/steamcmd/appcache/appinfo.vdf

# Install Dragonwilds
RUN steamcmd +force_install_dir /opt/dragonwildsserver +login anonymous +app_update 4019830 +quit

# Set the working directory
WORKDIR /opt/dragonwildsserver

# Make sure the server executable is executable
RUN chmod +x RSDragonwildsServer.sh

# Set the volume for saved content for persistent storage
VOLUME ["/opt/dragonwildsserver/RSDragonwilds/Saved"]

# Expose the ports (N and N+1 are used for the server)
EXPOSE 7777 7778

# Run the Dragonwilds server
ENTRYPOINT ["./RSDragonwildsServer.sh"]