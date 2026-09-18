export default function DashboardLoading() {
  return (
    <div className="mx-auto max-w-4xl animate-pulse p-8">
      <div className="h-8 w-48 rounded bg-gray-200" />
      <div className="mt-8 space-y-3">
        {Array.from({ length: 5 }).map((_, index) => (
          <div key={index} className="h-10 rounded bg-gray-100" />
        ))}
      </div>
    </div>
  );
}
