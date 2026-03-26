#!/bin/bash

# Exportiere alle Umgebungsvariablen aus .env
set -a
source .env

# Erstelle temporäre Verzeichnisse im n8n-Container für Export
# (falls sie noch nicht existieren)
docker exec -it n8n-server mkdir /tmp/credentials
docker exec -it n8n-server mkdir /tmp/workflows

# Exportiere alle Credentials aus n8n in eine JSON-Datei
docker exec -it n8n-server sh -c "n8n export:credentials --all--output=/tmp/credentials/credentials.json"
# Exportiere alle Workflows aus n8n in eine JSON-Datei
docker exec -it n8n-server sh -c "n8n export:workflow --all --output=/tmp/workflows/workflow.json"

# Kopiere die exportierten Credentials aus dem Container ins lokale Verzeichnis
docker cp n8n-server:/tmp/credentials/credentials.json n8n/n8n-utils/credential/credentials.json
# Kopiere die exportierten Workflows aus dem Container ins lokale Verzeichnis
docker cp n8n-server:/tmp/workflows/workflow.json n8n/n8n-utils/workflow/workflow.json

# Lösche die temporären Export-Verzeichnisse im Container
docker exec -it n8n-server rm -rf /tmp/credentials
docker exec -it n8n-server rm -rf /tmp/workflows