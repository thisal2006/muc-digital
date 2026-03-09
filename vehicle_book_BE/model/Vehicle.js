import mongoose from 'mongoose';

const vehicleSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Vehicle name is required'],
        trim: true
    },
    type: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'VehicleType',
        required: [true, 'Vehicle type is required']
    },
    description: {
        type: String,
        trim: true
    },
    pricePerDay: {
        type: Number,
        required: [true, 'Full day price is required']
    },
    halfDayPrice: {
        type: Number,
        required: [true, 'Half day price is required']
    },
    images: [{
        type: String,
        trim: true
    }],
    includedServices: [{
        type: String,
        trim: true
    }],
    isAvailable: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

const Vehicle = mongoose.model('Vehicle', vehicleSchema);

export default Vehicle;
