import express from 'express'
import { applicationController } from '~/controllers/jobController/applicationController'

const router = express.Router()

router.post('/applications', applicationController.createApplication)

router.get('/seeker/applications', applicationController.getSeekerApplications)

router.get('/company/candidates', applicationController.getCompanyCandidates)

router.post('/applications/:applicationId/status', applicationController.updateStatus)

export const applicationRouter = router
