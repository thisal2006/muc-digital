import { db } from '../config/firebase.js';
import { randomUUID } from 'crypto';
import { parseISO, format } from 'date-fns';

const populateVehicle = async (bookingData) => {
  if (!bookingData.vehicle) return bookingData;
  const vehicleDoc = await db.collection('vehicles').doc(bookingData.vehicle).get();
  return {
    ...bookingData,
    vehicle: vehicleDoc.exists ? { id: vehicleDoc.id, ...vehicleDoc.data() } : bookingData.vehicle
  };
};

export const createBooking = async (req, res, next) => {
  try {
    const {
      vehicle: vehicleId,
      bookingType,
      startDate,
      endDate,
      userName,
      userPhone,
    } = req.body;

    if (!vehicleId) {
      return res.status(400).json({ success: false, message: "Vehicle ID is required" });
    }

    const vehicleDoc = await db.collection('vehicles').doc(vehicleId).get();
    if (!vehicleDoc.exists) {
      return res.status(404).json({ success: false, message: "Vehicle not found" });
    }
    const vehicle = vehicleDoc.data();

    const start = parseISO(startDate);
    const end = endDate ? parseISO(endDate) : new Date(start);

    if (bookingType === 'FULL_DAY' || bookingType === 'MULTIPLE_DAYS') {
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
    } else if (bookingType === 'HALF_DAY_AM') {
      start.setHours(8, 0, 0, 0);
      end.setHours(12, 59, 59, 999);
    } else if (bookingType === 'HALF_DAY_PM') {
      start.setHours(13, 0, 0, 0);
      end.setHours(17, 59, 59, 999);
    }

    // Check availability (In-memory overlap check due to Firestore inequality limitations)
    const bookingsSnapshot = await db.collection('bookings')
      .where('vehicle', '==', vehicleId)
      .where('status', 'in', ["CONFIRMED", "PENDING"])
      .get();

    const existingBookings = bookingsSnapshot.docs
      .map(doc => ({ id: doc.id, ...doc.data() }))
      .filter(b => {
        const bStart = b.startDate.toDate();
        const bEnd = b.endDate.toDate();
        return bStart <= end && bEnd >= start;
      });

    let canBook = true;
    let conflictMessage = "";

    if (bookingType === "MULTIPLE_DAYS" || bookingType === "FULL_DAY") {
      if (existingBookings.length > 0) {
        canBook = false;
        conflictMessage = "One or more selected days are already booked.";
      }
    } else if (bookingType === "HALF_DAY_AM") {
      const hasAMConflict = existingBookings.some(
        (b) =>
          b.bookingType === "FULL_DAY" ||
          b.bookingType === "HALF_DAY_AM" ||
          b.bookingType === "MULTIPLE_DAYS",
      );
      if (hasAMConflict) {
        canBook = false;
        conflictMessage = "Morning slot is already booked.";
      }
    } else if (bookingType === "HALF_DAY_PM") {
      const hasPMConflict = existingBookings.some(
        (b) =>
          b.bookingType === "FULL_DAY" ||
          b.bookingType === "HALF_DAY_PM" ||
          b.bookingType === "MULTIPLE_DAYS",
      );
      if (hasPMConflict) {
        canBook = false;
        conflictMessage = "Afternoon slot is already booked.";
      }
    }

    if (!canBook) {
      return res.status(400).json({ success: false, message: conflictMessage });
    }

    let totalAmount = 0;
    if (bookingType === "HALF_DAY_AM" || bookingType === "HALF_DAY_PM") {
      totalAmount = vehicle.halfDayPrice;
    } else if (bookingType === "FULL_DAY") {
      totalAmount = vehicle.pricePerDay;
    } else if (bookingType === "MULTIPLE_DAYS") {
      const diffTime = Math.abs(end - start);
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      totalAmount = diffDays * vehicle.pricePerDay;
    }

    const bookingData = {
      vehicle: vehicleId,
      bookingType,
      startDate: start,
      endDate: end,
      totalAmount,
      userName,
      userPhone,
      status: "PENDING",
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const id = randomUUID();
    const docRef = db.collection('bookings').doc(id);
    await docRef.set(bookingData);
    const savedDoc = await docRef.get();

    res.status(201).json({
      success: true,
      data: { id: savedDoc.id, ...savedDoc.data() },
    });
  } catch (error) {
    next(error);
  }
};

export const getVehicleAvailability = async (req, res, next) => {
  try {
    const { vehicleId, year, month } = req.query;
    if (!vehicleId || !year || !month) {
      return res.status(400).json({ success: false, message: "Missing required parameters" });
    }

    const startOfMonth = parseISO(`${year}-${String(month).padStart(2, '0')}-01`);
    const endOfMonth = new Date(startOfMonth.getFullYear(), startOfMonth.getMonth() + 1, 0, 23, 59, 59, 999);

    const snapshot = await db.collection('bookings')
      .where('vehicle', '==', vehicleId)
      .where('status', 'in', ["CONFIRMED", "PENDING"])
      .get();

    const allBookings = snapshot.docs
      .map(doc => ({ id: doc.id, ...doc.data() }))
      .filter(b => {
        const bStart = b.startDate.toDate();
        const bEnd = b.endDate.toDate();
        return bStart <= endOfMonth && bEnd >= startOfMonth;
      });

    const confirmedBookings = allBookings.filter(b => b.status === "CONFIRMED");
    const pendingBookings = allBookings.filter(b => b.status === "PENDING");

    const daysInMonth = endOfMonth.getDate();
    const availability = [];

    const isOnDay = (b, currentDay) => {
      const bStart = b.startDate.toDate();
      const bEnd = b.endDate.toDate();
      const dayStart = new Date(currentDay.getFullYear(), currentDay.getMonth(), currentDay.getDate());
      const dayEnd = new Date(currentDay.getFullYear(), currentDay.getMonth(), currentDay.getDate(), 23, 59, 59, 999);
      return bStart <= dayEnd && bEnd >= dayStart;
    };

    for (let i = 1; i <= daysInMonth; i++) {
      const currentDay = new Date(startOfMonth.getFullYear(), startOfMonth.getMonth(), i);

      const dayConfirmed = confirmedBookings.filter((b) => isOnDay(b, currentDay));
      const dayPending = pendingBookings.filter((b) => isOnDay(b, currentDay));

      let amBooked = false;
      let pmBooked = false;
      let pendingAmBooked = false;
      let pendingPmBooked = false;
      let specificTimeBookings = [];

      dayConfirmed.forEach((b) => {
        if (b.bookingType === "FULL_DAY" || b.bookingType === "MULTIPLE_DAYS") {
          amBooked = true;
          pmBooked = true;
        } else if (b.bookingType === "HALF_DAY_AM") {
          amBooked = true;
        } else if (b.bookingType === "HALF_DAY_PM") {
          pmBooked = true;
        }
        specificTimeBookings.push({
          startTime: b.startDate.toDate().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }),
          endTime: b.endDate.toDate().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }),
          type: b.bookingType,
          status: 'CONFIRMED',
        });
      });

      dayPending.forEach((b) => {
        if (b.bookingType === "FULL_DAY" || b.bookingType === "MULTIPLE_DAYS") {
          pendingAmBooked = true;
          pendingPmBooked = true;
        } else if (b.bookingType === "HALF_DAY_AM") {
          pendingAmBooked = true;
        } else if (b.bookingType === "HALF_DAY_PM") {
          pendingPmBooked = true;
        }
        specificTimeBookings.push({
          startTime: b.startDate.toDate().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }),
          endTime: b.endDate.toDate().toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }),
          type: b.bookingType,
          status: 'PENDING',
        });
      });

      let confirmedStatus = "AVAILABLE";
      if (amBooked && pmBooked) confirmedStatus = "FULLY_BOOKED";
      else if (amBooked) confirmedStatus = "PARTIALLY_BOOKED_AM";
      else if (pmBooked) confirmedStatus = "PARTIALLY_BOOKED_PM";

      let status = confirmedStatus;
      if (confirmedStatus === "AVAILABLE") {
        if (pendingAmBooked && pendingPmBooked) status = "PENDING_FULL";
        else if (pendingAmBooked) status = "PENDING_AM";
        else if (pendingPmBooked) status = "PENDING_PM";
      } else if (confirmedStatus === "PARTIALLY_BOOKED_AM" && pendingPmBooked) {
        status = "PARTIALLY_BOOKED_AM_PENDING_PM";
      } else if (confirmedStatus === "PARTIALLY_BOOKED_PM" && pendingAmBooked) {
        status = "PARTIALLY_BOOKED_PM_PENDING_AM";
      }

      availability.push({
        date: format(currentDay, 'yyyy-MM-dd'),
        status,
        details: {
          amBooked,
          pmBooked,
          pendingAmBooked,
          pendingPmBooked,
          specificTimeBookings,
        },
      });
    }

    res.status(200).json({ success: true, data: availability });
  } catch (error) {
    next(error);
  }
};

export const getAllBookings = async (req, res, next) => {
  try {
    const snapshot = await db.collection('bookings').orderBy('createdAt', 'desc').get();
    const bookings = await Promise.all(snapshot.docs.map(async (doc) => {
      return await populateVehicle({ id: doc.id, ...doc.data() });
    }));

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

export const cancelBooking = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const docRef = db.collection('bookings').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    const booking = doc.data();
    if (booking.status === "CANCELLED") {
      return res.status(400).json({ success: false, message: "Booking is already cancelled" });
    }

    const updateData = {
      status: "CANCELLED",
      updatedAt: new Date()
    };
    if (reason) {
      updateData.cancellationReason = reason;
    }

    await docRef.update(updateData);
    const updatedDoc = await docRef.get();

    res.status(200).json({
      success: true,
      message: "Booking cancelled successfully",
      data: { id: updatedDoc.id, ...updatedDoc.data() },
    });
  } catch (error) {
    next(error);
  }
};

export const approveBooking = async (req, res, next) => {
  try {
    const { id } = req.params;

    const docRef = db.collection('bookings').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    const booking = doc.data();
    if (booking.status !== "PENDING") {
      return res.status(400).json({
        success: false,
        message: `Booking cannot be approved because its status is '${booking.status}'.`,
      });
    }

    const snapshot = await db.collection('bookings')
      .where('vehicle', '==', booking.vehicle)
      .where('status', '==', "CONFIRMED")
      .get();

    const conflictingBookings = snapshot.docs
      .map(d => ({ id: d.id, ...d.data() }))
      .filter(b => {
        if (b.id === id) return false;
        const bStart = b.startDate.toDate();
        const bEnd = b.endDate.toDate();
        const currStart = booking.startDate.toDate();
        const currEnd = booking.endDate.toDate();
        return bStart <= currEnd && bEnd >= currStart;
      });

    let canApprove = true;
    let conflictMessage = "";

    if (booking.bookingType === "MULTIPLE_DAYS" || booking.bookingType === "FULL_DAY") {
      if (conflictingBookings.length > 0) {
        canApprove = false;
        conflictMessage = "Cannot approve: one or more selected days are already confirmed.";
      }
    } else if (booking.bookingType === "HALF_DAY_AM") {
      const hasConflict = conflictingBookings.some(
        (b) =>
          b.bookingType === "FULL_DAY" ||
          b.bookingType === "HALF_DAY_AM" ||
          b.bookingType === "MULTIPLE_DAYS"
      );
      if (hasConflict) {
        canApprove = false;
        conflictMessage = "Cannot approve: morning slot is already confirmed.";
      }
    } else if (booking.bookingType === "HALF_DAY_PM") {
      const hasConflict = conflictingBookings.some(
        (b) =>
          b.bookingType === "FULL_DAY" ||
          b.bookingType === "HALF_DAY_PM" ||
          b.bookingType === "MULTIPLE_DAYS"
      );
      if (hasConflict) {
        canApprove = false;
        conflictMessage = "Cannot approve: afternoon slot is already confirmed.";
      }
    }

    if (!canApprove) {
      return res.status(400).json({ success: false, message: conflictMessage });
    }

    await docRef.update({
      status: "CONFIRMED",
      updatedAt: new Date()
    });
    const updatedDoc = await docRef.get();

    res.status(200).json({
      success: true,
      message: "Booking approved successfully",
      data: { id: updatedDoc.id, ...updatedDoc.data() },
    });
  } catch (error) {
    next(error);
  }
};
