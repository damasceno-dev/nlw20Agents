import Link from "next/link";

export default function  CreateRoomPage() {
    return (
        <div>
            <h1>Create room</h1>
            <Link href={'/room/2'}>Acessa sala</Link>
        </div>
    )
}