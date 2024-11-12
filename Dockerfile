# Base image
FROM alpine:latest

# Install Tor, Privoxy, Python, and necessary tools
RUN apk update && \
    apk add tor privoxy python3 py3-pip busybox-suid

# Set up a virtual environment and install Python packages
RUN python3 -m venv /venv
RUN /venv/bin/pip install stem Flask

# Generate the hashed password for Tor
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Configure Privoxy to forward requests to Tor's SOCKS5 proxy
RUN echo 'forward-socks5t / 127.0.0.1:12453 .' >> /etc/privoxy/config && \
    echo 'listen-address 0.0.0.0:8118' >> /etc/privoxy/config

# Copy the script to generate torrc configuration and set permissions
COPY generate_torrc.sh /generate_torrc.sh
RUN chmod +x /generate_torrc.sh && /generate_torrc.sh

# Copy the Flask app for renewing IP
COPY renew_ip.py /renew_ip.py

# Expose necessary ports
EXPOSE 8118 12453 12454 5000

# Run Tor, Privoxy, and Flask app for IP renewal
CMD ["sh", "-c", "tor & privoxy /etc/privoxy/config & /venv/bin/python /renew_ip.py"]
