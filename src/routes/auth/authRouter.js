import express from 'express'
import { authController } from '~/controllers/authController/authController'

const router = express.Router()

router.get('/login', (req, res) => {
    res.render('auth/login.ejs', { title: 'Login' })
})

router.post('/login', authController.login)
export const authRouter = router