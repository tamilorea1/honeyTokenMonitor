/**
 * This file will log the trap hit
 */

import { Router, Request, Response } from "express";
import { logTrapHit } from "../services/dynamodb";
import { publishTrapAlert } from "../services/sns";

//Creates the mini route handler
const router = Router()

//Runs before every trap route -- logs who hit it & when
/**
 * router.use() acts as middleware
 * It runs on every request
 * Needs next(), else request would hang
 * Every service gets its own try catch so a failure in one doesn't block another
 */
router.use(async (request: Request, response: Response, next) => {
    const hit = {
        path: request.path,
        ip: request.ip || 'unknown',
        userAgent: request.headers['user-agent'] || 'unknown',
        time: new Date().toISOString()
    }
    console.log('TRAP HIT:', hit)

    try {
        await logTrapHit(hit)
        console.log('Logged to DynamoDB')
    } catch (error) {
        console.log('DynamoDB write failed:', error)
    }

    try {
        await publishTrapAlert(hit)
        console.log('SNS alert sent')
    } catch (error) {
        console.log('SNS publish failed:', error)
    }


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