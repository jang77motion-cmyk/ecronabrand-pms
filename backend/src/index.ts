import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';

dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:3000' }));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API Routes
app.get('/api/products', (req: Request, res: Response) => {
  res.json({ message: 'Products endpoint' });
});

app.get('/api/orders', (req: Request, res: Response) => {
  res.json({ message: 'Orders endpoint' });
});

app.get('/api/inventory', (req: Request, res: Response) => {
  res.json({ message: 'Inventory endpoint' });
});

app.get('/api/analytics/sales', (req: Request, res: Response) => {
  res.json({ message: 'Sales analytics endpoint' });
});

// API Documentation
app.get('/api/docs', (req: Request, res: Response) => {
  res.json({
    message: 'API Documentation',
    version: '1.0.0',
    endpoints: [
      '/api/products',
      '/api/orders',
      '/api/inventory',
      '/api/analytics/sales'
    ]
  });
});

// 404 Handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found' });
});

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
  console.log(`📚 API Documentation at http://localhost:${PORT}/api/docs`);
});

export default app;
