# Use the official Ubuntu 24.04 image as the base, to provide general compatibility
FROM ubuntu:24.04

# Set as non-interactive
ARG DEBIAN_FRONTEND=noninteractive

# Install SteamCMD dependencies
RUN apt-get update -y \
    && dpkg --add-architecture i386 \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository multiverse \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Prepare answer for license agreement
RUN echo steam steam/question select "I AGREE" | debconf-set-selections 

# Install SteamCMD
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends steamcmd \ 
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Update steamcmd (apt-get install doesn't always install latest) and clear the SteamCMD app cache to prevent issues with updates
RUN steamcmd +quit && rm -rf /root/.local/share/Steam/appcache/appinfo.vdf

# Set default command
# ENTRYPOINT ["steamcmd"]
# CMD ["+help", "+quit"]
ENTRYPOINT ["bash", "-c", "sleep 300"]