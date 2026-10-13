FROM alpine:3.20

# Install the runtime dependencies
RUN apk add --no-cache bash coreutils curl jq tini bind-tools iputils-ping

# Run as an unprivileged user
RUN adduser -D -h /app noir

# Install the script and man page from this checkout
COPY --chmod=755 noirnet /usr/local/bin/noirnet
COPY noirnet.1 /usr/share/man/man1/noirnet.1

USER noir
WORKDIR /app

# Create the default configuration. Mount your own file over /app/noirnet.json to replace it.
RUN noirnet --init -c /app/noirnet.json -C /app/cache

# Run in the foreground so logs reach `docker logs` and `docker stop` reaches the app.
# Arguments given to `docker run` are added after the configuration file option.
ENTRYPOINT ["/sbin/tini", "--", "noirnet", "-c", "/app/noirnet.json"]
