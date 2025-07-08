export default function Room({ params }: { params: { id: string } }) {
    return (
        <h1>Room details: {params.id}</h1>
    )
}