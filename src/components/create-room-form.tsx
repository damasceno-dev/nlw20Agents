"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { usePostRoomsCreate } from "@/api/generated/serverAPI";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Loader2, Plus } from "lucide-react";

export function CreateRoomForm() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const createRoomMutation = usePostRoomsCreate({
    mutation: {
      onSuccess: (data) => {
        // Redirect to the newly created room
        router.push(`/room/${data.id}`);
      },
      onError: (error) => {
        console.error("Failed to create room:", error);
        // You could add toast notification here
      },
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    if (!name.trim()) {
      return; // Don't submit if name is empty
    }

    createRoomMutation.mutate({
      data: {
        name: name.trim(),
        description: description.trim() || "", // Send empty string instead of null
      },
    });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Plus className="size-5" />
          Criar nova sala
        </CardTitle>
        <CardDescription>
          Crie uma nova sala para fazer perguntas e obter respostas
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Nome da sala *</Label>
            <Input
              id="name"
              type="text"
              placeholder="Digite o nome da sala"
              value={name}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setName(e.target.value)}
              required
              disabled={createRoomMutation.isPending}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Descrição (opcional)</Label>
            <Textarea
              id="description"
              placeholder="Descreva o propósito desta sala..."
              value={description}
              onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(e.target.value)}
              disabled={createRoomMutation.isPending}
              rows={3}
            />
          </div>

          <Button
            type="submit"
            className="w-full"
            disabled={createRoomMutation.isPending || !name.trim()}
          >
            {createRoomMutation.isPending ? (
              <>
                <Loader2 className="mr-2 size-4 animate-spin" />
                Criando sala...
              </>
            ) : (
              <>
                <Plus className="mr-2 size-4" />
                Criar sala
              </>
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
} 