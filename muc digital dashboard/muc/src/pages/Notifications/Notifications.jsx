import { useState, useEffect } from 'react';
import { collection, addDoc, deleteDoc, getDocs, doc } from 'firebase/firestore';
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

export default function Notifications() {
    const [announcements, setAnnouncements] = useState([]);
    const [loading, setLoading] = useState(true);
    const [toast, setToast] = useState(null);
    const [form, setForm] = useState({ title: '', description: '' });

    const showToast = (message, type = 'success') => setToast({ message, type });

    const loadAnnouncements = async () => {
        setLoading(true);
        try {
            const querySnapshot = await getDocs(collection(db, 'announcements'));
            const data = querySnapshot.docs.map(docSnap => {
                const d = docSnap.data();
                let displayTime = d.timestamp;
                let sortTime = 0;

                if (d.timestamp) {
                    if (typeof d.timestamp.toDate === 'function') {
                        const dateObj = d.timestamp.toDate();
                        displayTime = dateObj.toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric' });
                        sortTime = dateObj.getTime();
                    } else if (d.timestamp.seconds !== undefined) {
                        const dateObj = new Date(d.timestamp.seconds * 1000);
                        displayTime = dateObj.toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric' });
                        sortTime = dateObj.getTime();
                    } else if (typeof d.timestamp === 'string') {
                        sortTime = new Date(d.timestamp).getTime();
                    }
                }
                return {
                    id: docSnap.id,
                    ...d,
                    displayTime,
                    sortTime
                };
            }).sort((a, b) => b.sortTime - a.sortTime);
            setAnnouncements(data);
        } catch (error) {
            console.error(error);
            showToast('Error loading notifications', 'error');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { loadAnnouncements(); }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!form.title || !form.description) return;
        try {
            const now = new Date();
            const timestampString = now.toLocaleString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) + ' at ' + now.toLocaleTimeString('en-US') + ' UTC+5:30';
            await addDoc(collection(db, 'announcements'), {
                title: form.title,
                description: form.description,
                timestamp: timestampString
            });
            showToast('Notification added successfully');
            setForm({ title: '', description: '' });
            loadAnnouncements();
        } catch (e) {
            console.error(e);
            showToast('Failed to add notification', 'error');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this notification?')) return;
        try {
            await deleteDoc(doc(db, 'announcements', id));
            showToast('Notification removed');
            loadAnnouncements();
        } catch (e) {
            showToast('Failed to remove', 'error');
        }
    };

    return (
        <>
            <div className="split">
                {/* Add Form */}
                <div className="card">
                    <div className="card-header">
                        <h3>Add Notification</h3>
                    </div>
                    <div className="card-body">
                        <form onSubmit={handleSubmit}>
                            <div className="form-grid">
                                <div className="form-group full">
                                    <label>Title</label>
                                    <input
                                        type="text"
                                        placeholder="Enter notification title"
                                        value={form.title}
                                        onChange={(e) => setForm({ ...form, title: e.target.value })}
                                        required
                                    />
                                </div>
                                <div className="form-group full">
                                    <label>Description</label>
                                    <textarea
                                        placeholder="Enter notification description"
                                        value={form.description}
                                        onChange={(e) => setForm({ ...form, description: e.target.value })}
                                        required
                                    />
                                </div>
                                <div className="form-group full">
                                    <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
                                        + Publish Notification
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                {/* List */}
                <div className="card">
                    <div className="card-header">
                        <h3>Active Notifications</h3>
                        <button className="btn btn-ghost btn-sm" onClick={loadAnnouncements}>
                            Refresh
                        </button>
                    </div>
                    <div className="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Description</th>
                                    <th>Timestamp</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {loading ? (
                                    <tr>
                                        <td colSpan="4">
                                            <div className="empty-state">Loading...</div>
                                        </td>
                                    </tr>
                                ) : announcements.length === 0 ? (
                                    <tr>
                                        <td colSpan="4">
                                            <div className="empty-state">No notifications.</div>
                                        </td>
                                    </tr>
                                ) : (
                                    announcements.map((a) => (
                                        <tr key={a.id}>
                                            <td style={{ fontWeight: '500' }}>{a.title}</td>
                                            <td>{a.description}</td>
                                            <td style={{ color: 'var(--muted)', fontSize: 12 }}>{a.displayTime}</td>
                                            <td>
                                                <button
                                                    className="btn btn-danger btn-sm"
                                                    onClick={() => handleDelete(a.id)}
                                                >
                                                    Delete
                                                </button>
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
