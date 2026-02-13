const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://muc-digital-4390a-default-rtdb.firebaseio.com/"
});

const db = admin.database();
seedDumpPoints();


//--------------------------------------
// ROUTES (REAL ROADS)
//--------------------------------------

const routes = {

  truck1: [
    { lat: 6.8480, lng: 79.9260 },
    { lat: 6.8495, lng: 79.9285 },
    { lat: 6.8520, lng: 79.9302 },
    { lat: 6.8550, lng: 79.9325 },
  ],

  truck2: [
    { lat: 6.8600, lng: 79.9200 },
    { lat: 6.8620, lng: 79.9225 },
    { lat: 6.8650, lng: 79.9250 },
    { lat: 6.8680, lng: 79.9270 },
  ],

  truck3: [
    { lat: 6.8400, lng: 79.9300 },
    { lat: 6.8420, lng: 79.9330 },
    { lat: 6.8450, lng: 79.9360 },
    { lat: 6.8480, lng: 79.9390 },
  ]
};


// Track positions
let index = {
  truck1: 0,
  truck2: 0,
  truck3: 0,
};


//--------------------------------------
// SIMULATE MOVEMENT
//--------------------------------------

setInterval(() => {

  Object.keys(routes).forEach(truck => {

    const route = routes[truck];

    index[truck] =
        (index[truck] + 1) % route.length;

    const position = route[index[truck]];

    db.ref(`trucks/${truck}`).set({

      lat: position.lat,
      lng: position.lng,
      speed: Math.floor(Math.random() * 40) + 10,
      status: "on_route",
      lastUpdate: Date.now(),
      type: "degradable",

    });

  });

  console.log("🚛 Trucks moved");

}, 5000);
//--------------------------------------
// SEED DUMP POINTS (RUNS ONCE)
//--------------------------------------

async function seedDumpPoints() {

  const dumpRef = db.ref("dump_points");

  const snapshot = await dumpRef.get();

  // Prevent reseeding every run
  if(snapshot.exists()){
    console.log("Dump points already exist ✅");
    return;
  }

  console.log("Seeding dump points...");

  await dumpRef.set({

    dp_karadiyana: {
      name: "Karadiyana Waste Management Facility",
      lat: 6.8236,
      lng: 79.9021,
      address: "Borupana Road, Karadiyana",
      status: "active",
      capacity_tons: 120,
      current_load: 45,
      open_time: "06:00",
      close_time: "18:00",
      supports_recycling: true,
      last_updated: Date.now()
    },

    dp_nawinna: {
      name: "Nawinna Solid Waste Dump Site",
      lat: 6.8580,
      lng: 79.9180,
      address: "Nawinna, Maharagama",
      status: "active",
      capacity_tons: 80,
      current_load: 20,
      open_time: "07:00",
      close_time: "17:00",
      supports_recycling: false,
      last_updated: Date.now()
    },

    dp_keells_maharagama: {
      name: "Keells Plasticcycle Bin",
      lat: 6.8489,
      lng: 79.9265,
      address: "Piliyandala Road, Maharagama",
      status: "active",
      capacity_tons: 5,
      current_load: 1,
      open_time: "08:00",
      close_time: "22:00",
      supports_recycling: true,
      last_updated: Date.now()
    }

  });

  console.log("Dump points seeded ✅");
}
