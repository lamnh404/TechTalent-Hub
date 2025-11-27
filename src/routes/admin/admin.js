import express from 'express'

const router = express.Router()

router.get('/dashboard', (req, res) => {
    res.render('admin/dashboard.ejs', { title: 'Admin Dashboard', user : req.session.user } )
})

router.get('/users', (req, res) => {
    res.render('admin/users.ejs', { title: 'User Management', user : req.session.user } )
})

router.get('/jobs', (req, res) => {
    res.render('admin/jobs.ejs', { title: 'Jobs Management', user : req.session.user } )
})

router.get('/settings', (req, res) => {
    res.render('admin/settings.ejs', { title: 'Admin Settings', user : req.session.user } )
})

export const adminRouter = router