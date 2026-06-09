import { Router, Request, Response } from "express";

//Creates the mini route handler
const router = Router()

//Runs before every trap route -- logs who hit it & when
/**
 * router.use() acts as middleware
 * It runs on every request
 * Needs next(), else request would hang
 */
router.use((request: Request, response: Response, next) => {
    console.log('TRAP HIT:', {
        path: request.path,
        ip: request.ip,
        userAgent: request.headers['user-agent'],
        time: new Date().toISOString()
    })
    next()
})

//Fake admin panel endpoint
router.get('/admin', (request: Request, response: Response)=> {
    response.status(403).json({error: 'Forbidden'})
})

//Fake key management endpoint
router.get('/keys', (request: Request, response: Response)=> {
    response.status(403).json({error: 'Forbidden'})
})

//Fake config/secrets  endpoint
router.get('/config', (request: Request, response: Response)=> {
    response.status(403).json({error: 'Forbidden'})
})

export default router