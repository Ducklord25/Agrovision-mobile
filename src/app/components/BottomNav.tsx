import { BarChart3, Sprout } from "lucide-react";

interface BottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export default function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-lg">
      <div className="flex items-center justify-around h-16 max-w-md mx-auto">
        <button
          onClick={() => onTabChange("prediction")}
          className={`flex flex-col items-center justify-center flex-1 h-full transition-colors ${
            activeTab === "prediction"
              ? "text-[#2E7D32]"
              : "text-gray-500"
          }`}
        >
          <Sprout className="w-6 h-6" />
          <span className="text-xs mt-1">Prediction</span>
        </button>
        <button
          onClick={() => onTabChange("analytics")}
          className={`flex flex-col items-center justify-center flex-1 h-full transition-colors ${
            activeTab === "analytics"
              ? "text-[#2E7D32]"
              : "text-gray-500"
          }`}
        >
          <BarChart3 className="w-6 h-6" />
          <span className="text-xs mt-1">Analytics</span>
        </button>
      </div>
    </div>
  );
}
