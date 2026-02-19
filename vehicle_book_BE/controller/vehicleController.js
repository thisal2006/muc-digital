import Vehicle from '../model/Vehicle.js';

export const createVehicle = async (req, res, next) => {
    try {
        const vehicle = await Vehicle.create(req.body);
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
        const filter = {};
        
        if (type) {
            filter.type = type;
        }
        
        // Only include available vehicles by default
        if (includeUnavailable !== 'true') {
            filter.isAvailable = true;
        }
        
        const vehicles = await Vehicle.find(filter).populate({
            path: 'type',
            match: { isActive: true } // Only populate active vehicle types
        });
        
        // Filter out vehicles with inactive types
        const filteredVehicles = vehicles.filter(vehicle => vehicle.type !== null);
        
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
        const vehicles = await Vehicle.find().populate('type').sort({ createdAt: -1 });
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
        const vehicle = await Vehicle.findById(req.params.id).populate('type');
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }
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

        const vehicle = await Vehicle.findByIdAndUpdate(
            id,
            { isAvailable },
            { new: true, runValidators: true }
        ).populate('type');

        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        res.status(200).json({
            success: true,
            message: `Vehicle ${isAvailable ? 'enabled' : 'disabled'} successfully`,
            data: vehicle
        });
    } catch (error) {
        next(error);
    }
};
