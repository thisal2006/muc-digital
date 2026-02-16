import mongoose from 'mongoose';

const vehicleTypeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Vehicle type name is required'],
    unique: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  image: {
    type: String,
    trim: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

const VehicleType = mongoose.model('VehicleType', vehicleTypeSchema);

export default VehicleType;
