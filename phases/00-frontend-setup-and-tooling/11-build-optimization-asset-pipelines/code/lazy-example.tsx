import { lazy, Suspense } from "react";

const HeavyChart = lazy(() => import("./HeavyChart"));

export function Dashboard() {
  return (
    <Suspense fallback={<div>Loading chart...</div>}>
      <HeavyChart />
    </Suspense>
  );
}
