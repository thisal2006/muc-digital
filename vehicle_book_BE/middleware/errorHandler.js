import { constants } from "../constants.js";

const errorHandling = (err, req, res, next) => {
    let statusCode = res.statusCode ? res.statusCode : 500;
    let title = "Server Error";
    let message = err.message;

    // Handle Mongoose CastError (Invalid ID)
    if (err.name === 'CastError') {
        statusCode = constants.VALIDATION_ERROR;
        title = "Invalid ID";
        message = `Resource not found with id of ${err.value}`;
    }

    // Handle Mongoose ValidationError
    if (err.name === 'ValidationError') {
        statusCode = constants.VALIDATION_ERROR;
        title = "Validation Error";
        message = Object.values(err.errors).map(val => val.message).join(', ');
    }

    res.status(statusCode).json({
        success: false,
        title,
        message,
        stackType: process.env.NODE_ENV === 'production' ? null : err.stack
    });

    if (statusCode === 500) {
        console.error("❌ ERROR:", err);
    }
};

export default errorHandling;