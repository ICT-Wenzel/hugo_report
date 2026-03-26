#!/bin/sh
# Stoppe alle laufenden Docker-Container
docker compose down

echo "Updating project..."
# Lege temporäre Verzeichnisse für das Update an
mkdir ./update-tmp
mkdir ./update-tmp/supabase
mkdir ./update-tmp/supabase-volumes
mkdir ./update-tmp/supabase-static

# Klone das aktuelle Supabase-Repository (nur letzter Commit)
git clone --depth 1 https://github.com/supabase/supabase ./update-tmp/supabase

# Sichere bestehende Supabase-Volumes
cp -rf ./supabase/volumes/* ./update-tmp/supabase-volumes

# Entferne alle alten Supabase-Dateien
rm -rf ./supabase/*

# Kopiere neue Supabase-Dockerdateien ins Projekt
cp -rf ./update-tmp/supabase/docker/* ./supabase/

# Kopiere neue statische Dateien
cp -rf ./update-tmp/supabase/static/* ./supabase-static/

# Stelle die gesicherten Volumes wieder her
cp -rf ./update-tmp/supabase-volumes ./supabase/volumes

# Lösche temporäre Update-Verzeichnisse
rm -rf ./update-tmp

echo "Update done..."

# Wechsle ins n8n-Verzeichnis und aktualisiere das n8n-Image
cd n8n
docker pull
