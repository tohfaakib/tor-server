# Stage 1: Generate the hashed password
FROM alpine:latest as builder

# Install dependencies for Tor, Privoxy, and Python
RUN apk update && \
    apk add tor python3 py3-pip py3-flask py3-requests busybox-suid privoxy

# Create a virtual environment and install Stem
RUN python3 -m venv /venv
RUN /venv/bin/pip install stem

# Generate the hashed password and save it in a file
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Stage 2: Set up Tor, Privoxy, and Flask with the hashed password
FROM alpine:latest

# Install Tor, Privoxy, and other necessary tools
RUN apk update && \
    apk add tor python3 py3-flask py3-requests busybox-suid privoxy

# Copy the hashed password from the builder stage
COPY --from=builder /hashed_password.txt /hashed_password.txt

# Copy the virtual environment with Stem
COPY --from=builder /venv /venv

# Configure Privoxy to use Tor's SOCKS5 proxy
RUN echo 'forward-socks5t / 127.0.0.1:12453 .' >> /etc/privoxy/config
RUN echo 'listen-address 0.0.0.0:8118' >> /etc/privoxy/config

# Copy the script to generate torrc
COPY generate_torrc.sh /generate_torrc.sh

# Make the script executable and generate torrc
RUN chmod +x /generate_torrc.sh && /generate_torrc.sh

# Copy the proxy app
COPY proxy_app.py /proxy_app.py

# Expose necessary ports
EXPOSE 80 12453 12454 8118

# Run Tor, Privoxy, and Flask app in virtual environment
CMD ["sh", "-c", "tor & privoxy /etc/privoxy/config & /venv/bin/python /proxy_app.py"]
