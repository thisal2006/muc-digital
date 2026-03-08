import swaggerJsdoc from 'swagger-jsdoc';

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Vehicle Booking API',
            version: '1.0.0',
            description: 'API for managing vehicle types, vehicles, and bookings',
        },
        servers: [
            {
                url: 'http://localhost:3000',
                description: 'Development server',
            },
        ],
    },
    apis: ['./router.js', './controller/*.js'], // Path to the API docs
};

const specs = swaggerJsdoc(options);

export default specs;
