#!/bin/sh
set -e

mkdir -p /etc/grafana/provisioning/datasources
: > /etc/grafana/provisioning/datasources/datasources.yaml

cat <<EOF >> /etc/grafana/provisioning/datasources/datasources.yaml
apiVersion: 1
datasources:
EOF

# Parse all interfaces and generate data sources for their clients
echo "$MAKE87_CONFIG" | jq -c '.interfaces | to_entries[]' | while read -r iface_entry; do
  iface=$(echo "$iface_entry" | jq -c '.value')
  iface_name=$(echo "$iface_entry" | jq -r '.key')

  clients=$(echo "$iface" | jq -c '.clients // {} | to_entries[]?')
  echo "$clients" | while read -r client_entry; do
    client_name=$(echo "$client_entry" | jq -r '.key')
    client=$(echo "$client_entry" | jq -c '.value')

    # Determine IP/port based on use_public_ip
    use_public=$(echo "$client" | jq -r '.use_public_ip // false')
    if [ "$use_public" = "true" ]; then
      host=$(echo "$client" | jq -r '.public_ip // empty')
      port=$(echo "$client" | jq -r '.public_port // empty')
    else
      host=$(echo "$client" | jq -r '.vpn_ip // empty')
      port=$(echo "$client" | jq -r '.vpn_port // empty')
    fi

    if [ -z "$host" ] || [ -z "$port" ]; then
      echo "Skipping ${iface_name}_${client_name}: missing host or port" >&2
      continue
    fi

    url="http://$host:$port"

    datasource_type=$(echo "$client" | jq -r '.spec // "loki"')
    name="${iface_name}_${client_name}"

    cat <<EOF >> /etc/grafana/provisioning/datasources/datasources.yaml
  - name: "$name"
    type: "$datasource_type"
    url: "$url"
    access: "proxy"
    jsonData:
      maxLines: 1000
EOF

  done
done

exec grafana-server \
  --homepath=/usr/share/grafana \
  --config=/etc/grafana/grafana.ini
