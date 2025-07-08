import Link from "next/link";
import { getRoomsGetall } from "@/api/generated/serverAPI";

export default async function CreateRoomPage() {
    const rooms = await getRoomsGetall();

    return (
        <div className="p-6">
            <h1 className="mb-6 font-bold text-2xl">Rooms</h1>
            
            <div className="grid gap-4">
                {rooms?.map((room) => (
                    <div className="rounded-lg border p-4 transition-all hover:bg-gray-800" key={room.id} > 
                        <h2 className="font-semibold text-lg">{room.name || 'Unnamed Room'}</h2>
                        <Link 
                            className="mt-2 inline-block rounded bg-blue-500 px-4 py-2 transition-all hover:bg-blue-600"
                            href={`/room/${room.id}`}
                        >
                            Access Room
                        </Link>
                    </div>
                ))}
            </div>

            {rooms?.length === 0 && (
                <p className="text-gray-500">No rooms found.</p>
            )}
        </div>
    );
}