import { useState, useEffect } from 'react';
import { collection, getDocs, doc, updateDoc, orderBy, query } from 'firebase/firestore';
import { db } from '../../firebase';

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

export default function Cemetery() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  const normalizeStatus = (value) => {
    const status = (value || 'pending').toString().trim().toLowerCase();
    if (status === 'approved') return 'Approved';
    if (status === 'rejected') return 'Rejected';
    return 'Pending';
  };

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadBookings = async () => {
    setLoading(true);
    try {
      const q = query(collection(db, 'crematorium_bookings'), orderBy('createdAt', 'desc'));
      const querySnapshot = await getDocs(q);
      const data = querySnapshot.docs.map(docSnap => ({
        id: docSnap.id,
        ...docSnap.data()
      }));
      setBookings(data);
    } catch (error) {
      console.error('Error fetching cemetery bookings:', error);
      showToast('Failed to load bookings', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadBookings();
  }, []);

  const updateStatus = async (id, newStatus) => {
    try {
      const bookingRef = doc(db, 'crematorium_bookings', id);
      await updateDoc(bookingRef, {
        status: newStatus.toLowerCase()
      });
      showToast(`Booking status updated to ${newStatus}`);
      loadBookings();
    } catch (error) {
      console.error('Error updating booking status:', error);
      showToast('Error updating status', 'error');
    }
  };

  return (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginBottom: '20px' }}>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#f8fafc' }}>
          <h4 style={{ margin: 0, color: '#64748b', fontSize: '14px', textTransform: 'uppercase' }}>Total Bookings</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#0f172a' }}>{bookings.length}</div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#f0fdf4' }}>
          <h4 style={{ margin: 0, color: '#166534', fontSize: '14px', textTransform: 'uppercase' }}>Approved</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#22c55e' }}>
            {bookings.filter(b => normalizeStatus(b.status) === 'Approved').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#fefce8' }}>
          <h4 style={{ margin: 0, color: '#854d0e', fontSize: '14px', textTransform: 'uppercase' }}>Pending</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#eab308' }}>
            {bookings.filter(b => normalizeStatus(b.status) === 'Pending').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#fef2f2' }}>
          <h4 style={{ margin: 0, color: '#991b1b', fontSize: '14px', textTransform: 'uppercase' }}>Rejected</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#ef4444' }}>
             {bookings.filter(b => normalizeStatus(b.status) === 'Rejected').length}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h3>Crematorium Bookings</h3>
          <button className="btn btn-ghost btn-sm" onClick={loadBookings}>
            Refresh
          </button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Date & Time</th>
                <th>Resident Details</th>
                <th>Relation</th>
                <th>Document</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state">
                      <div className="empty-icon">&#8987;</div>
                      Loading...
                    </div>
                  </td>
                </tr>
              ) : bookings.length === 0 ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state">
                      <div className="empty-icon">&#128193;</div>
                      No cemetery bookings found.
                    </div>
                  </td>
                </tr>
              ) : (
                bookings.map((b) => {
                  let badgeClass = '';
                  let badgeStyle = {};
                  const status = normalizeStatus(b.status);
                  
                  if (status === 'Approved') {
                    badgeClass = 'badge-available';
                  } else if (status === 'Pending') {
                    badgeStyle = { backgroundColor: '#fef08a', color: '#854d0e' };
                  } else {
                    badgeClass = 'badge-unavailable';
                  }

                  // Handle different date formats (timestamp vs string vs Date)
                  let displayDate = '---';
                  if (b.date) {
                    if (b.date.toDate) {
                      displayDate = b.date.toDate().toLocaleDateString();
                    } else if (typeof b.date === 'string') {
                      displayDate = new Date(b.date).toLocaleDateString();
                    } else if (b.date.seconds) { // Just in case toDate is missing
                      displayDate = new Date(b.date.seconds * 1000).toLocaleDateString();
                    }
                  }

                  return (
                    <tr key={b.id}>
                      <td>
                        <div style={{ fontWeight: '500' }}>{displayDate}</div>
                        <div style={{ color: 'var(--muted)', fontSize: 13 }}>
                          {b.timeSlot || '---'}
                        </div>
                      </td>
                      <td>
                        <div>
                           {b.isResident ? (
                             <span className="badge badge-available" style={{ padding: '2px 6px', fontSize: '11px' }}>Resident</span>
                           ) : (
                             <span className="badge badge-unavailable" style={{ padding: '2px 6px', fontSize: '11px', backgroundColor: '#e2e8f0', color: '#475569' }}>Non-Resident</span>
                           )}
                        </div>
                        <div style={{ fontSize: 12, marginTop: '4px', color: 'var(--muted)' }}>
                           User ID: <span title={b.userId || 'N/A'}>{b.userId ? b.userId.substring(0, 8) + '...' : '---'}</span>
                        </div>
                      </td>
                      <td>
                        <div>{b.relation || '---'}</div>
                      </td>
                      <td>
                         {b.documentUrl ? (
                           <a href={b.documentUrl} target="_blank" rel="noopener noreferrer" style={{ color: 'var(--accent-light)', textDecoration: 'none', fontWeight: '500' }}>
                             View File
                           </a>
                         ) : (
                           <span style={{ color: '#888' }}>No Document</span>
                         )}
                      </td>
                      <td>
                        <span className={`badge ${badgeClass}`} style={badgeStyle}>
                           {status}
                        </span>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                          <button
                            className="btn btn-primary btn-sm"
                            onClick={() => updateStatus(b.id, 'Approved')}
                            disabled={status === 'Approved'}
                            style={{
                              opacity: status === 'Approved' ? 0.5 : 1,
                              cursor: status === 'Approved' ? 'not-allowed' : 'pointer',
                            }}
                          >
                            Approve
                          </button>
                          <button
                            className="btn btn-danger btn-sm"
                            onClick={() => updateStatus(b.id, 'Rejected')}
                            disabled={status === 'Rejected'}
                            style={{
                              opacity: status === 'Rejected' ? 0.5 : 1,
                              cursor: status === 'Rejected' ? 'not-allowed' : 'pointer',
                            }}
                          >
                            Reject
                          </button>
                          <button
                            className="btn btn-sm"
                            onClick={() => updateStatus(b.id, 'Pending')}
                            disabled={status === 'Pending'}
                            style={{
                              backgroundColor: '#eab308',
                              color: 'white',
                              border: 'none',
                              borderRadius: '4px',
                              padding: '4px 8px',
                              opacity: status === 'Pending' ? 0.5 : 1,
                              cursor: status === 'Pending' ? 'not-allowed' : 'pointer',
                            }}
                          >
                            Mark Pending
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
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
