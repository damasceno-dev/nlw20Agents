import Link from "next/link";
import { getRoomsList } from "@/api/generated/serverAPI";
import {Card, CardContent, CardDescription, CardHeader, CardTitle} from "@/components/ui/card";
import {ArrowRight} from "lucide-react";
import {Badge} from "@/components/ui/badge";
import {formatDate} from "@/utils/format-date";
import { CreateRoomForm } from "@/components/create-room-form";


export default async function CreateRoomPage() {
    let rooms: Awaited<ReturnType<typeof getRoomsList>> = [];
    try {
        rooms = await getRoomsList();
    } catch (error) {
        console.warn('Failed to fetch rooms during build:', error);
        // During build time or when API is unavailable, use empty array
    }

    return (
        <div className="min-h-screen p-4">
            <div className="mx-auto max-w-4xl">
                <div className="grid grid-cols-2 items-start gap-8">
                    <CreateRoomForm />
                    <Card>
                        <CardHeader>
                            <CardTitle>
                                Salas recentes
                            </CardTitle>
                            <CardDescription>
                                Acesso rápido para as salas criadas recentemente
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="flex flex-col gap-3">
                            {rooms?.map((room) => (
                                <div className="flex items-center justify-between rounded-lg border p-3 transition-all hover:bg-gray-800" key={room.id} >
                                    <div className="flex flex-1 flex-col gap-1">
                                        <h3 className="font-semibold text-lg">{room.name || 'Unnamed Room'}</h3>
                                        <div className="flex items-center gap-2">
                                            <Badge>{formatDate(room.createdOn)}</Badge>
                                            <Badge className="text-xs" variant="secondary">
                                                {room.questionsCount === 0
                                                    ? 'nenhuma pergunta'
                                                    : `${room.questionsCount} pergunta${room.questionsCount === 1 ? '' : 's'}`}
                                            </Badge>
                                        </div>
                                    </div>
                                    <Link
                                        className="flex items-center gap-1 rounded bg-blue-500 p-3 text-sm transition-all hover:bg-blue-600"
                                        href={`/room/${room.id}`}
                                    >
                                        Entrar
                                        <ArrowRight className="size-3" />
                                    </Link>
                                </div>
                            ))}
                        </CardContent>
                    </Card>
                </div>

                {rooms?.length === 0 && (
                    <p className="text-gray-500">No rooms found.</p>
                )}
            </div>
        </div>
    );
}
