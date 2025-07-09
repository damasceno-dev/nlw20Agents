"use client";

import { useState } from "react";
import { usePostQuestionsRoomIdCreate } from "@/api/generated/serverAPI";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Loader2, MessageSquarePlus } from "lucide-react";

interface CreateQuestionFormProps {
  roomId: string;
}

export function CreateQuestionForm({ roomId }: CreateQuestionFormProps) {
  const [question, setQuestion] = useState("");

  const createQuestionMutation = usePostQuestionsRoomIdCreate({
    mutation: {
      onSuccess: () => {
        // Reset form and refresh the page to show new question
        setQuestion("");
        window.location.reload();
      },
      onError: (error) => {
        console.error("Failed to create question:", error);
        // You could add toast notification here
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
        answer: "", // Send empty string instead of null
      },
    });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <MessageSquarePlus className="size-5" />
          Nova pergunta
        </CardTitle>
        <CardDescription>
          Faça uma pergunta para obter uma resposta
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="question">Sua pergunta *</Label>
            <Textarea
              id="question"
              placeholder="Digite sua pergunta aqui..."
              value={question}
              onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setQuestion(e.target.value)}
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
  );
} 