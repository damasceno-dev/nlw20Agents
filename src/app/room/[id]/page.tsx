import { ArrowLeft, Mic } from "lucide-react";
import Link from "next/link";
import { getQuestionsRoomIdList, getRoomsRoomIdGetbyid } from "@/api/generated/serverAPI";
import { CreateQuestionForm } from "@/components/create-question-form";
import { Button } from "@/components/ui/button";

interface RoomPageProps {
  params: { id: string };
}

export default async function RoomPage({ params }: RoomPageProps) {
  // Await params before using its properties
  const { id } = await params;

  const questionsFromServer = await getQuestionsRoomIdList(id);
  const questions = questionsFromServer.sort((a, b) => {
    const dateA = a.createdOn ? new Date(a.createdOn).getTime() : 0;
    const dateB = b.createdOn ? new Date(b.createdOn).getTime() : 0;
    return dateB - dateA;
  });

  const room = await getRoomsRoomIdGetbyid(id);

  return (
    <div className="mt-10 min-h-screen p-4">
      <div className="mx-auto max-w-4xl">
        <div className="mb-8 flex justify-between gap-4">
          <Button asChild size="sm" variant="outline">
            <Link href="/" className="flex items-center gap-2">
              <ArrowLeft className="h-4 w-4" />
              Voltar ao início
            </Link>
          </Button>
          <Button
            className="hover:cursor-pointer flex items-center gap-2"
            size="sm"
            variant="outline"
          >
            <Link href="/record-room-audio" className="flex items-center gap-2">
              <Mic className="h-4 w-4" />
              Gravar Áudio
            </Link>
          </Button>
        </div>
        <div className="mb-6">
          <h1 className="font-bold text-3xl">Sala {room.name || "Sala sem nome"}</h1>
          {room.description && room.description.trim().length > 0 && (
            <p className="text-gray-600">{room.description}</p>
          )}
        </div>

        <div>
          <p className="mb-2 text-gray-600">Gerencie suas perguntas e respostas</p>
          <CreateQuestionForm roomId={id} initialQuestions={questions} />
        </div>
      </div>
    </div>
  );
}
