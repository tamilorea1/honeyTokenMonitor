import { Router, Request, Response } from 'express';
import { getAllIncidents } from '../services/dynamodb';

const router = Router();

// GET /incidents — returns every logged incident as JSON
router.get('/', async (request: Request, response: Response) => {
    try {
        const incidents = await getAllIncidents();
        response.json(incidents);
    } catch (error) {
        console.error('Failed to fetch incidents:', error);
        response.status(500).json({ error: 'Failed to fetch incidents' });
    }
});

export default router;
