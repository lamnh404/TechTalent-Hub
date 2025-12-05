import express from 'express'
import { userController } from '~/controllers/userController/userController'

const router = express.Router()

router.get('/', userController.viewSettings)
router.post('/change-password', userController.postChangePassword)

export const settingsRouter = router
