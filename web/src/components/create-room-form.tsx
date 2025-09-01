"use client";

import { Loader2, Plus } from "lucide-react";
import { useRouter } from "next/navigation";
import type React from "react";
import { useState } from "react";
import { usePostRoomsCreate, getGetRoomsListQueryKey } from "@/api/generated/serverAPI";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export function CreateRoomForm() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const createRoomMutation = usePostRoomsCreate({
    mutation: {
      onSuccess: (data) => {
        // Invalidate and refetch rooms list
        queryClient.invalidateQueries({ queryKey: getGetRoomsListQueryKey() });
        // Redirect to the newly created room
        router.push(`/room/${data.id}`);
      },
      onError: (_error) => {
        // You could add toast notification here
      },
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    if (!name.trim()) {
      return;
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
        <form className="space-y-4" onSubmit={handleSubmit}>
          <div className="space-y-2">
            <Label htmlFor="name">Nome da sala *</Label>
            <Input
              disabled={createRoomMutation.isPending}
              id="name"
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setName(e.target.value)}
              placeholder="Digite o nome da sala"
              required
              type="text"
              value={name}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Descrição (opcional)</Label>
            <Textarea
              disabled={createRoomMutation.isPending}
              id="description"
              onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(e.target.value)}
              placeholder="Descreva o propósito desta sala..."
              rows={3}
              value={description}
            />
          </div>

          <Button
            className="w-full"
            disabled={createRoomMutation.isPending || !name.trim()}
            type="submit"
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