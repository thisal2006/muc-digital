import { db } from '../config/firebase.js';
import { randomUUID } from 'crypto';

const populateVehicleType = async (vehicleData) => {
    if (!vehicleData.type) return vehicleData;
    const typeDoc = await db.collection('vehicleTypes').doc(vehicleData.type).get();
    return {
        ...vehicleData,
        type: typeDoc.exists ? { id: typeDoc.id, ...typeDoc.data() } : null
    };
};

export const createVehicle = async (req, res, next) => {
    try {
        const id = randomUUID();
        const vehicleData = {
            ...req.body,
            createdAt: new Date(),
            updatedAt: new Date(),
            isAvailable: req.body.isAvailable ?? true
        };
        const docRef = db.collection('vehicles').doc(id);
        await docRef.set(vehicleData);
        const savedDoc = await docRef.get();
        const vehicle = await populateVehicleType({ id: savedDoc.id, ...savedDoc.data() });

        res.status(201).json({
            success: true,
            data: vehicle
        });
    } catch (error) {
        next(error);
    }
};

export const getVehicles = async (req, res, next) => {
    try {
        const { type, includeUnavailable } = req.query;
        let query = db.collection('vehicles');

        if (type) {
            query = query.where('type', '==', type);
        }

        if (includeUnavailable !== 'true') {
            query = query.where('isAvailable', '==', true);
        }

        const snapshot = await query.get();
        const vehicles = await Promise.all(snapshot.docs.map(async (doc) => {
            const vehicle = { id: doc.id, ...doc.data() };
            return await populateVehicleType(vehicle);
        }));

        // Filter out vehicles with inactive types (simulating Mongoose populate match)
        const filteredVehicles = vehicles.filter(vehicle => vehicle.type && vehicle.type.isActive !== false);

        res.status(200).json({
            success: true,
            data: filteredVehicles
        });
    } catch (error) {
        next(error);
    }
};

export const getAllVehiclesAdmin = async (req, res, next) => {
    try {
        const snapshot = await db.collection('vehicles').orderBy('createdAt', 'desc').get();
        const vehicles = await Promise.all(snapshot.docs.map(async (doc) => {
            const vehicle = { id: doc.id, ...doc.data() };
            return await populateVehicleType(vehicle);
        }));

        res.status(200).json({
            success: true,
            data: vehicles
        });
    } catch (error) {
        next(error);
    }
};

export const getVehicleById = async (req, res, next) => {
    try {
        const doc = await db.collection('vehicles').doc(req.params.id).get();
        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const vehicle = await populateVehicleType({ id: doc.id, ...doc.data() });

        res.status(200).json({
            success: true,
            data: vehicle
        });
    } catch (error) {
        next(error);
    }
};

export const updateVehicleStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { isAvailable } = req.body;

        if (typeof isAvailable !== 'boolean') {
            return res.status(400).json({
                success: false,
                message: 'isAvailable must be a boolean value'
            });
        }

        const docRef = db.collection('vehicles').doc(id);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        await docRef.update({
            isAvailable,
            updatedAt: new Date()
        });

        const updatedDoc = await docRef.get();
        const vehicle = await populateVehicleType({ id: updatedDoc.id, ...updatedDoc.data() });

        res.status(200).json({
            success: true,
            message: `Vehicle ${isAvailable ? 'enabled' : 'disabled'} successfully`,
            data: vehicle
        });
    } catch (error) {
        next(error);
    }
};

