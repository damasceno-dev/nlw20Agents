import {getQuestionsRoomIdList, getRoomsRoomIdGetbyid} from "@/api/generated/serverAPI";
import { CreateQuestionForm } from "@/components/create-question-form";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { formatDate } from "@/utils/format-date";
import Link from "next/link";
import { ArrowLeft, Mic } from "lucide-react";

interface RoomPageProps {
  params: { id: string };
}

export default async function RoomPage({ params }: RoomPageProps) {
  // Await params before using its properties
  const { id } = await params;
  const questions = await getQuestionsRoomIdList(id);
  const room = await getRoomsRoomIdGetbyid(id);

  return (
    <div className="mt-10 min-h-screen p-4">
      <div className="mx-auto max-w-4xl">
        <div className="mb-8 flex justify-between gap-4">
          <Button asChild size="sm" variant="outline" >
            <Link href="/" className="flex items-center gap-2"  >
              <ArrowLeft className="h-4 w-4" />
              Voltar ao início
            </Link>
          </Button>
          <Button className="hover:cursor-pointer flex items-center gap-2" size="sm"  variant="outline" >
            <Link href="/record-room-audio" className="flex items-center gap-2"  >
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

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
          {/* Questions List */}
          <div className="lg:col-span-2">

            <p className="mb-2 text-gray-600">Gerencie suas perguntas e respostas</p>
            <Card>
              <CardHeader>
                <CardTitle>Perguntas</CardTitle>
                <CardDescription>
                  {questions?.length === 0 
                    ? "Nenhuma pergunta ainda. Seja o primeiro a perguntar!"
                    : `${questions?.length} pergunta${questions?.length === 1 ? '' : 's'}`
                  }
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {questions?.map((question) => (
                  <div className="rounded-lg border p-4" key={question.id}>
                    <div className="mb-3 flex items-start justify-between">
                      <h3 className="font-semibold text-lg">
                        {question.question || "Pergunta sem título"}
                      </h3>
                      <Badge className="text-xs" variant="secondary">
                        {formatDate(question.createdOn)}
                      </Badge>
                    </div>

                    {question.answer && (
                      <div className="mt-3 rounded-lg bg-gray-50 p-3">
                        <p className="text-gray-700 text-sm">{question.answer}</p>
                      </div>
                    )}

                    {!question.answer && (
                      <div className="mt-2 text-gray-500 text-sm italic">
                        Aguardando resposta...
                      </div>
                    )}
                  </div>
                ))}

                {questions?.length === 0 && (
                  <div className="py-8 text-center text-gray-500">
                    <p>Nenhuma pergunta encontrada.</p>
                    <p className="text-sm">Crie a primeira pergunta usando o formulário ao lado.</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Create Question Form */}
          <div>
            <CreateQuestionForm roomId={id} />
          </div>
        </div>
      </div>
    </div>
  );
}
