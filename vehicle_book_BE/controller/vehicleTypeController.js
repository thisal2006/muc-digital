import VehicleType from '../model/VehicleType.js';

export const createVehicleType = async (req, res, next) => {
    try {
        const { name, description, image } = req.body;
        const vehicleType = await VehicleType.create({ name, description, image });
        res.status(201).json({
            success: true,
            data: vehicleType
        });
    } catch (error) {
        next(error);
    }
};

export const getVehicleTypes = async (req, res, next) => {
    try {
        const { includeInactive } = req.query;
        const filter = includeInactive === 'true' ? {} : { isActive: true };
        const vehicleTypes = await VehicleType.find(filter);
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
        const vehicleTypes = await VehicleType.find().sort({ createdAt: -1 });
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
        const vehicleType = await VehicleType.findById(req.params.id);
        if (!vehicleType) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle type not found'
            });
        }
        res.status(200).json({
            success: true,
            data: vehicleType
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

        const vehicleType = await VehicleType.findByIdAndUpdate(
            id,
            { isActive },
            { new: true, runValidators: true }
        );

        if (!vehicleType) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle type not found'
            });
        }

        res.status(200).json({
            success: true,
            message: `Vehicle type ${isActive ? 'enabled' : 'disabled'} successfully`,
            data: vehicleType
        });
    } catch (error) {
        next(error);
    }
};
