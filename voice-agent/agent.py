import logging
import os
from dotenv import load_dotenv

from livekit.agents import (
    Agent,
    AgentServer,
    AgentSession,
    JobContext,
    JobProcess,
    cli,
)
from livekit.plugins import deepgram, openai, silero, elevenlabs,groq

logger = logging.getLogger("voice-agent")

load_dotenv()

class Assistant(Agent):
    def __init__(self) -> None:
        super().__init__(
            instructions="""
You are a friendly AI phone assistant.
Keep responses short and natural.
Do not say you are an AI or bot.
"""
        )

server = AgentServer()

def prewarm(proc: JobProcess):
    proc.userdata["vad"] = silero.VAD.load()

server.setup_fnc = prewarm


@server.rtc_session()
async def voice_agent(ctx: JobContext):

    if not ctx.room.name.startswith("call-"):
        return

    session = AgentSession(
        stt=deepgram.STT(
            model="nova-2",
        ),
        llm=groq.LLM(
        	model="llama-3.1-8b-instant",
   	 ),
        tts= elevenlabs.TTS(),
        vad=ctx.proc.userdata["vad"],
    )

    await session.start(
        agent=Assistant(),
        room=ctx.room,
    )

    await ctx.connect()


if __name__ == "__main__":
    cli.run_app(server)
