import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/', async (req: Request, res: Response) => {
    try {
        const userCount = await prisma.user.count();
        res.json({ message: 'Agentic LMS Admin API is running', db_users: userCount });
    } catch (error) {
        res.status(500).json({ error: 'Database connection failed', details: error });
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
