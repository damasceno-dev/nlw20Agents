'use client';

export default function ErrorBoundary({
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="p-6">
      <h2 className="mb-4 font-bold text-xl">Something went wrong!</h2>
      <p className="mb-4 text-gray-600">Failed to load rooms.</p>
      <button
        className="rounded bg-blue-500 px-4 py-2 text-white transition-all hover:cursor-pointer hover:bg-blue-600"
        onClick={() => reset()}
        type="button"
      >
        Try again
      </button>
    </div>
  );
}
