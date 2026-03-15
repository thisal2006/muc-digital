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

export default function VehicleTypes() {
  const [types, setTypes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  const [form, setForm] = useState({ name: '', description: '', image: '' });

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadTypes = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${BASE_URL}/admin/vehicle-types`);
      const result = await res.json();
      setTypes(result.data || []);
    } catch {
      showToast('Failed to load vehicle types', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTypes();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch(`${BASE_URL}/vehicle-types`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      if (res.ok) {
        showToast('Vehicle type added!');
        setForm({ name: '', description: '', image: '' });
        loadTypes();
      } else {
        const r = await res.json();
        showToast(r.message || 'Error adding type', 'error');
      }
    } catch {
      showToast('Error', 'error');
    }
  };

  const toggleStatus = async (id, isActive) => {
    try {
      const res = await fetch(`${BASE_URL}/vehicle-types/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive }),
      });
      const result = await res.json();
      if (res.ok) {
        showToast(result.message || 'Updated');
        loadTypes();
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
            <h3>Add Vehicle Type</h3>
          </div>
          <div className="card-body">
            <form onSubmit={handleSubmit}>
              <div className="form-grid">
                <div className="form-group full">
                  <label>Type Name</label>
                  <input
                    type="text"
                    placeholder="e.g. Sedan"
                    value={form.name}
                    onChange={(e) =>
                      setForm({ ...form, name: e.target.value })
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
                  <label>Image URL</label>
                  <input
                    type="text"
                    placeholder="https://..."
                    value={form.image}
                    onChange={(e) =>
                      setForm({ ...form, image: e.target.value })
                    }
                  />
                </div>
                <div className="form-group full">
                  <button
                    type="submit"
                    className="btn btn-primary"
                    style={{ width: '100%' }}
                  >
                    + Add Type
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>

        {/* Types List */}
        <div className="card">
          <div className="card-header">
            <h3>Vehicle Types</h3>
            <button className="btn btn-ghost btn-sm" onClick={loadTypes}>
              Refresh
            </button>
          </div>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Description</th>
                  <th>Image</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan="5">
                      <div className="empty-state">
                        <div className="empty-icon">&#128203;</div>
                        Loading...
                      </div>
                    </td>
                  </tr>
                ) : types.length === 0 ? (
                  <tr>
                    <td colSpan="5">
                      <div className="empty-state">
                        <div className="empty-icon">&#128203;</div>
                        No types yet.
                      </div>
                    </td>
                  </tr>
                ) : (
                  types.map((t) => (
                    <tr key={t._id}>
                      <td>{t.name}</td>
                      <td style={{ color: 'var(--muted)', fontSize: 12 }}>
                        {t.description || '---'}
                      </td>
                      <td>
                        {t.image ? (
                          <img className="thumb" src={t.image} alt="" />
                        ) : (
                          '---'
                        )}
                      </td>
                      <td>
                        <span
                          className={`badge ${
                            t.isActive ? 'badge-active' : 'badge-inactive'
                          }`}
                        >
                          {t.isActive ? 'ACTIVE' : 'INACTIVE'}
                        </span>
                      </td>
                      <td>
                        {t.isActive ? (
                          <button
                            className="btn btn-danger btn-sm"
                            onClick={() => toggleStatus(t._id, false)}
                          >
                            Disable
                          </button>
                        ) : (
                          <button
                            className="btn btn-primary btn-sm"
                            onClick={() => toggleStatus(t._id, true)}
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
