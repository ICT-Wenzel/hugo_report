# Fullstack Docker Architektur

Dieses Repository stellt eine vollständige, containerisierte Entwicklungsumgebung bereit, die folgende Komponenten umfasst:

- **Streamlit Frontend**: Moderne Weboberfläche für Endnutzer
- **n8n Backend**: Low-Code Automatisierungs- und Workflow-Engine
- **Supabase**: Open-Source Backend-as-a-Service (PostgreSQL, Auth, Storage, Realtime, REST API)

## Architekturübersicht

```
+-------------------+        +-------------------+        +-------------------+
|   Streamlit App   | <----> |      n8n API      | <----> |    Supabase DB    |
|   (Frontend)      |        | (Workflows/Logic) |        | (Postgres, Auth)  |
+-------------------+        +-------------------+        +-------------------+
```

- Das **Frontend** kommuniziert direkt mit Supabase (z.B. für Authentifizierung, Daten) und kann über HTTP-Requests n8n-Workflows triggern.
- **n8n** kann als Automatisierungs-Backend agieren, Daten aus Supabase lesen/schreiben und externe APIs anbinden.
- **Supabase** stellt Auth, Datenbank, Storage und Realtime-Features bereit.

## Komponenten & Verzeichnisstruktur

- `frontend/` – Streamlit-App (Python)
- `n8n/` – n8n-Container mit Custom-Import-Skripten für Workflows/Credentials
- `supabase/` – Supabase-Stack (Docker Compose, Konfiguration)
- `n8n-utils/` – Ablage für n8n-Workflows und Credentials (JSON)
- `docker-compose.yml` – Orchestriert alle Services

## Wie funktionieren die wichtigsten Skripte?

### n8n Dockerfile & Import-Mechanismus

- **`n8n/Dockerfile.n8n`**: Baut ein n8n-Image, das beim Start automatisch alle Workflows und Credentials aus `n8n-utils/` importiert.
    - Kopiert alle `.json`-Dateien aus `n8n-utils/workflow/` und `n8n-utils/credential/` in den Container.
    - Ein Startscript (`docker-entrypoint-custom.sh`) importiert diese Dateien beim Containerstart (überspringt, falls keine vorhanden).
    - Danach startet n8n wie gewohnt.

### Supabase

- **`supabase/config.toml`**: Zentrale Konfiguration (Ports, Auth, Redirects, etc.)
- **`supabase/.env`**: Umgebungsvariablen für Supabase-Services (z.B. JWT-Secret, DB-URL)
- **`supabase/docker-compose.yml`**: Startet alle Supabase-Komponenten (DB, Auth, Storage, Studio, etc.)

### Frontend

- **`frontend/`**: Enthält die Streamlit-App. Die Verbindung zu Supabase erfolgt über die dort hinterlegten Umgebungsvariablen (`.env`).
- Authentifizierung und Datenzugriff laufen direkt über Supabase-REST-API.

## Setup & Entwicklung

1. **Voraussetzungen:**
   - Docker & Docker Compose
   - Git

2. **Repository klonen:**
   ```bash
   git clone <repo-url>
   cd fullstack_docker
   ```

3. **Supabase initialisieren:**
   ```bash
   cd supabase
   supabase init
   # Passe config.toml und .env nach Bedarf an
   cd ..
   ```

4. **n8n-Workflows/Credentials ablegen:**
   - Lege JSON-Dateien in `n8n-utils/workflow/` und `n8n-utils/credential/` ab.

5. **Alle Services starten:**
   ```bash
   docker compose up --build
   ```

6. **Frontend öffnen:**
   - Standardmäßig unter [http://localhost:3000](http://localhost:3000)

7. **n8n öffnen:**
   - Standardmäßig unter [http://localhost:5678](http://localhost:5678)

8. **Supabase Studio:**
   - Standardmäßig unter [http://localhost:54323](http://localhost:54323)

## Hinweise & Tipps

- **Workflows/Credentials:** Neue oder geänderte Dateien in `n8n-utils/` erfordern einen Neustart des n8n-Containers, damit sie importiert werden.
- **Supabase Auth:** Die Umgebungsvariable `SUPABASE_URL` im Frontend muss auf den Supabase-API-Endpunkt zeigen (z.B. `http://localhost:8000`).
- **Konfiguration:** Passe alle `.env`-Dateien und `config.toml` an deine Umgebung an.
- **Sicherheit:** Standard-Konfiguration ist nicht für Produktion geeignet! Setze sichere Passwörter, Secrets und prüfe CORS/Netzwerkregeln.
- **Frontend-Struktur:** Jede Frontend-App muss eine `app.py` (Hauptdatei), eine `requirements.txt` (Python-Abhängigkeiten) und eine `.env.dist` (Beispiel-Umgebungsvariablen) enthalten.

## Weiterführende Links

- [Supabase Self-Hosting Doku](https://supabase.com/docs/guides/self-hosting/docker)
- [n8n Dokumentation](https://docs.n8n.io/)
- [Streamlit Dokumentation](https://docs.streamlit.io/)

---

**Lizenz:** Apache 2.0 (siehe Supabase/n8n Upstream-Repos)
