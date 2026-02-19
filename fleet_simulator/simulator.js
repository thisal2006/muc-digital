const admin = require("firebase-admin");
const truckRoutes = require("./routes/truck_routes");
const serviceAccount = require("./serviceAccountKey.json");

//--------------------------------------
// FIREBASE INIT
//--------------------------------------

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://muc-digital-4390a-default-rtdb.firebaseio.com/"
});

const db = admin.database();

// Seed dump points once
seedDumpPoints();

//--------------------------------------
// TRACK ROUTE INDEX
//--------------------------------------

const routeIndexes = {};

Object.keys(truckRoutes).forEach(truckId => {
  routeIndexes[truckId] = 0;
});

//--------------------------------------
// SIMULATE CONTINUOUS MOVEMENT
//--------------------------------------

async function moveTrucks() {

  try {

    for (const truckId of Object.keys(truckRoutes)) {

      const route = truckRoutes[truckId];

      let index = routeIndexes[truckId];

      const position = route[index];

      await db.ref(`trucks/${truckId}`).update({

        lat: position.lat,
        lng: position.lng,

        speed: Math.floor(Math.random() * 20) + 25, // 25–45 realistic

        status: "on_route",
        lastUpdate: Date.now(),

        type: Math.random() > 0.5
          ? "degradable"
          : "non_degradable",
      });

      // Move to next coordinate
      routeIndexes[truckId] =
        (index + 1) % route.length;
    }

    console.log("🚛 Trucks moved");

  } catch (err) {
    console.error("Simulator Error:", err);
  }
}

//--------------------------------------
// RUN EVERY 3 SECONDS (SMOOTH)
//--------------------------------------

setInterval(moveTrucks, 3000);


//--------------------------------------
// SEED DUMP POINTS
//--------------------------------------

async function seedDumpPoints() {

  const dumpRef = db.ref("dump_points");

  const snapshot = await dumpRef.get();

  if (snapshot.exists()) {
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

