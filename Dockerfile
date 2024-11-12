# Base image
FROM alpine:latest

# Install Tor, Python, and pip
RUN apk update && \
    apk add tor python3 py3-pip busybox-suid && \
    python3 -m venv /venv && \
    /venv/bin/pip install stem Flask requests

# Generate the hashed password for Tor
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Copy the script to generate torrc configuration and set permissions
COPY generate_torrc.sh /generate_torrc.sh
RUN chmod +x /generate_torrc.sh && /generate_torrc.sh

# Copy the Flask app for proxying requests
COPY proxy_app.py /proxy_app.py

# Expose necessary ports
EXPOSE 5000 12453 12454

# Run Tor and Flask app for IP renewal and proxying
CMD ["sh", "-c", "tor & /venv/bin/python /proxy_app.py"]
