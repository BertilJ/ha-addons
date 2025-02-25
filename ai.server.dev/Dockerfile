ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set the working directory
WORKDIR /app

# Expose API Port
EXPOSE 32168

# Create persistent storage for models and config
VOLUME [ "/data" ]

# Copy the startup script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Start the AI server
CMD [ "/app/run.sh" ]
