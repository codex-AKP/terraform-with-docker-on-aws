#!/bin/bash
set -euo pipefail

# ── Install Docker ────────────────────────────────────────────────────────────
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# ── Write the Dockerfile ──────────────────────────────────────────────────────
mkdir -p /opt/catsite/site

cat > /opt/catsite/Dockerfile <<'DOCKERFILE'
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY site/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

# ── Write the static site ─────────────────────────────────────────────────────
cat > /opt/catsite/site/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cat Site 🐱</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: "Segoe UI", sans-serif;
      background: #1a1a2e;
      color: #eee;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 2rem;
      padding: 2rem;
    }
    h1 { font-size: 3rem; color: #e94560; text-shadow: 0 0 20px rgba(233,69,96,0.5); }
    p  { font-size: 1.2rem; color: #aaa; }
    .cat-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 1.5rem;
      max-width: 900px;
      width: 100%;
    }
    .cat-card {
      background: #16213e;
      border-radius: 16px;
      overflow: hidden;
      border: 1px solid #0f3460;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .cat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 30px rgba(233,69,96,0.3); }
    .cat-card img   { width: 100%; height: 200px; object-fit: cover; }
    .cat-card .caption { padding: 1rem; font-size: 0.95rem; color: #ccc; text-align: center; }
    footer { color: #555; font-size: 0.85rem; }
  </style>
</head>
<body>
  <h1>🐱 Welcome to Cat Site</h1>
  <p>The internet's most important resource.</p>
  <div class="cat-grid">
    <div class="cat-card">
      <img src="https://cataas.com/cat/cute?width=400&height=200" alt="Cute cat" />
      <div class="caption">Professional loaf inspector</div>
    </div>
    <div class="cat-card">
      <img src="https://cataas.com/cat/funny?width=400&height=200" alt="Funny cat" />
      <div class="caption">Senior nap consultant</div>
    </div>
    <div class="cat-card">
      <img src="https://cataas.com/cat?width=400&height=200" alt="Random cat" />
      <div class="caption">Distinguished chaos engineer</div>
    </div>
  </div>
  <footer>Powered by Docker &amp; nginx on AWS EC2</footer>
</body>
</html>
HTML

# ── Build and run the container ───────────────────────────────────────────────
cd /opt/catsite
docker build -t ${container_image_tag} .

docker run -d \
  --name ${container_name} \
  --restart unless-stopped \
  -p ${app_port}:80 \
  ${container_image_tag}
