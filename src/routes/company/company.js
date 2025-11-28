import express from 'express'
import { companyController } from '~/controllers/companyController/companyController.js'

const router = express.Router()

router.get('/dashboard', companyController.getDashboard)

router.get('/jobs/create', companyController.getCreateJobPage)
router.post('/jobs/create', companyController.createJob)

router.get('/jobs', companyController.getJobs)

router.get('/candidates', companyController.getCandidates)

router.get('/profile', companyController.getProfile)
router.post('/profile', companyController.updateProfile)

// Route for updating application status
router.post('/applications/:applicationId/status', companyController.updateApplicationStatus)

export const companyRouter = router