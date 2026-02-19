# Realtime Voice AI Platform

An end-to-end real-time AI phone assistant built using LiveKit SIP, Groq LLM, Deepgram STT, and ElevenLabs TTS.

This project provides a production-ready infrastructure stack for deploying a real-time conversational voice AI system over SIP.

---

## Overview

This platform enables real-time AI-powered phone conversations by integrating:

- **LiveKit** – WebRTC server and SIP gateway
- **Groq** – Large Language Model (LLM)
- **Deepgram** – Speech-to-Text (STT)
- **ElevenLabs** – Text-to-Speech (TTS)
- **Docker** – Containerized infrastructure
- **Ubuntu EC2** – Deployment target

The system supports inbound SIP calls that are automatically routed to an AI agent for natural, real-time interaction.

---

## Architecture

SIP Call  
→ LiveKit SIP Service  
→ LiveKit Room  
→ AI Agent Session  
→ LLM (Groq)  
→ STT (Deepgram)  
→ TTS (ElevenLabs)  
→ Real-Time Audio Response  

---

## Project Structure

realtime-voice-ai-platform/
│
├── bootstrap/
│ └── full_bootstrap.sh # One-command infrastructure setup
│
├── livekit-stack/
│ ├── livekit.yaml # LiveKit server configuration
│ ├── sip.yaml # SIP service configuration
│ └── trunk.json # SIP trunk definition
│
├── voice-agent/
│ ├── agent.py # AI voice agent logic
│ └── requirements.txt # Python dependencies
│
├── .env.example # Example environment variables
├── .gitignore
└── README.md


---

## Features

- Automated Docker installation
- Dynamic LiveKit API key generation
- SIP trunk creation via CLI
- Dispatch rule auto-configuration
- Real-time AI voice agent
- Modular provider configuration (LLM/STT/TTS)
- Production-ready network configuration
- NAT 1:1 IP handling for SIP

---

## Deployment (Ubuntu EC2)

### 1. Clone Repository

```bash
git clone https://github.com/sachi7479/realtime-voice-ai-platform.git
cd realtime-voice-ai-platform 
```

```bash
Run Infrastructure Bootstrap
chmod +x bootstrap/full_bootstrap.sh
./bootstrap/full_bootstrap.sh

```

---

## 🛠 1. This will do these things

* **Docker & Networking:** Installs Docker and creates a dedicated internal network.
* **Redis:** Deploys Redis for session management and state handling.
* **LiveKit Stack:** Deploys the LiveKit Server and the LiveKit SIP service.
* **Credentials:** Automatically generates the required LiveKit API keys and secrets.
* **SIP Logic:** Configures the SIP trunk and dispatch rules for handling calls.
* **Environment:** Sets up the Python virtual environment for the voice agent.



---

## 🔑 2. Configure API Keys

The voice agent requires credentials from external AI providers for speech processing and intelligence.

1.  Open the environment configuration file:
    ```bash
    nano voice-agent/.env
    ```
2.  Enter your API keys for the following services:
    * **DEEPGRAM_API_KEY:** Used for fast Speech-to-Text (STT).
    * **GROQ_API_KEY:** Used for low-latency LLM (Llama 3 / Mixtral) inference.
    * **ELEVEN_API_KEY:** Used for high-quality Text-to-Speech (TTS).
    * **LIVEKIT_URL=**ws://localhost:7880
    * **LIVEKIT_API_KEY=**your_generated_api_key
    * **LIVEKIT_API_SECRET=**your_generated_api_secret

---

## 🚀 3. Start the AI Agent

Once the infrastructure is live and keys are configured, start the agent service:

```bash
cd voice-agent
source venv/bin/activate
python3 agent.py
```
### SIP Configuration

After deployment, your SIP URI will be:
  * **sip:test@YOUR_PUBLIC_IP**

Make sure your EC2 Security Group allows the following inbound ports:

| Port(s)       | Protocol | Purpose               |
|---------------|----------|-----------------------|
| 5060          | UDP/TCP  | SIP signaling         |
| 7880          | TCP      | LiveKit HTTP/WebSocket|
| 10000–20000   | UDP      | RTP media             |
| 50000–60000   | UDP      | WebRTC ICE range      |
