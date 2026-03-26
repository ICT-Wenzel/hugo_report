#!/bin/bash

# Alle Umgebungsvariablen exportieren
set -a

# Lade die Umgebungsvariablen
source .env

# Kopiere die Supabase .env-Datei aus dem Template
cp ./supabase/.env.dist ./supabase/.env
# Lade die Supabase-Umgebungsvariablen
source ./supabase/.env

# Lege das Frontend-App-Verzeichnis an
mkdir -p ./frontend/app
# Klone das Frontend-Repository aus GitHub (URL aus .env)
git clone $FRONTEND_GITHUB_URL ./frontend/app

# Kopiere das .env-Template ins Frontend
cp ./frontend/app/.env.dist ./frontend/app/.env

# Schreibe wichtige Keys und URLs ins Frontend-.env
# (werden aus der Haupt-.env übernommen)
echo ANON_KEY="$ANON_KEY" >> ./frontend/app/.env
echo SUPABASE_URL="$API_EXTERNAL_URL" >> ./frontend/app/.env
echo N8N_URL="$N8N_URL" >> ./frontend/app/.env
echo SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY" >> ./frontend/app/.env

# Docker-Images aktualisieren und bauen
docker compose pull
docker compose build
# Container im Hintergrund starten
docker compose up -d