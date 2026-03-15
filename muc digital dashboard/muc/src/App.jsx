import { BrowserRouter, Routes, Route } from 'react-router-dom';
import DashboardLayout from './components/layout/DashboardLayout';
import Home from './pages/Home/Home';
import Dashboard from './pages/Dashboard/Dashboard';
import Bookings from './pages/Bookings/Bookings';
import Vehicles from './pages/Vehicles/Vehicles';
import VehicleTypes from './pages/VehicleTypes/VehicleTypes';
import Cemetery from './pages/Cemetery/Cemetery';
import Property from './pages/Property/Property';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<DashboardLayout />}>
          {/* Home */}
          <Route path="/" element={<Home />} />

          {/* Vehicle Management */}
          <Route path="/vehicle" element={<Dashboard />} />
          <Route path="/vehicle/bookings" element={<Bookings />} />
          <Route path="/vehicle/list" element={<Vehicles />} />
          <Route path="/vehicle/types" element={<VehicleTypes />} />

          {/* Other Modules (blank) */}
          <Route path="/cemetery" element={<Cemetery />} />
          <Route path="/property" element={<Property />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
