import { db } from '../config/firebase.js';
import { randomUUID } from 'crypto';

export const createVehicleType = async (req, res, next) => {
    try {
        const { name, description, image } = req.body;
        const id = randomUUID();
        const vehicleTypeData = {
            name,
            description,
            image,
            isActive: true,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        const docRef = db.collection('vehicleTypes').doc(id);
        await docRef.set(vehicleTypeData);
        const savedDoc = await docRef.get();

        res.status(201).json({
            success: true,
            data: { id: savedDoc.id, ...savedDoc.data() }
        });
    } catch (error) {
        next(error);
    }
};

export const getVehicleTypes = async (req, res, next) => {
    try {
        const { includeInactive } = req.query;
        let query = db.collection('vehicleTypes');

        if (includeInactive !== 'true') {
            query = query.where('isActive', '==', true);
        }

        const snapshot = await query.get();
        const vehicleTypes = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        res.status(200).json({
            success: true,
            data: vehicleTypes
        });
    } catch (error) {
        next(error);
    }
};

export const getAllVehicleTypesAdmin = async (req, res, next) => {
    try {
        const snapshot = await db.collection('vehicleTypes').orderBy('createdAt', 'desc').get();
        const vehicleTypes = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        res.status(200).json({
            success: true,
            data: vehicleTypes
        });
    } catch (error) {
        next(error);
    }
};

export const getVehicleTypeById = async (req, res, next) => {
    try {
        const doc = await db.collection('vehicleTypes').doc(req.params.id).get();

        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle type not found'
            });
        }

        res.status(200).json({
            success: true,
            data: { id: doc.id, ...doc.data() }
        });
    } catch (error) {
        next(error);
    }
};

export const updateVehicleTypeStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { isActive } = req.body;

        if (typeof isActive !== 'boolean') {
            return res.status(400).json({
                success: false,
                message: 'isActive must be a boolean value'
            });
        }

        const docRef = db.collection('vehicleTypes').doc(id);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle type not found'
            });
        }

        await docRef.update({
            isActive,
            updatedAt: new Date()
        });

        const updatedDoc = await docRef.get();

        res.status(200).json({
            success: true,
            message: `Vehicle type ${isActive ? 'enabled' : 'disabled'} successfully`,
            data: { id: updatedDoc.id, ...updatedDoc.data() }
        });
    } catch (error) {
        next(error);
    }
};

