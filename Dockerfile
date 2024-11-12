# Stage 1: Generate the hashed password and set up Python environment
FROM alpine:latest as builder

# Install dependencies for Tor, Python, and pip
RUN apk update && \
    apk add tor python3 py3-pip busybox-suid

# Set up a virtual environment and install Python packages
RUN python3 -m venv /venv
RUN /venv/bin/pip install Flask requests stem

# Generate the hashed password and save it in a file
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Stage 2: Set up Tor, Privoxy, and Flask with the hashed password
FROM alpine:latest

# Install Tor, Privoxy, and other necessary tools
RUN apk update && \
    apk add tor privoxy python3 busybox-suid

# Copy the hashed password and virtual environment from the builder stage
COPY --from=builder /hashed_password.txt /hashed_password.txt
COPY --from=builder /venv /venv

# Configure Privoxy to forward requests to Tor's SOCKS5 proxy
RUN echo 'forward-socks5t / 127.0.0.1:12453 .' >> /etc/privoxy/config && \
    echo 'listen-address 0.0.0.0:8118' >> /etc/privoxy/config

# Copy the script to generate torrc configuration and set permissions
COPY generate_torrc.sh /generate_torrc.sh
RUN chmod +x /generate_torrc.sh && /generate_torrc.sh

# Copy the Flask proxy app
COPY proxy_app.py /proxy_app.py

# Expose necessary ports
EXPOSE 80 12453 12454 8118

# Run Tor, Privoxy, and the Flask app in the virtual environment
CMD ["sh", "-c", "tor & privoxy /etc/privoxy/config & /venv/bin/python /proxy_app.py"]
