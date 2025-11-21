import express from 'express'
import { authController } from '~/controllers/authController/authController'

const router = express.Router()

router.get('/login', (req, res) => {
    res.render('auth/login.ejs', { title: 'Login' })
})

router.get('/register', (req, res) => {
    res.render('auth/register.ejs', { title: 'Register' })
})

router.post('/login', authController.login)
router.post('/register', authController.register)
export const authRouter = router