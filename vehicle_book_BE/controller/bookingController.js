import Vehicle from "../model/Vehicle.js";
import Booking from "../model/Booking.js";
import mongoose from "mongoose";
import { parseISO, format } from 'date-fns';  // For safe date parsing and formatting

// Helper to check if string is valid ObjectId
const isValidObjectId = (id) => mongoose.Types.ObjectId.isValid(id);

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
    
    console.log("Received booking request:", req.body);

    if (!isValidObjectId(vehicleId)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid vehicle ID format" });
    }

    const vehicle = await Vehicle.findById(vehicleId);
    if (!vehicle) {
      return res
        .status(404)
        .json({ success: false, message: "Vehicle not found" });
    }

    // Parse dates as local time using date-fns (handles '2026-05-30' as local midnight)
    const start = parseISO(startDate);
    const end = endDate ? parseISO(endDate) : new Date(start);

    // Set times based on booking type (always apply defaults for half-day if no time provided)
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
    // For other types or if times are provided, preserve as-is

    // Check availability
    const existingBookings = await Booking.find({
      vehicle: vehicleId,
      status: "CONFIRMED",
      $or: [{ startDate: { $lte: end }, endDate: { $gte: start } }],
    });

    // Check for conflicts
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

    const booking = await Booking.create({
      vehicle: vehicleId,
      bookingType,
      startDate: start,
      endDate: end,
      totalAmount,
      userName,
      userPhone,
      status: "CONFIRMED",
    });

    res.status(201).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

export const getVehicleAvailability = async (req, res, next) => {
  try {
    const { vehicleId, year, month } = req.query;
    if (!vehicleId || !year || !month) {
      return res
        .status(400)
        .json({ success: false, message: "Missing required parameters" });
    }

    if (!isValidObjectId(vehicleId)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid vehicle ID format" });
    }

    // Parse start/end of month as local dates
    const startOfMonth = parseISO(`${year}-${String(month).padStart(2, '0')}-01`);
    const endOfMonth = new Date(startOfMonth.getFullYear(), startOfMonth.getMonth() + 1, 0, 23, 59, 59, 999);

    const bookings = await Booking.find({
      vehicle: vehicleId,
      status: "CONFIRMED",
      $or: [
        { startDate: { $lte: endOfMonth }, endDate: { $gte: startOfMonth } },
      ],
    });

    const daysInMonth = endOfMonth.getDate();
    const availability = [];

    for (let i = 1; i <= daysInMonth; i++) {
      const currentDay = new Date(startOfMonth.getFullYear(), startOfMonth.getMonth(), i);
      const dayBookings = bookings.filter((b) => {
        const bStart = new Date(b.startDate);
        const bEnd = new Date(b.endDate);
        return (
          currentDay >= new Date(bStart.getFullYear(), bStart.getMonth(), bStart.getDate()) &&
          currentDay <= new Date(bEnd.getFullYear(), bEnd.getMonth(), bEnd.getDate(), 23, 59, 59, 999)
        );
      });

      let amBooked = false;
      let pmBooked = false;
      let specificTimeBookings = [];

      dayBookings.forEach((b) => {
        if (b.bookingType === "FULL_DAY" || b.bookingType === "MULTIPLE_DAYS") {
          amBooked = true;
          pmBooked = true;
        } else if (b.bookingType === "HALF_DAY_AM") {
          amBooked = true;
        } else if (b.bookingType === "HALF_DAY_PM") {
          pmBooked = true;
        }
        
        // Add specific time information
        specificTimeBookings.push({
          startTime: new Date(b.startDate).toLocaleTimeString('en-US', {
            hour12: false,
            hour: '2-digit', 
            minute: '2-digit'
          }),
          endTime: new Date(b.endDate).toLocaleTimeString('en-US', {
            hour12: false, 
            hour: '2-digit',
            minute: '2-digit'
          }),
          type: b.bookingType
        });
      });

      let status = "AVAILABLE";
      if (amBooked && pmBooked) status = "FULLY_BOOKED";
      else if (amBooked) status = "PARTIALLY_BOOKED_AM";
      else if (pmBooked) status = "PARTIALLY_BOOKED_PM";

      availability.push({
        date: format(currentDay, 'yyyy-MM-dd'),  // Local date, no UTC shift
        status,
        details: { 
          amBooked, 
          pmBooked,
          specificTimeBookings
        },
      });
    }
    console.log(
      "Availability for vehicle",
      vehicleId,
      "in",
      month,
      "/",
      year,
      ":",
      availability,
    );
    res.status(200).json({
      success: true,
      data: availability,
    });
    console.log("Sent availability response:", availability);
  } catch (error) {
    next(error);
  }
};

export const getAllBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find()
      .populate("vehicle")
      .sort({ createdAt: -1 });
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

    if (!isValidObjectId(id)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid booking ID format" });
    }

    const booking = await Booking.findById(id);
    if (!booking) {
      return res
        .status(404)
        .json({ success: false, message: "Booking not found" });
    }

    if (booking.status === "CANCELLED") {
      return res
        .status(400)
        .json({ success: false, message: "Booking is already cancelled" });
    }

    booking.status = "CANCELLED";
    if (reason) {
      booking.cancellationReason = reason;
    }
    await booking.save();

    res.status(200).json({
      success: true,
      message: "Booking cancelled successfully",
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};