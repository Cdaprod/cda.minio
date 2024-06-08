ARG SSL_CERTIFICATE
ARG SSL_CERTIFICATE_KEY

# Use an argument for the base image
ARG BASE_IMAGE=minio/minio:latest
FROM $BASE_IMAGE

# Add custom configuration or scripts if needed
# COPY your-custom-config /your-config-location
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy the SSL certificates
COPY ./ssl/certs/$SSL_CERTIFICATE /etc/ssl/certs/$SSL_CERTIFICATE
COPY ./ssl/private/$SSL_CERTIFICATE_KEY /etc/ssl/private/$SSL_CERTIFICATE_KEY

EXPOSE 9000 9001
ENTRYPOINT ["/entrypoint.sh"]