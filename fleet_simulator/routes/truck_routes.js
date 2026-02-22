// Smooth curved road-like routes around Maharagama

const truckRoutes = {

  "GT-001": generateRoute(6.8480, 79.9260, 0.010, 0.008),

  "GT-002": generateRoute(6.8580, 79.9180, 0.008, -0.010),

  "GT-003": generateRoute(6.8400, 79.9300, -0.009, 0.007),
};


//--------------------------------------
// FUNCTION TO GENERATE CURVED ROUTES
//--------------------------------------

function generateRoute(startLat, startLng, latAmplitude, lngAmplitude) {

  const points = [];
  const steps = 120; // More points = smoother road

  for (let i = 0; i < steps; i++) {

    const angle = (i / steps) * 2 * Math.PI;

    const lat = startLat + Math.sin(angle) * latAmplitude;
    const lng = startLng + Math.cos(angle) * lngAmplitude;

    points.push({ lat, lng });
  }

  return points;
}

module.exports = truckRoutes;