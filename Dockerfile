# Stage 1: Generate the hashed password
FROM alpine:latest as builder

# Install Tor
RUN apk update && apk add tor

# Generate the hashed password and save it in a file
RUN tor --hash-password TorPass34 > /hashed_password.txt

# Stage 2: Set up Tor with the hashed password
FROM alpine:latest

# Install Tor and other necessary tools
RUN apk update && apk add tor busybox-suid

# Copy the hashed password from the builder stage
COPY --from=builder /hashed_password.txt /hashed_password.txt

# Copy the script to generate torrc
COPY generate_torrc.sh /generate_torrc.sh

# Make the script executable
RUN chmod +x /generate_torrc.sh

# Run the script to generate the torrc file
RUN /generate_torrc.sh

# Expose necessary ports
EXPOSE 12453 12454

# Print files for verification and run Tor
CMD ["sh", "-c", "cat /hashed_password.txt; cat /etc/tor/torrc; tor"]
