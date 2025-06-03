FROM grafana/grafana:12.0.1

# Install jq
USER root
RUN apt-get update && \
    apt-get install -y jq && \
    rm -rf /var/lib/apt/lists/*

# Add entrypoint
COPY grafana-entrypoint.sh /grafana-entrypoint.sh
RUN chmod +x /grafana-entrypoint.sh

ENTRYPOINT ["/grafana-entrypoint.sh"]
