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



2. Run Infrastructure Bootstrap
chmod +x bootstrap/full_bootstrap.sh
./bootstrap/full_bootstrap.sh


This will:

Install Docker

Create Docker network

Deploy Redis

Deploy LiveKit server

Deploy LiveKit SIP service

Generate LiveKit API credentials

Create SIP trunk

Create dispatch rule

Prepare voice agent environment

3. Configure API Keys

Edit:

nano voice-agent/.env


Add your:

DEEPGRAM_API_KEY

GROQ_API_KEY

ELEVEN_API_KEY

4. Start the AI Agent
cd voice-agent
source venv/bin/activate
python agent.py

SIP Configuration

After deployment, your SIP URI will be:

sip:test@YOUR_PUBLIC_IP


Make sure your EC2 Security Group allows:

5060 (UDP & TCP)

7880 (LiveKit)

10000-20000 (RTP)

50000-60000 (WebRTC range)



Environment Variables

DEEPGRAM_API_KEY=
GROQ_API_KEY=
ELEVEN_API_KEY=
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
