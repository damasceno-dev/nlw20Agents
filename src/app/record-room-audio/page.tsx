"use client";
import { useRef, useState } from "react";
import { Button } from "@/components/ui/button";

const isRecordingSupported =
  typeof navigator !== "undefined" &&
  navigator.mediaDevices &&
  typeof navigator.mediaDevices.getUserMedia === "function";

export default function RecordRoomAudioPage() {
  const [isRecording, setIsRecording] = useState(false);
  const recorder = useRef<MediaRecorder | null>(null);
  const mediaStream = useRef<MediaStream | null>(null);

  function stopRecording() {
    setIsRecording(false);
    if (recorder.current && recorder.current.state !== "inactive") {
      recorder.current.stop();
    }

    // Release the microphone by stopping all tracks in the stream
    if (mediaStream.current) {
      mediaStream.current.getTracks().forEach((track) => {
        track.stop();
      });
      mediaStream.current = null;
    }
  }

  async function startRecording() {
    if (!isRecordingSupported) {
      alert("Seu navegador não suporta gravação");
      return;
    }

    setIsRecording(true);

    const audio = await navigator.mediaDevices.getUserMedia({
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        sampleRate: 44_100,
      },
    });

    // Store the media stream in the ref for later cleanup
    mediaStream.current = audio;

    recorder.current = new MediaRecorder(audio, {
      mimeType: "audio/webm",
      audioBitsPerSecond: 64_000,
    });

    recorder.current.ondataavailable = (e) => {
      if (e.data.size > 0) {
        console.log(e.data);
      }
    };

    recorder.current.onstart = () => {
      console.log("Recording started");
    };
    recorder.current.onstop = () => {
      console.log("Record stopped");
    };

    recorder.current.start();
  }

  return (
    <div className="flex h-screen flex-col items-center justify-center gap-4">
      {!isRecordingSupported ? (
        <p className="text-red-500">Seu navegador não suporta gravação de áudio.</p>
      ) : isRecording ? (
        <Button onClick={stopRecording} disabled={!isRecordingSupported}>
          Parar gravação
        </Button>
      ) : (
        <Button onClick={startRecording}>Gravar</Button>
      )}
    </div>
  );
}
