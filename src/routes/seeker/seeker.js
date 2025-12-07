import express from 'express'
import { seekerController } from '~/controllers/seekerController/seekerController'

const router = express.Router()

router.get('/dashboard', seekerController.viewDashboard)

router.get('/profile', seekerController.viewProfile)
router.post('/profile/update', seekerController.handleUpdateProfile)
router.post('/profile/addskill', seekerController.addSkill)
router.post('/profile/delete-skill', seekerController.deleteSkill)
router.get('/profile/myskills', seekerController.getSkills)

router.get('/suggestions', seekerController.getSuggestions)


export const seekerRouter = router