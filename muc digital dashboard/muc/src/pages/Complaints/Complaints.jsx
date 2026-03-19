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

export default function Complaints() {
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);

  const normalizeStatus = (value) => {
    const status = (value || 'Pending').toString().trim().toLowerCase();
    if (status === 'resolved') return 'Resolved';
    if (status === 'in progress') return 'In Progress';
    return 'Pending';
  };

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
  };

  const loadComplaints = async () => {
    setLoading(true);
    try {
      const q = query(collection(db, 'complaints'), orderBy('createdAt', 'desc'));
      const querySnapshot = await getDocs(q);
      const data = querySnapshot.docs.map(docSnap => ({
        id: docSnap.id,
        ...docSnap.data()
      }));
      setComplaints(data);
    } catch (error) {
      console.error('Error fetching complaints:', error);
      showToast('Failed to load complaints', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadComplaints();
  }, []);

  const updateStatus = async (id, newStatus) => {
    try {
      const complaintRef = doc(db, 'complaints', id);
      await updateDoc(complaintRef, {
        status: newStatus
      });
      showToast(`Complaint status updated to ${newStatus}`);
      loadComplaints();
    } catch (error) {
      console.error('Error updating complaint status:', error);
      showToast('Error updating status', 'error');
    }
  };

  return (
    <>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginBottom: '20px' }}>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#f8fafc' }}>
          <h4 style={{ margin: 0, color: '#64748b', fontSize: '14px', textTransform: 'uppercase' }}>Total Complaints</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#0f172a' }}>{complaints.length}</div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#f0fdf4' }}>
          <h4 style={{ margin: 0, color: '#166534', fontSize: '14px', textTransform: 'uppercase' }}>Resolved</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#22c55e' }}>
            {complaints.filter(c => normalizeStatus(c.status) === 'Resolved').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#fefce8' }}>
          <h4 style={{ margin: 0, color: '#854d0e', fontSize: '14px', textTransform: 'uppercase' }}>Pending</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#eab308' }}>
            {complaints.filter(c => normalizeStatus(c.status) === 'Pending').length}
          </div>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', backgroundColor: '#eff6ff' }}>
          <h4 style={{ margin: 0, color: '#1d4ed8', fontSize: '14px', textTransform: 'uppercase' }}>In Progress</h4>
          <div style={{ fontSize: '32px', fontWeight: 'bold', marginTop: '10px', color: '#3b82f6' }}>
             {complaints.filter(c => normalizeStatus(c.status) === 'In Progress').length}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h3>Complaints</h3>
          <button className="btn btn-ghost btn-sm" onClick={loadComplaints}>
            Refresh
          </button>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Image</th>
                <th>Category & Description</th>
                <th>User Details</th>
                <th>Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state">
                      <div className="empty-icon">&#9888;</div>
                      Loading...
                    </div>
                  </td>
                </tr>
              ) : complaints.length === 0 ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state">
                      <div className="empty-icon">&#9888;</div>
                      No complaints found.
                    </div>
                  </td>
                </tr>
              ) : (
                complaints.map((c) => {
                  let badgeClass = '';
                  let badgeStyle = {};
                  const status = normalizeStatus(c.status);
                  
                  if (status === 'Resolved') {
                    badgeClass = 'badge-available';
                  } else if (status === 'Pending') {
                    badgeStyle = { backgroundColor: '#fef08a', color: '#854d0e' };
                  } else if (status === 'In Progress') {
                     badgeStyle = { backgroundColor: '#bfdbfe', color: '#1e3a8a' };
                  } else {
                    badgeClass = 'badge-unavailable';
                  }

                  // Handle different date formats (timestamp vs string vs Date)
                  let displayDate = '---';
                  if (c.createdAt) {
                    if (c.createdAt.toDate) {
                      displayDate = c.createdAt.toDate().toLocaleString();
                    } else if (typeof c.createdAt === 'string') {
                      displayDate = new Date(c.createdAt).toLocaleString();
                    }
                  }

                  return (
                    <tr key={c.id}>
                      <td>
                         {c.imageUrl ? (
                           <a href={c.imageUrl} target="_blank" rel="noopener noreferrer">
                             <img
                               src={c.imageUrl}
                               alt="Complaint"
                               style={{
                                 width: '60px',
                                 height: '60px',
                                 objectFit: 'cover',
                                 borderRadius: '4px',
                               }}
                             />
                           </a>
                         ) : (
                           <div
                             style={{
                               width: '60px',
                               height: '60px',
                               backgroundColor: '#f5f5f5',
                               borderRadius: '4px',
                               display: 'flex',
                               alignItems: 'center',
                               justifyContent: 'center',
                               fontSize: '12px',
                               color: '#888',
                             }}
                           >
                             No Image
                           </div>
                         )}
                      </td>
                      <td>
                        <div style={{ fontWeight: '500' }}>{c.category || 'N/A'}</div>
                        <div style={{ color: 'var(--muted)', fontSize: 13, maxWidth: '300px', whiteSpace: 'normal' }}>
                          {c.description || '---'}
                        </div>
                      </td>
                      <td>
                        <div>{c.userEmail || '---'}</div>
                      </td>
                      <td>
                         <div style={{ fontSize: 13 }}>{displayDate}</div>
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
                            onClick={() => updateStatus(c.id, 'Resolved')}
                            disabled={status === 'Resolved'}
                            style={{
                              opacity: status === 'Resolved' ? 0.5 : 1,
                              cursor: status === 'Resolved' ? 'not-allowed' : 'pointer',
                            }}
                          >
                            Resolve
                          </button>
                          <button
                            className="btn btn-sm"
                            onClick={() => updateStatus(c.id, 'In Progress')}
                            disabled={status === 'In Progress'}
                            style={{
                              backgroundColor: '#3b82f6',
                              color: 'white',
                              border: 'none',
                              borderRadius: '4px',
                              padding: '4px 8px',
                              opacity: status === 'In Progress' ? 0.5 : 1,
                              cursor: status === 'In Progress' ? 'not-allowed' : 'pointer',
                            }}
                          >
                            In Progress
                          </button>
                          <button
                            className="btn btn-sm"
                            onClick={() => updateStatus(c.id, 'Pending')}
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
