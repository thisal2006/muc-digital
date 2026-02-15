import express from "express";
import {
  createVehicleType,
  getVehicleTypes,
  getVehicleTypeById,
  getAllVehicleTypesAdmin,
  updateVehicleTypeStatus
} from "./controller/vehicleTypeController.js";
import {
  createVehicle,
  getVehicles,
  getVehicleById,
  getAllVehiclesAdmin,
  updateVehicleStatus
} from "./controller/vehicleController.js";
import {
  createBooking,
  getVehicleAvailability,
  getAllBookings,
  cancelBooking
} from "./controller/bookingController.js";

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     VehicleType:
 *       type: object
 *       required:
 *         - name
 *       properties:
 *         name:
 *           type: string
 *         description:
 *           type: string
 *         image:
 *           type: string
 *     Vehicle:
 *       type: object
 *       required:
 *         - name
 *         - type
 *         - pricePerDay
 *         - halfDayPrice
 *       properties:
 *         name:
 *           type: string
 *         type:
 *           type: string
 *           description: Vehicle Type ID
 *         description:
 *           type: string
 *         pricePerDay:
 *           type: number
 *         halfDayPrice:
 *           type: number
 *         images:
 *           type: array
 *           items:
 *             type: string
 *         includedServices:
 *           type: array
 *           items:
 *             type: string
 *     Booking:
 *       type: object
 *       required:
 *         - vehicle
 *         - bookingType
 *         - startDate
 *       properties:
 *         vehicle:
 *           type: string
 *           description: Vehicle ID
 *         bookingType:
 *           type: string
 *           enum: [HALF_DAY_AM, HALF_DAY_PM, FULL_DAY, MULTIPLE_DAYS]
 *         startDate:
 *           type: string
 *           format: date
 *         endDate:
 *           type: string
 *           format: date
 *         userName:
 *           type: string
 *         userPhone:
 *           type: string
 */

// Add middleware to log all requests
router.use((req, res, next) => {
  console.log(`${req.method} ${req.originalUrl}`);
  next();
});

/**
 * @swagger
 * /api/vehicle-types:
 *   post:
 *     summary: Create a new vehicle type
 *     tags: [Vehicle Types]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/VehicleType'
 *     responses:
 *       201:
 *         description: Created
 *   get:
 *     summary: Get all vehicle types
 *     tags: [Vehicle Types]
 *     responses:
 *       200:
 *         description: Success
 */
router.post("/vehicle-types", createVehicleType);
router.get("/vehicle-types", getVehicleTypes);
router.get("/vehicle-types/:id", getVehicleTypeById);

/**
 * @swagger
 * /api/admin/vehicle-types:
 *   get:
 *     summary: Get all vehicle types for admin (including inactive)
 *     tags: [Admin - Vehicle Types]
 *     responses:
 *       200:
 *         description: Success
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/VehicleType'
 */
router.get("/admin/vehicle-types", getAllVehicleTypesAdmin);

/**
 * @swagger
 * /api/vehicle-types/{id}/status:
 *   patch:
 *     summary: Enable or disable a vehicle type
 *     tags: [Vehicle Types]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Vehicle type ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - isActive
 *             properties:
 *               isActive:
 *                 type: boolean
 *                 description: Whether the vehicle type should be active
 *             example:
 *               isActive: false
 *     responses:
 *       200:
 *         description: Vehicle type status updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Vehicle type not found
 */
router.patch("/vehicle-types/:id/status", updateVehicleTypeStatus);

/**
 * @swagger
 * /api/vehicles:
 *   post:
 *     summary: Add a new vehicle
 *     tags: [Vehicles]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Vehicle'
 *     responses:
 *       201:
 *         description: Created
 *   get:
 *     summary: Get vehicles
 *     tags: [Vehicles]
 *     parameters:
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *         description: Vehicle type ID
 *     responses:
 *       200:
 *         description: Success
 */
router.post("/vehicles", createVehicle);
router.get("/vehicles", getVehicles);
router.get("/vehicles/:id", getVehicleById);

/**
 * @swagger
 * /api/admin/vehicles:
 *   get:
 *     summary: Get all vehicles for admin (including unavailable and inactive types)
 *     tags: [Admin - Vehicles]
 *     responses:
 *       200:
 *         description: Success
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Vehicle'
 */
router.get("/admin/vehicles", getAllVehiclesAdmin);

/**
 * @swagger
 * /api/vehicles/{id}/status:
 *   patch:
 *     summary: Enable or disable a vehicle
 *     tags: [Vehicles]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Vehicle ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - isAvailable
 *             properties:
 *               isAvailable:
 *                 type: boolean
 *                 description: Whether the vehicle should be available
 *             example:
 *               isAvailable: false
 *     responses:
 *       200:
 *         description: Vehicle status updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Vehicle not found
 */
router.patch("/vehicles/:id/status", updateVehicleStatus);

/**
 * @swagger
 * /api/bookings:
 *   post:
 *     summary: Create a booking
 *     tags: [Bookings]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Booking'
 *     responses:
 *       201:
 *         description: Created
 *   get:
 *     summary: Get all bookings (Admin)
 *     tags: [Bookings]
 *     responses:
 *       200:
 *         description: Success
 */
router.post("/bookings", createBooking);
router.get("/bookings", getAllBookings);

/**
 * @swagger
 * /api/bookings/availability:
 *   get:
 *     summary: Get vehicle availability for a month
 *     tags: [Bookings]
 *     parameters:
 *       - in: query
 *         name: vehicleId
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: year
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: month
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/bookings/availability", getVehicleAvailability);

/**
 * @swagger
 * /api/bookings/{id}/cancel:
 *   patch:
 *     summary: Cancel a booking (Admin)
 *     tags: [Bookings]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reason:
 *                 type: string
 *                 description: Reason for cancellation
 *             example:
 *               reason: "Customer requested cancellation"
 *     responses:
 *       200:
 *         description: Booking cancelled successfully
 */
router.patch("/bookings/:id/cancel", cancelBooking);

export default router;