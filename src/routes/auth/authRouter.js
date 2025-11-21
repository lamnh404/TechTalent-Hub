import express from 'express'
import { authController } from '~/controllers/authController/authController'

const router = express.Router()

router.get('/login', (req, res) => {
    res.render('auth/login.ejs', { title: 'Login' })
})

router.post('/auth/login', authController.login)

router.get('/register', (req, res) => {
    res.render('auth/register.ejs', { title: 'Register' })
})

router.get('/setup-seeker', (req, res) => {
    res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker' })
})
router.get('/setup-company', (req, res) => {
    res.render('auth/setup-company.ejs', { title: 'Setup Company' })
})

router.get('/auth/logout', authController.logout)

export const authRouter = router