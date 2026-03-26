cp frontend/app/.env.example frontend/app/.env
cp supabase/.env.dist supabase/.env
docker compose pull
docker compose build
docker compose up -d