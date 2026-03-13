import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema({
    vehicle: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Vehicle',
        required: [true, 'Vehicle is required']
    },
    bookingType: {
        type: String,
        enum: ['HALF_DAY_AM', 'HALF_DAY_PM', 'FULL_DAY', 'MULTIPLE_DAYS'],
        required: [true, 'Booking type is required']
    },
    startDate: {
        type: Date,
        required: [true, 'Start date is required']
    },
    endDate: {
        type: Date,
        required: [true, 'End date is required']
    },
    totalAmount: {
        type: Number,
        required: [true, 'Total amount is required']
    },
    status: {
        type: String,
        enum: ['PENDING', 'CONFIRMED', 'CANCELLED'],
        default: 'PENDING'
    },
    userName: {
        type: String,
        trim: true
    },
    userPhone: {
        type: String,
        trim: true
    },
    cancellationReason: {
        type: String,
        trim: true,
        default: null
    }
}, {
    timestamps: true
});

const Booking = mongoose.model('Booking', bookingSchema);

export default Booking;
