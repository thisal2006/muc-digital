import { useNavigate } from 'react-router-dom';

const sections = [
  {
    name: 'Vehicle Management',
    description: 'Manage vehicle bookings, fleet, and vehicle types. View booking stats, approve or cancel reservations.',
    to: '/vehicle',
    color: '#3b82f6',
    bg: 'rgba(59, 130, 246, 0.12)',
    status: 'Active',
    statusColor: 'badge-active',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M8 17h.01M16 17h.01M4 11l1.34-4.02A2 2 0 017.24 5h9.52a2 2 0 011.9 1.38L20 11m-16 0h16m-16 0v6a1 1 0 001 1h1a1 1 0 001-1v-1h10v1a1 1 0 001 1h1a1 1 0 001-1v-6" />
      </svg>
    ),
  },
  {
    name: 'Cemetery Management',
    description: 'Manage cemetery plots, reservations, and maintenance schedules.',
    to: '/cemetery',
    color: '#8b5cf6',
    bg: 'rgba(139, 92, 246, 0.12)',
    status: 'Coming Soon',
    statusColor: 'badge-pending',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h14a2 2 0 012 2v14a2 2 0 01-2 2z" />
        <path d="M12 7v6m-3-3h6" />
      </svg>
    ),
  },
  {
    name: 'Property Management',
    description: 'Manage property listings, tenant records, and lease agreements.',
    to: '/property',
    color: '#f59e0b',
    bg: 'rgba(245, 158, 11, 0.12)',
    status: 'Coming Soon',
    statusColor: 'badge-pending',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <rect x="2" y="7" width="20" height="14" rx="2" />
        <path d="M16 7V5a4 4 0 00-8 0v2" />
      </svg>
    ),
  },
];

export default function Home() {
  const navigate = useNavigate();

  return (
    <>
      <div style={{ marginBottom: 28 }}>
        <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 6 }}>
          Welcome to MUC Digital
        </h2>
        <p style={{ fontSize: 14, color: 'var(--muted)' }}>
          Select a management module to get started.
        </p>
      </div>

      <div className="home-grid">
        {sections.map((section) => (
          <div
            key={section.name}
            className="home-card"
            onClick={() => navigate(section.to)}
          >
            <div
              className="home-card-icon"
              style={{ background: section.bg, color: section.color }}
            >
              {section.icon}
            </div>
            <h3>{section.name}</h3>
            <p>{section.description}</p>
            <span className={`badge ${section.statusColor}`}>
              {section.status}
            </span>
          </div>
        ))}
      </div>
    </>
  );
}
