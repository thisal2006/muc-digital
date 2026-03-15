import { useState, useEffect } from 'react';

const BASE_URL = 'http://localhost:3000/api';

function fmt(d) {
  return new Date(d).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

function StatusBadge({ status }) {
  const cls = {
    CONFIRMED: 'badge-confirmed',
    PENDING: 'badge-pending',
    CANCELLED: 'badge-cancelled',
  }[status] || 'badge-pending';
  return <span className={`badge ${cls}`}>{status}</span>;
}

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

export default function Bookings() {
  const [bookings, setBookings] = useState([]);
  const [filter, setFilter] = useState('ALL');
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  // Modal state
  const [approveModal, setApproveModal] = useState(null);
  const [cancelModal, setCancelModal] = useState(null);
  const [cancelReason, setCancelReason] = useState('');

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadBookings = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${BASE_URL}/bookings`);
      const result = await res.json();
      setBookings(result.data || []);
    } catch {
      showToast('Failed to load bookings', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadBookings();
  }, []);

  const filtered =
    filter === 'ALL' ? bookings : bookings.filter((b) => b.status === filter);

  const handleApprove = async () => {
    try {
      const res = await fetch(`${BASE_URL}/bookings/${approveModal}/approve`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
      });
      const result = await res.json();
      setApproveModal(null);
      if (res.ok) {
        showToast('Booking approved successfully!');
        loadBookings();
      } else {
        showToast(result.message || 'Failed to approve booking', 'error');
      }
    } catch {
      showToast('Error approving booking', 'error');
    }
  };

  const handleCancel = async () => {
    if (!cancelReason.trim()) {
      showToast('Please enter a cancellation reason', 'error');
      return;
    }
    try {
      const res = await fetch(`${BASE_URL}/bookings/${cancelModal}/cancel`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: cancelReason }),
      });
      const result = await res.json();
      setCancelModal(null);
      setCancelReason('');
      if (res.ok) {
        showToast('Booking cancelled.');
        loadBookings();
      } else {
        showToast(result.message || 'Failed to cancel', 'error');
      }
    } catch {
      showToast('Error cancelling booking', 'error');
    }
  };

  const filters = ['ALL', 'PENDING', 'CONFIRMED', 'CANCELLED'];

  return (
    <>
      <div className="card">
        <div className="card-header">
          <h3>All Bookings</h3>
          <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <div className="filter-tabs">
              {filters.map((f) => (
                <button
                  key={f}
                  className={`filter-tab${filter === f ? ' active' : ''}`}
                  onClick={() => setFilter(f)}
                >
                  {f.charAt(0) + f.slice(1).toLowerCase()}
                </button>
              ))}
            </div>
            <button className="btn btn-ghost btn-sm" onClick={loadBookings}>
              Refresh
            </button>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Vehicle</th>
                <th>Booking Type</th>
                <th>User</th>
                <th>Phone</th>
                <th>Date Range</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Cancel Reason</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="9">
                    <div className="empty-state">
                      <div className="empty-icon">&#128203;</div>
                      Loading...
                    </div>
                  </td>
                </tr>
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan="9">
                    <div className="empty-state">
                      <div className="empty-icon">&#128203;</div>
                      No bookings found.
                    </div>
                  </td>
                </tr>
              ) : (
                filtered.map((b) => (
                  <tr key={b._id}>
                    <td>{b.vehicle?.name || '---'}</td>
                    <td style={{ fontSize: 12 }}>
                      {b.bookingType.replace(/_/g, ' ')}
                    </td>
                    <td>{b.userName || '---'}</td>
                    <td>{b.userPhone || '---'}</td>
                    <td style={{ fontSize: 12 }}>
                      {fmt(b.startDate)}
                      <br />
                      <span style={{ color: 'var(--muted)' }}>
                        &rarr; {fmt(b.endDate)}
                      </span>
                    </td>
                    <td>${b.totalAmount}</td>
                    <td>
                      <StatusBadge status={b.status} />
                    </td>
                    <td style={{ fontSize: 12, color: 'var(--muted)' }}>
                      {b.cancellationReason || '---'}
                    </td>
                    <td style={{ whiteSpace: 'nowrap' }}>
                      {b.status === 'PENDING' && (
                        <>
                          <button
                            className="btn btn-success btn-sm"
                            onClick={() => setApproveModal(b._id)}
                          >
                            Approve
                          </button>{' '}
                          <button
                            className="btn btn-danger btn-sm"
                            onClick={() => {
                              setCancelModal(b._id);
                              setCancelReason('');
                            }}
                          >
                            Cancel
                          </button>
                        </>
                      )}
                      {b.status === 'CONFIRMED' && (
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => {
                            setCancelModal(b._id);
                            setCancelReason('');
                          }}
                        >
                          Cancel
                        </button>
                      )}
                      {b.status === 'CANCELLED' && (
                        <span style={{ color: 'var(--muted)', fontSize: 12 }}>
                          ---
                        </span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Approve Modal */}
      {approveModal && (
        <div
          className="modal-overlay open"
          onClick={(e) =>
            e.target === e.currentTarget && setApproveModal(null)
          }
        >
          <div className="modal">
            <h4>Approve Booking</h4>
            <p>
              Are you sure you want to approve this booking? The slot will be
              marked as <strong>Confirmed</strong>.
            </p>
            <div className="modal-actions">
              <button
                className="btn btn-ghost"
                onClick={() => setApproveModal(null)}
              >
                Cancel
              </button>
              <button className="btn btn-success" onClick={handleApprove}>
                Approve
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Cancel Modal */}
      {cancelModal && (
        <div
          className="modal-overlay open"
          onClick={(e) =>
            e.target === e.currentTarget && setCancelModal(null)
          }
        >
          <div className="modal">
            <h4>Cancel Booking</h4>
            <p>
              Please provide a reason for cancelling this booking. This action
              cannot be undone.
            </p>
            <div className="form-group">
              <label>Cancellation Reason</label>
              <textarea
                value={cancelReason}
                onChange={(e) => setCancelReason(e.target.value)}
                placeholder="Enter reason..."
                style={{ minHeight: 80 }}
              />
            </div>
            <div className="modal-actions">
              <button
                className="btn btn-ghost"
                onClick={() => setCancelModal(null)}
              >
                Close
              </button>
              <button className="btn btn-danger" onClick={handleCancel}>
                Confirm Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Toast */}
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
