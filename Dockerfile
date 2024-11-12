# Stage 1: Generate the hashed password
FROM alpine:latest as builder

# Install dependencies for Tor and Python
RUN apk update && \
    apk add tor python3 py3-pip busybox-suid

# Install Python packages
RUN pip install Flask requests stem

# Generate the hashed password and save it in a file
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Stage 2: Set up Tor with the hashed password
FROM alpine:latest

# Install Tor and other necessary tools
RUN apk update && \
    apk add tor python3 py3-pip busybox-suid

# Install Python packages
RUN pip install Flask requests stem

# Copy the hashed password from the builder stage
COPY --from=builder /hashed_password.txt /hashed_password.txt

# Copy the script to generate torrc
COPY generate_torrc.sh /generate_torrc.sh

# Make the script executable
RUN chmod +x /generate_torrc.sh

# Run the script to generate the torrc file
RUN /generate_torrc.sh

# Copy the proxy app
COPY proxy_app.py /proxy_app.py

# Expose necessary ports
EXPOSE 5000 12453 12454

# Run Tor and the Flask app
CMD ["sh", "-c", "tor & python3 /proxy_app.py"]
