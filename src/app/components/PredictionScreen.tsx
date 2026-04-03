import { useState } from "react";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Wheat, TrendingUp, CloudRain, Leaf } from "lucide-react";

export default function PredictionScreen() {
  const [formData, setFormData] = useState({
    nitrogen: "",
    phosphorus: "",
    potassium: "",
    temperature: "",
    humidity: "",
    ph: "",
    rainfall: "",
    state: "",
    area: "",
  });

  const [results, setResults] = useState<{
    crop: string;
    yield: string;
    season: string;
  } | null>(null);

  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handlePredict = () => {
    setIsLoading(true);
    // Simulate API call
    setTimeout(() => {
      setResults({
        crop: "Rice",
        yield: "5.3 tons per hectare",
        season: "Kharif (June - October)",
      });
      setIsLoading(false);
    }, 1500);
  };

  return (
    <div className="pb-20 px-4 pt-6 bg-[#F5F5F5] min-h-screen">
      {/* Header */}
      <div className="mb-6 text-center">
        <div className="flex items-center justify-center gap-2 mb-1">
          <Leaf className="w-7 h-7 text-[#2E7D32]" />
          <h1 className="text-2xl text-[#2E7D32]">AgroVision</h1>
        </div>
        <p className="text-sm text-gray-600">Smart Agriculture Decision System</p>
      </div>

      {/* Input Form Card */}
      <Card className="mb-6 shadow-md border-0">
        <CardContent className="p-5">
          <h2 className="text-lg mb-4 text-gray-800">Soil & Climate Parameters</h2>
          
          <div className="space-y-4">
            {/* Nitrogen */}
            <div>
              <Label htmlFor="nitrogen" className="text-gray-700 text-sm">
                Nitrogen (N) - kg/ha
              </Label>
              <Input
                id="nitrogen"
                type="number"
                placeholder="e.g., 90"
                value={formData.nitrogen}
                onChange={(e) => handleInputChange("nitrogen", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* Phosphorus */}
            <div>
              <Label htmlFor="phosphorus" className="text-gray-700 text-sm">
                Phosphorus (P) - kg/ha
              </Label>
              <Input
                id="phosphorus"
                type="number"
                placeholder="e.g., 42"
                value={formData.phosphorus}
                onChange={(e) => handleInputChange("phosphorus", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* Potassium */}
            <div>
              <Label htmlFor="potassium" className="text-gray-700 text-sm">
                Potassium (K) - kg/ha
              </Label>
              <Input
                id="potassium"
                type="number"
                placeholder="e.g., 43"
                value={formData.potassium}
                onChange={(e) => handleInputChange("potassium", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* Temperature */}
            <div>
              <Label htmlFor="temperature" className="text-gray-700 text-sm">
                Temperature - °C
              </Label>
              <Input
                id="temperature"
                type="number"
                placeholder="e.g., 25.5"
                value={formData.temperature}
                onChange={(e) => handleInputChange("temperature", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* Humidity */}
            <div>
              <Label htmlFor="humidity" className="text-gray-700 text-sm">
                Humidity - %
              </Label>
              <Input
                id="humidity"
                type="number"
                placeholder="e.g., 80"
                value={formData.humidity}
                onChange={(e) => handleInputChange("humidity", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* Soil pH */}
            <div>
              <Label htmlFor="ph" className="text-gray-700 text-sm">
                Soil pH
              </Label>
              <Input
                id="ph"
                type="number"
                placeholder="e.g., 6.5"
                value={formData.ph}
                onChange={(e) => handleInputChange("ph", e.target.value)}
                className="mt-1.5 h-12 text-base"
                step="0.1"
              />
            </div>

            {/* Rainfall */}
            <div>
              <Label htmlFor="rainfall" className="text-gray-700 text-sm">
                Rainfall - mm
              </Label>
              <Input
                id="rainfall"
                type="number"
                placeholder="e.g., 203.5"
                value={formData.rainfall}
                onChange={(e) => handleInputChange("rainfall", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>

            {/* State */}
            <div>
              <Label htmlFor="state" className="text-gray-700 text-sm">
                State
              </Label>
              <Select value={formData.state} onValueChange={(value) => handleInputChange("state", value)}>
                <SelectTrigger className="mt-1.5 h-12 text-base">
                  <SelectValue placeholder="Select state" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="punjab">Punjab</SelectItem>
                  <SelectItem value="haryana">Haryana</SelectItem>
                  <SelectItem value="uttar-pradesh">Uttar Pradesh</SelectItem>
                  <SelectItem value="maharashtra">Maharashtra</SelectItem>
                  <SelectItem value="karnataka">Karnataka</SelectItem>
                  <SelectItem value="tamil-nadu">Tamil Nadu</SelectItem>
                  <SelectItem value="west-bengal">West Bengal</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Area of Land */}
            <div>
              <Label htmlFor="area" className="text-gray-700 text-sm">
                Area of Land - hectares
              </Label>
              <Input
                id="area"
                type="number"
                placeholder="e.g., 2.5"
                value={formData.area}
                onChange={(e) => handleInputChange("area", e.target.value)}
                className="mt-1.5 h-12 text-base"
              />
            </div>
          </div>

          {/* Predict Button */}
          <Button
            onClick={handlePredict}
            disabled={isLoading}
            className="w-full h-14 mt-6 text-base bg-[#2E7D32] hover:bg-[#1B5E20] text-white"
          >
            {isLoading ? "Analyzing..." : "Predict Crop Insights"}
          </Button>
        </CardContent>
      </Card>

      {/* Results Section */}
      {results && (
        <div className="space-y-4 animate-in fade-in duration-500">
          <h2 className="text-lg text-gray-800 mb-3">Prediction Results</h2>
          
          {/* Recommended Crop */}
          <Card className="shadow-md border-0 bg-gradient-to-br from-white to-[#A5D6A7]/10">
            <CardContent className="p-5">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-full bg-[#2E7D32]/10 flex items-center justify-center flex-shrink-0">
                  <Wheat className="w-6 h-6 text-[#2E7D32]" />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-600 mb-1">Recommended Crop</p>
                  <p className="text-xl text-[#2E7D32]">{results.crop}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Predicted Yield */}
          <Card className="shadow-md border-0 bg-gradient-to-br from-white to-[#A5D6A7]/10">
            <CardContent className="p-5">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-full bg-[#2E7D32]/10 flex items-center justify-center flex-shrink-0">
                  <TrendingUp className="w-6 h-6 text-[#2E7D32]" />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-600 mb-1">Expected Yield</p>
                  <p className="text-xl text-[#2E7D32]">{results.yield}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Best Season */}
          <Card className="shadow-md border-0 bg-gradient-to-br from-white to-[#A5D6A7]/10">
            <CardContent className="p-5">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-full bg-[#2E7D32]/10 flex items-center justify-center flex-shrink-0">
                  <CloudRain className="w-6 h-6 text-[#2E7D32]" />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-600 mb-1">Best Season</p>
                  <p className="text-xl text-[#2E7D32]">{results.season}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
