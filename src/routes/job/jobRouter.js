import express from 'express'
import { jobController } from '~/controllers/jobController/jobController.js'

const router = express.Router()

router.get('/company/jobs/create', jobController.getCreateJobPage)
router.post('/company/jobs/create', jobController.createJob)
router.get('/company/jobs', jobController.getCompanyJobs)
router.get('/jobs/:jobId', jobController.getJobDetails)

export const jobRouter = router
