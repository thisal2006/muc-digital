import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import PublicRoute from './components/PublicRoute';
import Login from './pages/Login/Login';
import DashboardLayout from './components/layout/DashboardLayout';
import Home from './pages/Home/Home';
import Dashboard from './pages/Dashboard/Dashboard';
import Bookings from './pages/Bookings/Bookings';
import Vehicles from './pages/Vehicles/Vehicles';
import VehicleTypes from './pages/VehicleTypes/VehicleTypes';
import Cemetery from './pages/Cemetery/Cemetery';
import Property from './pages/Property/Property';
import Notifications from './pages/Notifications/Notifications';
import Complaints from './pages/Complaints/Complaints';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          } />

          <Route element={
            <ProtectedRoute>
              <DashboardLayout />
            </ProtectedRoute>
          }>
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
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/complaints" element={<Complaints />} />
          </Route>

          {/* Catch-all route to redirect unknown paths */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
