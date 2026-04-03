import { useState } from "react";
import PredictionScreen from "./components/PredictionScreen";
import AnalyticsScreen from "./components/AnalyticsScreen";
import BottomNav from "./components/BottomNav";

export default function App() {
  const [activeTab, setActiveTab] = useState<string>("prediction");

  return (
    <div className="bg-[#F5F5F5] min-h-screen max-w-md mx-auto relative">
      {/* Main Content */}
      <div className="min-h-screen">
        {activeTab === "prediction" ? (
          <PredictionScreen />
        ) : (
          <AnalyticsScreen />
        )}
      </div>

      {/* Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />
    </div>
  );
}
