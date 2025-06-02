#!/bin/sh
set -e

mkdir -p /etc/grafana/provisioning/datasources
: > /etc/grafana/provisioning/datasources/datasources.yaml

cat <<EOF >> /etc/grafana/provisioning/datasources/datasources.yaml
apiVersion: 1
datasources:
EOF

echo "$MAKE87_CONFIG" | jq -c '.interfaces | to_entries[]' | while read -r iface_entry; do
  iface=$(echo "$iface_entry" | jq -c '.value')
  iface_name=$(echo "$iface_entry" | jq -r '.key')

  echo "$iface" | jq -c '.clients | to_entries[]?' | while read -r client_entry; do
    client_name=$(echo "$client_entry" | jq -r '.key')
    client=$(echo "$client_entry" | jq -c '.value')

    use_public=$(echo "$client" | jq -r '.use_public_ip // false')
    if [ "$use_public" = "true" ]; then
      host=$(echo "$client" | jq -r '.public_ip')
      port=$(echo "$client" | jq -r '.public_port')
    else
      host=$(echo "$client" | jq -r '.vpn_ip')
      port=$(echo "$client" | jq -r '.vpn_port')
    fi

    url="http://$host:$port"
    datasource_type=$(echo "$client" | jq -r '.spec.string // "loki"')

    name="${iface_name}_${client_name}"

    cat <<EOF >> /etc/grafana/provisioning/datasources/datasources.yaml
  - name: $name
    type: $datasource_type
    url: $url
    access: proxy
    jsonData:
      maxLines: 1000
EOF
  done
done

exec grafana-server \
  --homepath=/usr/share/grafana \
  --config=/etc/grafana/grafana.ini
