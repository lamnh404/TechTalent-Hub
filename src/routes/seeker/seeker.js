import express from 'express'
import { seekerController } from '~/controllers/seekerController/seekerController'

const router = express.Router()

router.get('/dashboard', seekerController.viewDashboard)

router.get('/profile', seekerController.viewProfile)
router.post('/profile/update', seekerController.handleUpdateProfile)
router.post('/profile/addskill', seekerController.addSkill)
router.post('/profile/delete-skill', seekerController.deleteSkill)
router.get('/profile/myskills', seekerController.getSkills)
router.post('/profile/skills/recalculate', seekerController.recalculateSkills)

router.get('/saved-jobs', seekerController.viewSavedJobs)

export const seekerRouter = router