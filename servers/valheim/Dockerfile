ARG BASE_IMAGE=steamcmd:latest

FROM $BASE_IMAGE

# Arguments require to build the image
ARG SERVER_NAME=servername
ARG SERVER_PASSWORD=password
ARG SERVER_BASE_PORT=2456
ARG SERVER_PORT_RANGE=2456-2457
ARG WORLD_NAME=worldname

ENV SERVER_NAME=${SERVER_NAME}}
ENV SERVER_PASSWORD=${SERVER_PASSWORD}}
ENV SERVER_BASE_PORT=${SERVER_BASE_PORT}}
ENV WORLD_NAME=${WORLD_NAME}}

# Create a directory for the server
RUN mkdir -p /opt/valheim

# Create a user to run the server and provide it access to the server directory
RUN useradd -m valheim && chown -R valheim:valheim /opt/valheim

# Switch to the user that will run the server
USER valheim

# Clear the SteamCMD app cache to prevent issues with updates
RUN steamcmd +quit && rm -rf ~/.local/share/Steam/appcache/appinfo.vdf

# Install Valheim
RUN steamcmd +force_install_dir /opt/valheim +login anonymous +app_update 896660 +quit

# Set the working directory
WORKDIR /opt/valheim

# Update the start server command in start_server.sh
RUN sed -i "s/My server/\$SERVER_NAME/g" start_server.sh \
    && sed -i "s/2456/\$SERVER_BASE_PORT/g" start_server.sh \
    && sed -i "s/Dedicated/\$WORLD_NAME/g" start_server.sh \
    && sed -i "s/secret/\$SERVER_PASSWORD/g" start_server.sh

# Make sure the server executable is executable
RUN chmod +x start_server.sh

# Set the volume for saved content for persistent storage
VOLUME ["/home/valheim/.config/unity3d/IronGate/Valheim/"]

# Expose the ports (N and N+1 are used for the server)
EXPOSE ${SERVER_PORT_RANGE}

# Run the Valheim server
ENTRYPOINT ["./start_server.sh"]