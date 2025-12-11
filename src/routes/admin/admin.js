import express from 'express'
import { adminController } from '~/controllers/adminController/adminController'

const router = express.Router()

router.get('/', adminController.viewDashboard)

router.get('/dashboard', adminController.viewDashboard)

router.get('/users', adminController.viewUsers)

router.get('/jobs', adminController.viewJobs)

router.get('/settings', (req, res) => {
    if (!req.session || !req.session.user || req.session.user.userType !== 'Admin') return res.redirect('/auth/login')
    res.render('admin/settings.ejs', { title: 'Admin Settings', user: req.session.user })
})

export { router as adminRouter }