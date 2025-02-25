ARG BUILD_FROM
ARG AI_VERSION="2.9.7"
FROM codeproject/ai-server:${AI_VERSION}

# Set the work directory
WORKDIR /app

# Expose API Port
EXPOSE 32168

# Persistent storage for models, config, and logs
VOLUME [ "/data" ]

# Copy the startup script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Start the AI server
CMD [ "/app/run.sh" ]
