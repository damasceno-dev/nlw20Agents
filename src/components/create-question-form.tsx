"use client";

import { useQueryClient } from "@tanstack/react-query";
import { Loader2, MessageSquarePlus } from "lucide-react";
import { useState } from "react";
import {
  getGetQuestionsRoomIdListQueryKey,
  useGetQuestionsRoomIdList,
  usePostQuestionsRoomIdCreate,
} from "@/api/generated/serverAPI";
import type { ResponseQuestionJson } from "@/api/generated/serverAPI.schemas";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { formatDate } from "@/utils/format-date";

interface CreateQuestionFormProps {
  roomId: string;
  initialQuestions?: ResponseQuestionJson[];
}

export function CreateQuestionForm({ roomId, initialQuestions = [] }: CreateQuestionFormProps) {
  const [question, setQuestion] = useState("");
  const queryClient = useQueryClient();

  // Fetch questions using React Query
  const { data: unsortedQuestions = initialQuestions } = useGetQuestionsRoomIdList(roomId, {
    query: {
      initialData: initialQuestions,
    },
  });

  // Sort questions by creation date (newest first)
  const questions = [...unsortedQuestions].sort((a, b) => {
    const dateA = a.createdOn ? new Date(a.createdOn).getTime() : 0;
    const dateB = b.createdOn ? new Date(b.createdOn).getTime() : 0;
    return dateB - dateA;
  });

  const createQuestionMutation = usePostQuestionsRoomIdCreate({
    mutation: {
      // When mutation starts, update the cache optimistically
      onMutate: async (newQuestion) => {
        // Cancel any outgoing refetches
        await queryClient.cancelQueries({ queryKey: getGetQuestionsRoomIdListQueryKey(roomId) });

        // Snapshot the previous value
        const previousQuestions = queryClient.getQueryData(
          getGetQuestionsRoomIdListQueryKey(roomId),
        );

        // Create an optimistic question
        const optimisticQuestion: ResponseQuestionJson = {
          id: `temp-${Date.now()}`, // Temporary ID
          question: newQuestion.data.question,
          answer: null, // Set to null to show loading animation
          createdOn: new Date().toISOString(),
        };

        // Optimistically update the cache with sorted questions
        const updatedQuestions = [
          optimisticQuestion,
          ...((previousQuestions as ResponseQuestionJson[]) || []),
        ].sort((a, b) => {
          const dateA = a.createdOn ? new Date(a.createdOn).getTime() : 0;
          const dateB = b.createdOn ? new Date(b.createdOn).getTime() : 0;
          return dateB - dateA;
        });

        queryClient.setQueryData(getGetQuestionsRoomIdListQueryKey(roomId), updatedQuestions);

        // Return a context object with the snapshot
        return { previousQuestions };
      },
      // If the mutation fails, roll back to the previous value
      onError: (err, newQuestion, context) => {
        console.error("Failed to create question:", err);
        queryClient.setQueryData(
          getGetQuestionsRoomIdListQueryKey(roomId),
          context?.previousQuestions,
        );
      },
      // After the mutation is done (either success or error)
      onSettled: () => {
        // Refetch the questions to ensure cache is in sync with server
        queryClient.invalidateQueries({ queryKey: getGetQuestionsRoomIdListQueryKey(roomId) });
      },
      onSuccess: () => {
        // Reset form
        setQuestion("");
      },
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!question.trim()) {
      return; // Don't submit if question is empty
    }

    createQuestionMutation.mutate({
      roomId,
      data: {
        question: question.trim(),
        // Don't set answer property, let the server handle it
      },
    });
  };

  return (
    <div className="space-y-8">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquarePlus className="size-5" />
            Nova pergunta
          </CardTitle>
          <CardDescription>Faça uma pergunta para obter uma resposta</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="question">Sua pergunta *</Label>
              <Textarea
                id="question"
                placeholder="Digite sua pergunta aqui..."
                value={question}
                onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) =>
                  setQuestion(e.target.value)
                }
                required
                disabled={createQuestionMutation.isPending}
                rows={4}
              />
            </div>

            <Button
              type="submit"
              className="w-full"
              disabled={createQuestionMutation.isPending || !question.trim()}
            >
              {createQuestionMutation.isPending ? (
                <>
                  <Loader2 className="mr-2 size-4 animate-spin" />
                  Enviando pergunta...
                </>
              ) : (
                <>
                  <MessageSquarePlus className="mr-2 size-4" />
                  Enviar pergunta
                </>
              )}
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Questions List */}
      <Card>
        <CardHeader>
          <CardTitle>Perguntas</CardTitle>
          <CardDescription>
            {questions?.length === 0
              ? "Nenhuma pergunta ainda. Seja o primeiro a perguntar!"
              : `${questions?.length} pergunta${questions?.length === 1 ? "" : "s"}`}
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
                <div className="mt-2 text-gray-500 text-sm italic">Aguardando resposta...</div>
              )}
            </div>
          ))}

          {questions?.length === 0 && (
            <div className="py-8 text-center text-gray-500">
              <p>Nenhuma pergunta encontrada.</p>
              <p className="text-sm">Crie a primeira pergunta usando o formulário acima.</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
