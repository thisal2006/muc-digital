import { useState, useEffect } from 'react';

const BASE_URL = 'http://localhost:3000/api';

function fmt(d) {
  if (!d) return '---';
  // Check if it's a Firestore timestamp object
  let dateObj;
  if (d && typeof d === 'object' && d._seconds) {
    dateObj = new Date(d._seconds * 1000);
  } else {
    dateObj = new Date(d);
  }

  if (isNaN(dateObj.getTime())) return 'Invalid Date';

  return dateObj.toLocaleDateString('en-US', {
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

export default function Dashboard() {
  const [stats, setStats] = useState({ total: 0, pending: 0, confirmed: 0, cancelled: 0 });
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);

  const loadDashboard = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${BASE_URL}/bookings`);
      const result = await res.json();
      const data = result.data || [];

      setStats({
        total: data.length,
        pending: data.filter((b) => b.status === 'PENDING').length,
        confirmed: data.filter((b) => b.status === 'CONFIRMED').length,
        cancelled: data.filter((b) => b.status === 'CANCELLED').length,
      });
      setBookings(data.slice(0, 10));
    } catch {
      setBookings([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboard();
  }, []);

  return (
    <>
      {/* Stats */}
      <div className="stats-row">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(59,130,246,0.12)' }}>
            <span>&#128197;</span>
          </div>
          <div className="stat-label">Total Bookings</div>
          <div className="stat-value">{loading ? '...' : stats.total}</div>
          <div className="stat-sub">All time</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(245,158,11,0.12)' }}>
            <span>&#9203;</span>
          </div>
          <div className="stat-label">Pending Approval</div>
          <div className="stat-value" style={{ color: 'var(--yellow)' }}>
            {loading ? '...' : stats.pending}
          </div>
          <div className="stat-sub">Awaiting admin action</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(34,197,94,0.12)' }}>
            <span>&#9989;</span>
          </div>
          <div className="stat-label">Confirmed</div>
          <div className="stat-value" style={{ color: 'var(--green)' }}>
            {loading ? '...' : stats.confirmed}
          </div>
          <div className="stat-sub">Active bookings</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: 'rgba(239,68,68,0.12)' }}>
            <span>&#10060;</span>
          </div>
          <div className="stat-label">Cancelled</div>
          <div className="stat-value" style={{ color: 'var(--red)' }}>
            {loading ? '...' : stats.cancelled}
          </div>
          <div className="stat-sub">All time</div>
        </div>
      </div>

      {/* Recent Bookings */}
      <div className="card">
        <div className="card-header">
          <h3>Recent Bookings</h3>
          <button className="btn btn-ghost btn-sm" onClick={loadDashboard}>
            Refresh
          </button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Vehicle</th>
                <th>Type</th>
                <th>User</th>
                <th>Phone</th>
                <th>Dates</th>
                <th>Amount</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state">
                      <div className="empty-icon">&#128203;</div>
                      Loading...
                    </div>
                  </td>
                </tr>
              ) : bookings.length === 0 ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state">
                      <div className="empty-icon">&#128203;</div>
                      No bookings yet.
                    </div>
                  </td>
                </tr>
              ) : (
                bookings.map((b) => (
                  <tr key={b.id}>
                    <td>{b.vehicle?.name || '---'}</td>
                    <td>{b.bookingType}</td>
                    <td>{b.userName || '---'}</td>
                    <td>{b.userPhone || '---'}</td>
                    <td>
                      {fmt(b.startDate)} &rarr; {fmt(b.endDate)}
                    </td>
                    <td>${b.totalAmount}</td>
                    <td>
                      <StatusBadge status={b.status} />
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
