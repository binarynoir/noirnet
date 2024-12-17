FROM alpine:latest

# Upgrade all installed packages and install necessary packages
RUN apk upgrade && \
    apk add --no-cache bash coreutils jq openssl curl

# Set the working directory
WORKDIR /app

# Fetch the latest release tar.gz from GitHub
RUN curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/binarynoir/noirnet/releases/latest | \
    jq -r '.tarball_url' | \
    xargs curl -L -o /tmp/noirnet.tar.gz

# Create the temporary directory and extract the tarball
RUN mkdir -p /tmp/noirnet && \
    tar -xzf /tmp/noirnet.tar.gz -C /tmp/noirnet --strip-components=1

# Copy the noirnet script to /usr/local/bin
RUN cp /tmp/noirnet/noirnet /usr/local/bin/noirnet

# Copy the man page to the appropriate location
RUN mkdir -p /usr/share/man/man1 && \
    cp /tmp/noirnet/noirnet.1 /usr/share/man/man1/noirnet.1

# Clean up the temporary files
RUN rm -rf /tmp/noirnet /tmp/noirnet.tar.gz

# Make the script executable
RUN chmod +x /usr/local/bin/noirnet

# Run noirnet --init during the build process
ENV NOIRNET_CONFIG="/app/noirnet.json"
ENV NOIRNET_CACHE="/app/cache"
RUN /usr/local/bin/noirnet --init -c "$NOIRNET_CONFIG" -C "$NOIRNET_CACHE"

# Set the CMD to run the startup script and keep the container running
CMD ["/bin/sh", "-c", "/usr/local/bin/noirnet -c '/app/noirnet.json' --start && tail -f /dev/null"]