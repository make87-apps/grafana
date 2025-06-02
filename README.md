# Grafana

This is a make87 app that wraps **Grafana**, the open-source analytics and monitoring platform from Grafana Labs.

It provides a production-ready deployment of Grafana with dynamic configuration for data sources via the make87 platform. This enables seamless visualization of logs, metrics, and traces from sources like Loki, Prometheus, and Tempo.

> ![Grafana Banner](https://grafana.com/media/products/cloud/grafana/grafana-dashboard-english.png?w=900)

## Licensing Notice

This app wraps the official **Grafana** project, licensed under the **AGPLv3**.  
All original rights and trademarks belong to **Grafana Labs**.

## Features

📊 Interactive dashboards with support for Loki, Prometheus, and more  
🔌 Auto-provisioned data sources from make87 configuration  
🔐 Secure HTTP UI on port 3000  
🧩 Easy integration into observability stacks with Vector or Promtail

## Configuration

The Grafana config is provisioned via `datasources.yaml`, rendered dynamically from make87’s `config.datasources` field. You can define multiple datasources referencing internal services by VPN or public IP.
