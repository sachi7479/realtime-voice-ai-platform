#!/bin/bash
set -e

PUBLIC_IP="YOUR_EC2_PUBLIC_IP_HERE"  # Replace with your server's public IP

echo "🚀 Starting Full Voice AI Bootstrap..."

# -------------------------------------------------
# Generate LiveKit API Credentials
# -------------------------------------------------
API_KEY=$(openssl rand -hex 16)
API_SECRET=$(openssl rand -hex 32)

echo "Generated API_KEY: $API_KEY"
echo "Generated API_SECRET: $API_SECRET"

# -------------------------------------------------
# Install Docker + Tools
# -------------------------------------------------
sudo apt update
sudo apt install -y docker.io docker-compose curl jq openssl
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

docker network create livekit-net || true

# -------------------------------------------------
# Create LiveKit Stack
# -------------------------------------------------
mkdir -p ~/livekit-stack
cd ~/livekit-stack

# ---------------- livekit.yaml -------------------
cat <<EOF > livekit.yaml
port: 7880
rtc:
  udp_port: 7882
  tcp_port: 7881
  port_range_start: 50000
  port_range_end: 60000
keys:
  ${API_KEY}: ${API_SECRET}
redis:
  address: redis:6379
  db: 0
EOF

# ---------------- sip.yaml -----------------------
cat <<EOF > sip.yaml
log_level: info

api_key: ${API_KEY}
api_secret: ${API_SECRET}

ws_url: ws://livekit:7880

redis:
  address: redis:6379

sip_port: 5060
rtp_port: 10000-20000

nat_1_to_1_ip: ${PUBLIC_IP}
EOF

# -------------------------------------------------
# Start Redis
# -------------------------------------------------
docker rm -f redis || true
docker run -d \
  --name redis \
  --network livekit-net \
  redis:7-alpine

# -------------------------------------------------
# Start LiveKit
# -------------------------------------------------
docker rm -f livekit || true
docker run -d \
  --name livekit \
  --network livekit-net \
  -p 7880:7880 \
  -v $(pwd)/livekit.yaml:/livekit.yaml \
  livekit/livekit-server \
  --config /livekit.yaml

# -------------------------------------------------
# Start SIP
# -------------------------------------------------
docker rm -f livekit-sip || true
docker run -d \
  --name livekit-sip \
  --network livekit-net \
  -p 5060:5060/udp \
  -p 5060:5060/tcp \
  -v $(pwd)/sip.yaml:/sip.yaml \
  livekit/sip \
  --config /sip.yaml

echo "⏳ Waiting for services..."
sleep 10

# -------------------------------------------------
# Install LiveKit CLI
# -------------------------------------------------
curl -fsSL https://get.livekit.io/cli | sudo bash

export LIVEKIT_URL=http://localhost:7880
export LIVEKIT_API_KEY=${API_KEY}
export LIVEKIT_API_SECRET=${API_SECRET}

# -------------------------------------------------
# Create trunk.json (your format)
# -------------------------------------------------
cat <<EOF > trunk.json
{
  "trunk": {
    "name": "Test-Trunk",
    "allowed_addresses": ["0.0.0.0/0"]
  }
}
EOF

echo "📞 Creating SIP Trunk..."
lk sip inbound create trunk.json

TRUNK_ID=$(lk sip inbound list | awk '/ST_/ {print $1}')
echo "Created Trunk ID: $TRUNK_ID"

# -------------------------------------------------
# Create Dispatch Rule
# -------------------------------------------------
echo "📡 Creating Dispatch Rule..."
lk sip dispatch create \
  --name Test-Dispatch \
  --trunks $TRUNK_ID \
  --individual call- \
  --randomize

# -------------------------------------------------
# Setup Voice Agent
# -------------------------------------------------
mkdir -p ~/voice-agent
cd ~/voice-agent

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

pip install \
  livekit-agents \
  livekit-plugins-deepgram \
  livekit-plugins-groq \
  livekit-plugins-elevenlabs \
  livekit-plugins-silero \
  python-dotenv

# Create .env for agent (only external APIs)
cat <<EOF > .env
DEEPGRAM_API_KEY=PASTE_YOUR_DEEPGRAM_KEY
GROQ_API_KEY=PASTE_YOUR_GROQ_KEY
ELEVEN_API_KEY=PASTE_YOUR_ELEVENLABS_KEY

LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=${API_KEY}
LIVEKIT_API_SECRET=${API_SECRET}
EOF

echo ""
echo "=============================================="
echo "✅ FULL INFRA DEPLOYED SUCCESSFULLY"
echo "=============================================="
echo ""
echo "LiveKit API KEY: $API_KEY"
echo "LiveKit API SECRET: $API_SECRET"
echo ""
echo "SIP URI:"
echo "sip:test@${PUBLIC_IP}"
echo ""
echo "To start agent:"
echo "cd ~/voice-agent"
echo "source venv/bin/activate"
echo "python agent.py"
echo ""
