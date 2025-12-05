import express from 'express'
import { jobController } from '~/controllers/jobController/jobController.js'

const router = express.Router()

router.get('/jobs/:jobId', jobController.getJobDetails)

export const jobRouter = router
