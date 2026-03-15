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

export default function Property() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadBookings = async () => {
    setLoading(true);
    try {
      const q = query(collection(db, 'property_bookings'), orderBy('timestamp', 'desc'));
      const querySnapshot = await getDocs(q);
      const data = querySnapshot.docs.map(docSnap => ({
        id: docSnap.id,
        ...docSnap.data()
      }));
      setBookings(data);
    } catch (error) {
      console.error('Error fetching property bookings:', error);
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
      const bookingRef = doc(db, 'property_bookings', id);
      await updateDoc(bookingRef, {
        status: newStatus
      });
      showToast(`Booking ${newStatus.toLowerCase()} successfully`);
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
            {bookings.filter(b => b.status === 'Approved').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#fefce8' }}>
          <h4 style={{ margin: 0, color: '#854d0e', fontSize: '14px', textTransform: 'uppercase' }}>Pending</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#eab308' }}>
            {bookings.filter(b => b.status !== 'Approved' && b.status !== 'Rejected').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#fef2f2' }}>
          <h4 style={{ margin: 0, color: '#991b1b', fontSize: '14px', textTransform: 'uppercase' }}>Rejected</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#ef4444' }}>
            {bookings.filter(b => b.status === 'Rejected').length}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h3>Property Bookings</h3>
          <button className="btn btn-ghost btn-sm" onClick={loadBookings}>
            Refresh
          </button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Property Name</th>
                <th>Contact Details</th>
                <th>Date & Slot</th>
                <th>Purpose & Crowd</th>
                <th>Price</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state">
                      <div className="empty-icon">&#127970;</div>
                      Loading...
                    </div>
                  </td>
                </tr>
              ) : bookings.length === 0 ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state">
                      <div className="empty-icon">&#127970;</div>
                      No property bookings found.
                    </div>
                  </td>
                </tr>
              ) : (
                bookings.map((b) => (
                  <tr key={b.id}>
                    <td style={{ fontWeight: '500' }}>{b.property_name || 'N/A'}</td>
                    <td>
                      <div>{b.contact_name || '---'}</div>
                      <div style={{ color: 'var(--muted)', fontSize: 12 }}>
                        {b.contact_number || '---'}
                      </div>
                    </td>
                    <td>
                      <div>{b.date || '---'}</div>
                      <div style={{ color: 'var(--muted)', fontSize: 12 }}>
                        {b.slot || '---'}
                      </div>
                    </td>
                    <td>
                      <div>{b.purpose || '---'}</div>
                      <div style={{ color: 'var(--muted)', fontSize: 12 }}>
                        Crowd: {b.crowd_size || 'N/A'}
                      </div>
                    </td>
                    <td style={{ fontWeight: '500' }}>{b.price || '---'}</td>
                    <td>
                      <span
                        className={`badge ${b.status === 'Approved'
                          ? 'badge-available'
                          : b.status === 'Rejected'
                            ? 'badge-unavailable'
                            : ''
                          }`}
                        style={{
                          backgroundColor:
                            b.status !== 'Approved' && b.status !== 'Rejected'
                              ? '#fef08a'
                              : undefined,
                          color:
                            b.status !== 'Approved' && b.status !== 'Rejected'
                              ? '#854d0e'
                              : undefined,
                        }}
                      >
                        {b.status || 'Pending'}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <button
                          className="btn btn-primary btn-sm"
                          onClick={() => updateStatus(b.id, 'Approved')}
                          disabled={b.status === 'Approved'}
                          style={{
                            opacity: b.status === 'Approved' ? 0.5 : 1,
                            cursor: b.status === 'Approved' ? 'not-allowed' : 'pointer',
                          }}
                        >
                          Approve
                        </button>
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => updateStatus(b.id, 'Rejected')}
                          disabled={b.status === 'Rejected'}
                          style={{
                            opacity: b.status === 'Rejected' ? 0.5 : 1,
                            cursor: b.status === 'Rejected' ? 'not-allowed' : 'pointer',
                          }}
                        >
                          Reject
                        </button>
                        <button
                          className="btn btn-sm"
                          onClick={() => updateStatus(b.id, 'Pending')}
                          disabled={b.status !== 'Approved' && b.status !== 'Rejected'}
                          style={{
                            backgroundColor: '#eab308',
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px',
                            padding: '4px 8px',
                            opacity: b.status !== 'Approved' && b.status !== 'Rejected' ? 0.5 : 1,
                            cursor: b.status !== 'Approved' && b.status !== 'Rejected' ? 'not-allowed' : 'pointer',
                          }}
                        >
                          Mark Pending
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
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
