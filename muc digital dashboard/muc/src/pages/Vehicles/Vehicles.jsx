import { useState, useEffect } from 'react';

const BASE_URL = 'http://localhost:3000/api';

function Toast({ message, type, onClose }) {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  return (
    <div className={`toast ${type}`}>
      {type === 'success' ? '\u2705' : '\u274C'} {message}
    </div>
  );
}

export default function Vehicles() {
  const [vehicles, setVehicles] = useState([]);
  const [vehicleTypes, setVehicleTypes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  const [form, setForm] = useState({
    name: '',
    type: '',
    pricePerDay: '',
    halfDayPrice: '',
    description: '',
    images: '',
    includedServices: '',
  });

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadVehicles = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${BASE_URL}/admin/vehicles`);
      const result = await res.json();
      setVehicles(result.data || []);
    } catch {
      showToast('Failed to load vehicles', 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadVehicleTypes = async () => {
    try {
      const res = await fetch(`${BASE_URL}/admin/vehicle-types`);
      const result = await res.json();
      setVehicleTypes((result.data || []).filter((t) => t.isActive));
    } catch {
      // silent
    }
  };

  useEffect(() => {
    loadVehicles();
    loadVehicleTypes();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const images = form.images
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    const services = form.includedServices
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);

    try {
      const res = await fetch(`${BASE_URL}/vehicles`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: form.name,
          type: form.type,
          description: form.description,
          pricePerDay: parseFloat(form.pricePerDay),
          halfDayPrice: parseFloat(form.halfDayPrice),
          images,
          includedServices: services,
        }),
      });
      if (res.ok) {
        showToast('Vehicle added!');
        setForm({
          name: '',
          type: '',
          pricePerDay: '',
          halfDayPrice: '',
          description: '',
          images: '',
          includedServices: '',
        });
        loadVehicles();
      } else {
        const r = await res.json();
        showToast(r.message || 'Error adding vehicle', 'error');
      }
    } catch {
      showToast('Error', 'error');
    }
  };

  const toggleStatus = async (id, isAvailable) => {
    try {
      const res = await fetch(`${BASE_URL}/vehicles/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isAvailable }),
      });
      const result = await res.json();
      if (res.ok) {
        showToast(result.message || 'Updated');
        loadVehicles();
      } else {
        showToast(result.message || 'Error', 'error');
      }
    } catch {
      showToast('Error', 'error');
    }
  };

  return (
    <>
      <div className="split">
        {/* Add Form */}
        <div className="card">
          <div className="card-header">
            <h3>Add Vehicle</h3>
          </div>
          <div className="card-body">
            <form onSubmit={handleSubmit}>
              <div className="form-grid">
                <div className="form-group full">
                  <label>Vehicle Name</label>
                  <input
                    type="text"
                    placeholder="Toyota Camry 2024"
                    value={form.name}
                    onChange={(e) =>
                      setForm({ ...form, name: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="form-group full">
                  <label>Vehicle Type</label>
                  <select
                    value={form.type}
                    onChange={(e) =>
                      setForm({ ...form, type: e.target.value })
                    }
                    required
                  >
                    <option value="">Select Type</option>
                    {vehicleTypes.map((t) => (
                      <option key={t._id} value={t._id}>
                        {t.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label>Full Day Price ($)</label>
                  <input
                    type="number"
                    placeholder="150"
                    value={form.pricePerDay}
                    onChange={(e) =>
                      setForm({ ...form, pricePerDay: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Half Day Price ($)</label>
                  <input
                    type="number"
                    placeholder="90"
                    value={form.halfDayPrice}
                    onChange={(e) =>
                      setForm({ ...form, halfDayPrice: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="form-group full">
                  <label>Description</label>
                  <textarea
                    placeholder="Optional description"
                    value={form.description}
                    onChange={(e) =>
                      setForm({ ...form, description: e.target.value })
                    }
                  />
                </div>
                <div className="form-group full">
                  <label>Image URLs (comma separated)</label>
                  <textarea
                    placeholder="https://..."
                    value={form.images}
                    onChange={(e) =>
                      setForm({ ...form, images: e.target.value })
                    }
                  />
                </div>
                <div className="form-group full">
                  <label>Included Services (comma separated)</label>
                  <textarea
                    placeholder="GPS, Insurance, Fuel"
                    value={form.includedServices}
                    onChange={(e) =>
                      setForm({ ...form, includedServices: e.target.value })
                    }
                  />
                </div>
                <div className="form-group full">
                  <button
                    type="submit"
                    className="btn btn-primary"
                    style={{ width: '100%' }}
                  >
                    + Add Vehicle
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>

        {/* Vehicles List */}
        <div className="card">
          <div className="card-header">
            <h3>Vehicles</h3>
            <button className="btn btn-ghost btn-sm" onClick={loadVehicles}>
              Refresh
            </button>
          </div>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Full Day</th>
                  <th>Half Day</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan="6">
                      <div className="empty-state">
                        <div className="empty-icon">&#128663;</div>
                        Loading...
                      </div>
                    </td>
                  </tr>
                ) : vehicles.length === 0 ? (
                  <tr>
                    <td colSpan="6">
                      <div className="empty-state">
                        <div className="empty-icon">&#128663;</div>
                        No vehicles yet.
                      </div>
                    </td>
                  </tr>
                ) : (
                  vehicles.map((v) => (
                    <tr key={v._id}>
                      <td>{v.name}</td>
                      <td style={{ color: 'var(--muted)', fontSize: 12 }}>
                        {v.type?.name || '---'}
                      </td>
                      <td>${v.pricePerDay}</td>
                      <td>${v.halfDayPrice}</td>
                      <td>
                        <span
                          className={`badge ${
                            v.isAvailable
                              ? 'badge-available'
                              : 'badge-unavailable'
                          }`}
                        >
                          {v.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE'}
                        </span>
                      </td>
                      <td>
                        {v.isAvailable ? (
                          <button
                            className="btn btn-danger btn-sm"
                            onClick={() => toggleStatus(v._id, false)}
                          >
                            Disable
                          </button>
                        ) : (
                          <button
                            className="btn btn-primary btn-sm"
                            onClick={() => toggleStatus(v._id, true)}
                          >
                            Enable
                          </button>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
    </>
  );
}
