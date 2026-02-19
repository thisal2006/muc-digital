// Realistic truck routes around Maharagama / Nawinna / Pannipitiya
// These follow actual road directions — not random jumping.

const truckRoutes = {

  //Truck 1 — High Level Road loop (VERY realistic)
  "GT-001": [
    { lat: 6.8480, lng: 79.9265 }, // Maharagama town
    { lat: 6.8505, lng: 79.9288 },
    { lat: 6.8532, lng: 79.9315 },
    { lat: 6.8556, lng: 79.9339 },
    { lat: 6.8525, lng: 79.9300 },
    { lat: 6.8495, lng: 79.9275 },
  ],

  // Truck 2 — Nawinna residential collection route
  "GT-002": [
    { lat: 6.8578, lng: 79.9183 },
    { lat: 6.8602, lng: 79.9205 },
    { lat: 6.8628, lng: 79.9232 },
    { lat: 6.8605, lng: 79.9210 },
    { lat: 6.8585, lng: 79.9195 },
  ],

  //Truck 3 — Pannipitiya side streets
  "GT-003": [
    { lat: 6.8408, lng: 79.9352 },
    { lat: 6.8435, lng: 79.9378 },
    { lat: 6.8462, lng: 79.9405 },
    { lat: 6.8485, lng: 79.9380 },
    { lat: 6.8450, lng: 79.9362 },
  ],
};

module.exports = truckRoutes;
