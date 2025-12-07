import express from 'express'
import { companyController } from '~/controllers/companyController/companyController.js'

const router = express.Router()

router.get('/dashboard', companyController.getDashboard)

router.get('/jobs/create', companyController.getCreateJobPage)
router.post('/jobs/create', companyController.createJob)

router.get('/jobs', companyController.getJobs)
router.post('/dashboard/stats', companyController.getApplicationStatistics)
router.post('/jobs/:id/delete', companyController.deleteJob)
router.post('/jobs/:id/status', companyController.toggleJobStatus)
router.get('/jobs/:id/edit', companyController.getEditJobPage)
router.post('/jobs/:id/edit', companyController.updateJob)

router.get('/candidates', companyController.getCandidates)
router.get('/applications/:applicationId', companyController.getApplicationDetail)

router.get('/profile', companyController.getProfile)
router.post('/profile', companyController.updateProfile)

router.post('/applications/:applicationId/status', companyController.updateApplicationStatus)

export const companyRouter = router