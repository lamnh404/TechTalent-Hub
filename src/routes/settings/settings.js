import express from 'express'
import { userController } from '~/controllers/authController/userController'

const router = express.Router()

router.get('/', userController.viewSettings)
router.post('/change-password', userController.postChangePassword)

export const settingsRouter = router
