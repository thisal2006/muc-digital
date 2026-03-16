import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import { auth } from '../../firebase';
import { signOut } from 'firebase/auth';

const mainNav = [
  {
    to: '/',
    name: 'Home',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
        <polyline points="9 22 9 12 15 12 15 22" />
      </svg>
    ),
  },
  {
    name: 'Vehicle',
    prefix: '/vehicle',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M8 17h.01M16 17h.01M4 11l1.34-4.02A2 2 0 017.24 5h9.52a2 2 0 011.9 1.38L20 11m-16 0h16m-16 0v6a1 1 0 001 1h1a1 1 0 001-1v-1h10v1a1 1 0 001 1h1a1 1 0 001-1v-6" />
      </svg>
    ),
    children: [
      {
        to: '/vehicle',
        name: 'Dashboard',
        icon: (
          <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
            <rect x="3" y="3" width="7" height="7" rx="1" />
            <rect x="14" y="3" width="7" height="7" rx="1" />
            <rect x="3" y="14" width="7" height="7" rx="1" />
            <rect x="14" y="14" width="7" height="7" rx="1" />
          </svg>
        ),
      },
      {
        to: '/vehicle/bookings',
        name: 'Bookings',
        icon: (
          <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
            <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        ),
      },
      {
        to: '/vehicle/list',
        name: 'Vehicles',
        icon: (
          <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
            <path d="M8 17h.01M16 17h.01M4 11l1.34-4.02A2 2 0 017.24 5h9.52a2 2 0 011.9 1.38L20 11m-16 0h16m-16 0v6a1 1 0 001 1h1a1 1 0 001-1v-1h10v1a1 1 0 001 1h1a1 1 0 001-1v-6" />
          </svg>
        ),
      },
      {
        to: '/vehicle/types',
        name: 'Vehicle Types',
        icon: (
          <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
            <path d="M4 6h16M4 10h16M4 14h16M4 18h16" />
          </svg>
        ),
      },
    ],
  },
  {
    to: '/cemetery',
    name: 'Cemetery',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h14a2 2 0 012 2v14a2 2 0 01-2 2z" />
        <path d="M12 7v6m-3-3h6" />
      </svg>
    ),
  },
  {
    to: '/property',
    name: 'Property',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <rect x="2" y="7" width="20" height="14" rx="2" />
        <path d="M16 7V5a4 4 0 00-8 0v2" />
      </svg>
    ),
  },
  {
    to: '/notifications',
    name: 'Notifications',
    icon: (
      <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
        <path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
      </svg>
    ),
  },
];

const pageTitles = {
  '/': 'Home',
  '/vehicle': 'Vehicle Dashboard',
  '/vehicle/bookings': 'Vehicle Bookings',
  '/vehicle/list': 'Vehicles',
  '/vehicle/types': 'Vehicle Types',
  '/cemetery': 'Cemetery',
  '/property': 'Property',
  '/notifications': 'Notifications',
};

export default function DashboardLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const currentTitle = pageTitles[location.pathname] || 'Dashboard';

  const handleLogout = async () => {
    try {
      await signOut(auth);
      navigate('/login');
    } catch (error) {
      console.error('Failed to log out', error);
    }
  };

  // Track which expandable sections are open
  const [expanded, setExpanded] = useState(() => {
    // Auto-expand Vehicle section if we're on a vehicle route
    if (location.pathname.startsWith('/vehicle')) return { Vehicle: true };
    return {};
  });

  const toggleExpand = (name) => {
    setExpanded((prev) => ({ ...prev, [name]: !prev[name] }));
  };

  const isChildActive = (item) => {
    if (!item.children) return false;
    return item.children.some((c) => location.pathname === c.to);
  };

  return (
    <div className="layout">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="logo">
            <span className="logo-icon">MUC</span>
            <span>MUC Digital</span>
          </div>
        </div>
        <nav className="sidebar-nav">
          <div className="nav-label">Management</div>
          {mainNav.map((item) => {
            // Simple link (no children)
            if (!item.children) {
              return (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.to === '/'}
                  className={({ isActive }) =>
                    `nav-item${isActive ? ' active' : ''}`
                  }
                >
                  {item.icon}
                  {item.name}
                </NavLink>
              );
            }

            // Expandable section
            const isOpen = expanded[item.name] || isChildActive(item);
            return (
              <div key={item.name} className="nav-group">
                <button
                  className={`nav-item nav-parent${isChildActive(item) ? ' active' : ''}`}
                  onClick={() => toggleExpand(item.name)}
                >
                  {item.icon}
                  <span style={{ flex: 1 }}>{item.name}</span>
                  <svg
                    className={`nav-chevron${isOpen ? ' open' : ''}`}
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    viewBox="0 0 24 24"
                  >
                    <polyline points="9 18 15 12 9 6" />
                  </svg>
                </button>
                <div className={`nav-children${isOpen ? ' expanded' : ''}`}>
                  {item.children.map((child) => (
                    <NavLink
                      key={child.to}
                      to={child.to}
                      end
                      className={({ isActive }) =>
                        `nav-item nav-child${isActive ? ' active' : ''}`
                      }
                    >
                      {child.icon}
                      {child.name}
                    </NavLink>
                  ))}
                </div>
              </div>
            );
          })}
        </nav>
        <div className="sidebar-footer">
          MUC Digital Admin v1.0
        </div>
      </aside>

      {/* Main Area */}
      <div className="main">
        {/* Top Header Bar */}
        <header className="topbar">
          <div className="topbar-left">
            <span className="topbar-title">{currentTitle}</span>
            <span className="topbar-breadcrumb">
              {location.pathname !== '/' && (
                <>
                  <span style={{ color: 'var(--muted)' }}>Home</span>
                  {location.pathname.split('/').filter(Boolean).map((seg, i, arr) => (
                    <span key={i}>
                      <span style={{ color: 'var(--muted)', margin: '0 6px' }}>/</span>
                      <span style={{ color: i === arr.length - 1 ? 'var(--accent-light)' : 'var(--muted)' }}>
                        {seg.charAt(0).toUpperCase() + seg.slice(1)}
                      </span>
                    </span>
                  ))}
                </>
              )}
            </span>
          </div>
          <div className="topbar-right">
            <input
              type="text"
              className="topbar-search"
              placeholder="Search..."
            />
            <div className="topbar-status">
              <span className="badge-dot"></span>
              <span style={{ fontSize: 13, color: 'var(--muted)' }}>
                Online
              </span>
            </div>
            <div className="admin-pill" onClick={handleLogout} style={{ cursor: 'pointer' }} title="Logout">
              <span className="admin-avatar">A</span>
              <span>Logout</span>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <div className="content">
          <Outlet />
        </div>

        {/* Footer */}
        <footer className="footer">
          <span>MUC Digital Dashboard &copy; 2026. All rights reserved.</span>
          <div className="footer-links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms of Service</a>
            <a href="#">Support</a>
          </div>
        </footer>
      </div>
    </div>
  );
}
