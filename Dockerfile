FROM grafana/grafana:10.3.3

USER root

# Use Alpine's package manager
RUN apk add --no-cache jq

COPY grafana-entrypoint.sh /grafana-entrypoint.sh
RUN chmod +x /grafana-entrypoint.sh

ENTRYPOINT ["/grafana-entrypoint.sh"]
