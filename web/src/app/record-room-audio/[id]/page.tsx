"use client";
import { AlertCircle, Mic, MicOff, Upload } from "lucide-react";
import { useParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { usePostAudioRoomIdUpload } from "@/api/generated/serverAPI";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

const isRecordingSupported =
  typeof navigator !== "undefined" &&
  navigator.mediaDevices &&
  typeof navigator.mediaDevices.getUserMedia === "function";

const CHUNK_DURATION = 5000; // 5 seconds in milliseconds

export default function RecordRoomAudioPage() {
  const params = useParams();
  const roomId = params.id as string;

  const [isRecording, setIsRecording] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<"idle" | "uploading" | "success" | "error">(
    "idle",
  );
  const [chunkCount, setChunkCount] = useState(0);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const recorder = useRef<MediaRecorder | null>(null);
  const mediaStream = useRef<MediaStream | null>(null);
  const chunkInterval = useRef<NodeJS.Timeout | null>(null);
  const currentChunkData = useRef<Blob[]>([]);
  const isProcessingChunk = useRef(false);
  const shouldContinueRecording = useRef(false);

  const uploadAudioMutation = usePostAudioRoomIdUpload({
    mutation: {
      onSuccess: (data) => {
        console.log("Audio chunk uploaded successfully:", data);
        setUploadStatus("success");
        setTimeout(() => setUploadStatus("idle"), 1000);
        isProcessingChunk.current = false;
      },
      onError: (error) => {
        console.error("Failed to upload audio chunk:", error);
        setUploadStatus("error");
        setErrorMessage("Falha ao enviar áudio. Tente novamente.");
        setTimeout(() => {
          setUploadStatus("idle");
          setErrorMessage(null);
        }, 3000);
        isProcessingChunk.current = false;
      },
    },
  });

  const uploadAudioChunk = async (audioBlob: Blob, chunkNumber: number) => {
    if (isProcessingChunk.current) return;

    try {
      isProcessingChunk.current = true;
      setUploadStatus("uploading");

      // Create a File object from the Blob
      const audioFile = new File([audioBlob], `audio-chunk-${chunkNumber}.webm`, {
        type: "audio/webm",
      });

      console.log(`Uploading chunk ${chunkNumber}, size: ${audioBlob.size} bytes`);

      await uploadAudioMutation.mutateAsync({
        roomId,
        data: {
          audioFile,
        },
      });

      setChunkCount((prev) => prev + 1);
    } catch (error) {
      console.error("Error uploading audio chunk:", error);
      throw error;
    }
  };

  const createNewRecorder = () => {
    if (!mediaStream.current) return null;

    const newRecorder = new MediaRecorder(mediaStream.current, {
      mimeType: "audio/webm",
      audioBitsPerSecond: 64_000,
    });

    newRecorder.ondataavailable = (event) => {
      console.log("Data available:", event.data.size, "bytes");
      if (event.data.size > 0) {
        currentChunkData.current.push(event.data);
      }
    };

    newRecorder.onstop = async () => {
      console.log("Recording chunk stopped");

      if (currentChunkData.current.length > 0) {
        // Create a complete WebM file from the chunks
        const audioBlob = new Blob(currentChunkData.current, { type: "audio/webm" });
        const currentChunkNumber = chunkCount + 1;

        console.log(
          `Processing chunk ${currentChunkNumber} with ${currentChunkData.current.length} blob(s)`,
        );

        // Clear the current chunk data
        currentChunkData.current = [];

        try {
          await uploadAudioChunk(audioBlob, currentChunkNumber);
        } catch (error) {
          console.error("Failed to upload chunk:", error);
        }
      }

      // Continue recording if we should
      if (shouldContinueRecording.current && mediaStream.current) {
        setTimeout(() => {
          startNewChunkRecording();
        }, 100); // Small delay to ensure clean restart
      }
    };

    newRecorder.onerror = (event) => {
      console.error("Recording error:", event);
      setErrorMessage("Erro durante a gravação.");
    };

    return newRecorder;
  };

  const startNewChunkRecording = () => {
    if (!shouldContinueRecording.current || !mediaStream.current) return;

    recorder.current = createNewRecorder();
    if (recorder.current) {
      console.log("Starting new chunk recording");
      recorder.current.start();

      // Set timeout to stop this chunk after CHUNK_DURATION
      setTimeout(() => {
        if (recorder.current && recorder.current.state === "recording") {
          recorder.current.stop();
        }
      }, CHUNK_DURATION);
    }
  };

  const stopRecording = async () => {
    console.log("Stopping recording...");
    setIsRecording(false);
    shouldContinueRecording.current = false;

    // Clear the interval
    if (chunkInterval.current) {
      clearInterval(chunkInterval.current);
      chunkInterval.current = null;
    }

    // Stop the current recording
    if (recorder.current && recorder.current.state !== "inactive") {
      recorder.current.stop();
    }

    // Release the microphone
    if (mediaStream.current) {
      mediaStream.current.getTracks().forEach((track) => {
        track.stop();
      });
      mediaStream.current = null;
    }
  };

  const startRecording = async () => {
    if (!isRecordingSupported) {
      setErrorMessage("Seu navegador não suporta gravação de áudio.");
      return;
    }

    try {
      console.log("Starting recording...");
      setIsRecording(true);
      setChunkCount(0);
      setErrorMessage(null);
      currentChunkData.current = [];
      isProcessingChunk.current = false;
      shouldContinueRecording.current = true;

      const audio = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44_100,
        },
      });

      mediaStream.current = audio;

      // Start the first chunk recording
      startNewChunkRecording();
    } catch (error) {
      console.error("Error starting recording:", error);
      setErrorMessage("Erro ao acessar o microfone. Verifique as permissões.");
      setIsRecording(false);
      shouldContinueRecording.current = false;
    }
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      shouldContinueRecording.current = false;
      if (chunkInterval.current) {
        clearInterval(chunkInterval.current);
      }
      if (mediaStream.current) {
        mediaStream.current.getTracks().forEach((track) => {
          track.stop();
        });
      }
    };
  }, []);

  return (
    <div className="flex h-screen flex-col items-center justify-center gap-6 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="flex items-center justify-center gap-2">
            <Mic className="h-5 w-5" />
            Gravação de Áudio
          </CardTitle>
          <CardDescription>
            Grave áudio em chunks de 5 segundos para a sala {roomId}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {!isRecordingSupported ? (
            <div className="text-center">
              <AlertCircle className="h-8 w-8 text-red-500 mx-auto mb-2" />
              <p className="text-red-500">Seu navegador não suporta gravação de áudio.</p>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex justify-center">
                {isRecording ? (
                  <Button
                    onClick={stopRecording}
                    variant="destructive"
                    size="lg"
                    className="flex items-center gap-2"
                  >
                    <MicOff className="h-4 w-4" />
                    Parar Gravação
                  </Button>
                ) : (
                  <Button onClick={startRecording} size="lg" className="flex items-center gap-2">
                    <Mic className="h-4 w-4" />
                    Iniciar Gravação
                  </Button>
                )}
              </div>

              {/* Status indicators */}
              <div className="space-y-2">
                {isRecording && (
                  <div className="text-center">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-red-100 text-red-800 text-sm">
                      <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></div>
                      Gravando...
                    </div>
                  </div>
                )}

                {uploadStatus === "uploading" && (
                  <div className="text-center">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-100 text-blue-800 text-sm">
                      <Upload className="h-3 w-3 animate-spin" />
                      Enviando chunk...
                    </div>
                  </div>
                )}

                {uploadStatus === "success" && (
                  <div className="text-center">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-green-100 text-green-800 text-sm">
                      ✓ Chunk enviado com sucesso
                    </div>
                  </div>
                )}

                {chunkCount > 0 && (
                  <div className="text-center text-sm text-gray-600">
                    Chunks enviados: {chunkCount}
                  </div>
                )}

                {errorMessage && (
                  <div className="text-center">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-red-100 text-red-800 text-sm">
                      <AlertCircle className="h-3 w-3" />
                      {errorMessage}
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <div className="text-center text-sm text-gray-500 max-w-md">
        <p>
          O áudio será gravado em chunks de 5 segundos e enviado automaticamente para processamento
          pela IA.
        </p>
      </div>
    </div>
  );
}
