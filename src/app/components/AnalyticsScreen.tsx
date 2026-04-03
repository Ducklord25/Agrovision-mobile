import { Card, CardContent } from "./ui/card";
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { TrendingUp, Award, Leaf, CloudRain } from "lucide-react";

const yieldData = [
  { crop: "Rice", yield: 5.3 },
  { crop: "Wheat", yield: 4.8 },
  { crop: "Cotton", yield: 3.2 },
  { crop: "Sugarcane", yield: 6.5 },
  { crop: "Maize", yield: 4.1 },
];

const rainfallTrendData = [
  { month: "Jan", rainfall: 20, yield: 3.2 },
  { month: "Feb", rainfall: 25, yield: 3.5 },
  { month: "Mar", rainfall: 45, yield: 3.8 },
  { month: "Apr", rainfall: 60, yield: 4.2 },
  { month: "May", rainfall: 85, yield: 4.8 },
  { month: "Jun", rainfall: 150, yield: 5.3 },
];

const cropDistributionData = [
  { name: "Rice", value: 35, color: "#2E7D32" },
  { name: "Wheat", value: 25, color: "#66BB6A" },
  { name: "Cotton", value: 20, color: "#A5D6A7" },
  { name: "Sugarcane", value: 12, color: "#81C784" },
  { name: "Others", value: 8, color: "#C8E6C9" },
];

const yieldVsRainfallData = [
  { rainfall: 50, yield: 2.1 },
  { rainfall: 100, yield: 3.2 },
  { rainfall: 150, yield: 4.5 },
  { rainfall: 200, yield: 5.3 },
  { rainfall: 250, yield: 5.8 },
  { rainfall: 300, yield: 5.5 },
  { rainfall: 350, yield: 4.8 },
  { rainfall: 400, yield: 3.9 },
];

export default function AnalyticsScreen() {
  return (
    <div className="pb-20 px-4 pt-6 bg-[#F5F5F5] min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl text-[#2E7D32] mb-1">Analytics Dashboard</h1>
        <p className="text-sm text-gray-600">Agricultural Insights & Statistics</p>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        {/* Average Yield */}
        <Card className="shadow-md border-0">
          <CardContent className="p-4">
            <div className="flex flex-col items-center text-center">
              <div className="w-10 h-10 rounded-full bg-[#2E7D32]/10 flex items-center justify-center mb-2">
                <TrendingUp className="w-5 h-5 text-[#2E7D32]" />
              </div>
              <p className="text-xs text-gray-600 mb-1">Avg Yield</p>
              <p className="text-lg text-[#2E7D32]">4.8</p>
              <p className="text-xs text-gray-500">tons/ha</p>
            </div>
          </CardContent>
        </Card>

        {/* Best Performing Crop */}
        <Card className="shadow-md border-0">
          <CardContent className="p-4">
            <div className="flex flex-col items-center text-center">
              <div className="w-10 h-10 rounded-full bg-[#2E7D32]/10 flex items-center justify-center mb-2">
                <Award className="w-5 h-5 text-[#2E7D32]" />
              </div>
              <p className="text-xs text-gray-600 mb-1">Best Crop</p>
              <p className="text-base text-[#2E7D32]">Sugarcane</p>
              <p className="text-xs text-gray-500">6.5 t/ha</p>
            </div>
          </CardContent>
        </Card>

        {/* Soil Fertility Score */}
        <Card className="shadow-md border-0">
          <CardContent className="p-4">
            <div className="flex flex-col items-center text-center">
              <div className="w-10 h-10 rounded-full bg-[#2E7D32]/10 flex items-center justify-center mb-2">
                <Leaf className="w-5 h-5 text-[#2E7D32]" />
              </div>
              <p className="text-xs text-gray-600 mb-1">Fertility</p>
              <p className="text-lg text-[#2E7D32]">8.2</p>
              <p className="text-xs text-gray-500">out of 10</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Bar Chart - Crop Yield Comparison */}
      <Card className="shadow-md border-0 mb-6">
        <CardContent className="p-5">
          <h3 className="text-base text-gray-800 mb-4">Crop Yield Comparison</h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={yieldData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E0E0E0" />
              <XAxis 
                dataKey="crop" 
                tick={{ fontSize: 12 }}
                stroke="#757575"
              />
              <YAxis 
                tick={{ fontSize: 12 }}
                stroke="#757575"
                label={{ value: 'Yield (tons/ha)', angle: -90, position: 'insideLeft', fontSize: 12 }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'white', 
                  border: '1px solid #E0E0E0',
                  borderRadius: '8px',
                  fontSize: '12px'
                }}
              />
              <Bar dataKey="yield" fill="#2E7D32" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Line Chart - Rainfall vs Yield Trend */}
      <Card className="shadow-md border-0 mb-6">
        <CardContent className="p-5">
          <h3 className="text-base text-gray-800 mb-4">Rainfall vs Crop Yield Trend</h3>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={rainfallTrendData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E0E0E0" />
              <XAxis 
                dataKey="month" 
                tick={{ fontSize: 12 }}
                stroke="#757575"
              />
              <YAxis 
                yAxisId="left"
                tick={{ fontSize: 12 }}
                stroke="#757575"
                label={{ value: 'Rainfall (mm)', angle: -90, position: 'insideLeft', fontSize: 11 }}
              />
              <YAxis 
                yAxisId="right"
                orientation="right"
                tick={{ fontSize: 12 }}
                stroke="#757575"
                label={{ value: 'Yield (t/ha)', angle: 90, position: 'insideRight', fontSize: 11 }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'white', 
                  border: '1px solid #E0E0E0',
                  borderRadius: '8px',
                  fontSize: '12px'
                }}
              />
              <Legend wrapperStyle={{ fontSize: '12px' }} />
              <Line 
                yAxisId="left"
                type="monotone" 
                dataKey="rainfall" 
                stroke="#2196F3" 
                strokeWidth={2}
                dot={{ fill: '#2196F3', r: 4 }}
                name="Rainfall"
              />
              <Line 
                yAxisId="right"
                type="monotone" 
                dataKey="yield" 
                stroke="#2E7D32" 
                strokeWidth={2}
                dot={{ fill: '#2E7D32', r: 4 }}
                name="Yield"
              />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Pie Chart - Crop Distribution */}
      <Card className="shadow-md border-0 mb-6">
        <CardContent className="p-5">
          <h3 className="text-base text-gray-800 mb-4">Crop Distribution Statistics</h3>
          <ResponsiveContainer width="100%" height={240}>
            <PieChart>
              <Pie
                data={cropDistributionData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, value }) => `${name}: ${value}%`}
                outerRadius={80}
                fill="#8884d8"
                dataKey="value"
              >
                {cropDistributionData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'white', 
                  border: '1px solid #E0E0E0',
                  borderRadius: '8px',
                  fontSize: '12px'
                }}
              />
            </PieChart>
          </ResponsiveContainer>
          <div className="flex flex-wrap gap-2 mt-4 justify-center">
            {cropDistributionData.map((item, index) => (
              <div key={index} className="flex items-center gap-2">
                <div 
                  className="w-3 h-3 rounded-full" 
                  style={{ backgroundColor: item.color }}
                />
                <span className="text-xs text-gray-600">{item.name}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Yield vs Rainfall Trend - New Chart */}
      <Card className="shadow-md border-0 mb-6">
        <CardContent className="p-5">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-8 h-8 rounded-full bg-[#2E7D32]/10 flex items-center justify-center">
              <CloudRain className="w-4 h-4 text-[#2E7D32]" />
            </div>
            <h3 className="text-base text-gray-800">Yield vs Rainfall Trend</h3>
          </div>
          <p className="text-xs text-gray-600 mb-4">Relationship between rainfall levels and crop yield performance</p>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={yieldVsRainfallData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E0E0E0" />
              <XAxis 
                dataKey="rainfall" 
                tick={{ fontSize: 12 }}
                stroke="#757575"
                label={{ value: 'Rainfall (mm)', position: 'insideBottom', offset: -5, fontSize: 12 }}
              />
              <YAxis 
                tick={{ fontSize: 12 }}
                stroke="#757575"
                label={{ value: 'Yield (tons/ha)', angle: -90, position: 'insideLeft', fontSize: 12 }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'white', 
                  border: '1px solid #E0E0E0',
                  borderRadius: '8px',
                  fontSize: '12px'
                }}
                formatter={(value: number) => [`${value} tons/ha`, 'Yield']}
                labelFormatter={(label) => `Rainfall: ${label} mm`}
              />
              <Line 
                type="monotone" 
                dataKey="yield" 
                stroke="#2E7D32" 
                strokeWidth={3}
                dot={{ fill: '#2E7D32', r: 5, strokeWidth: 2, stroke: '#fff' }}
                activeDot={{ r: 7 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
}
