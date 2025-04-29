FROM rocker/rstudio:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libicu-dev \
    libreadline-dev \
    libzstd-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install renv
RUN R -e "install.packages('renv', repos = 'https://cran.rstudio.com/')"

# Create a directory for your project
RUN mkdir -p /home/rstudio/project
WORKDIR /home/rstudio/project

# Set correct ownership for the project directory
RUN chown -R rstudio:rstudio /home/rstudio/project

# Switch to the rstudio user for subsequent commands
USER rstudio

# Copy project files with correct ownership
COPY --chown=rstudio:rstudio . .

# Set explicit permissions for all files and directories
USER root
RUN find /home/rstudio/project -type d -exec chmod 755 {} \; && \
    find /home/rstudio/project -type f -exec chmod 644 {} \; && \
    chown -R rstudio:rstudio /home/rstudio/project

# Create startup script to ensure permissions at runtime
RUN echo '#!/bin/bash' > /usr/local/bin/fix-permissions.sh && \
    echo 'chown -R rstudio:rstudio /home/rstudio/project' >> /usr/local/bin/fix-permissions.sh && \
    echo 'find /home/rstudio/project -type d -exec chmod 755 {} \;' >> /usr/local/bin/fix-permissions.sh && \
    echo 'find /home/rstudio/project -type f -exec chmod 644 {} \;' >> /usr/local/bin/fix-permissions.sh && \
    echo 'exec "$@"' >> /usr/local/bin/fix-permissions.sh && \
    chmod +x /usr/local/bin/fix-permissions.sh

# Switch back to rstudio user for renv restore
USER rstudio
RUN R -e "renv::restore()"

# Switch back to root for the final CMD
USER root

EXPOSE 8787
ENTRYPOINT ["/usr/local/bin/fix-permissions.sh"]
CMD ["/init"]