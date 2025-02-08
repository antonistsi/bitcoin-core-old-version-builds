# Use an appropriate base image
FROM ubuntu:12.04

# Copy the setup script into the container
COPY setup_build.sh /root/setup_build.sh

# Make the script executable
RUN chmod +x /root/setup_build.sh

# Set the working directory
WORKDIR /root

# Run the setup script during the build
RUN /root/setup_build.sh