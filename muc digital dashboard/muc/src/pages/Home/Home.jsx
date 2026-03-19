import { useNavigate } from 'react-router-dom';
import vehicleModuleImage from '../../assets/vehicle-module.svg';
import cemeteryModuleImage from '../../assets/cemetery-module.svg';
import propertyModuleImage from '../../assets/property-module.svg';
import notificationModuleImage from '../../assets/notification-module.svg';
import complaintModuleImage from '../../assets/complaint-module.svg';

const sections = [
  {
    name: 'Vehicle Management',
    description: 'Manage vehicle bookings, fleet, and vehicle types. View booking stats, approve or cancel reservations.',
    to: '/vehicle',
    status: 'Active',
    statusColor: 'badge-active',
    image: vehicleModuleImage,
  },
  {
    name: 'Cemetery Management',
    description: 'Manage cemetery plots, crematorium bookings, and maintenance schedules.',
    to: '/cemetery',
    status: 'Active',
    statusColor: 'badge-active',
    image: cemeteryModuleImage,
  },
  {
    name: 'Property Management',
    description: 'Manage property bookings, tenant records, and lease agreements.',
    to: '/property',
    status: 'Active',
    statusColor: 'badge-active',
    image: propertyModuleImage,
  },
  {
    name: 'Complaints',
    description: 'Manage and resolve resident complaints.',
    to: '/complaints',
    status: 'Active',
    statusColor: 'badge-active',
    image: complaintModuleImage,
  },
  {
    name: 'Notifications',
    description: 'Add or remove global announcements and push notifications for users.',
    to: '/notifications',
    status: 'Active',
    statusColor: 'badge-active',
    image: notificationModuleImage,
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
            <img className="home-card-image" src={section.image} alt={section.name} />
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
