import express from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import specs from './config/swagger.js';
import router from './router.js';
import errorHandler from './middleware/errorHandler.js';
import dotenv from 'dotenv';
import connectDB from './config/dbconnect.js';

// Load environment variables FIRST
dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();
const PORT = process.env.PORT;

// Middleware
app.use(cors());
app.use(express.json());

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

app.use('/api', router);

// ⚠️ Global error handler (MUST be last middleware)
app.use(errorHandler);



app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});