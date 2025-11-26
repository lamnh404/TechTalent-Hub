import express from 'express'

const router = express.Router()

router.get('/dashboard', (req, res) => {
    res.render('company/dashboard.ejs', { title: 'Company Dashboard', user : req.session.user } )
})

router.get('/jobs/create', (req, res) => {
    res.render('company/post-job.ejs', { title: 'Create Job', user : req.session.user } )
})

router.get('/jobs', (req, res) => {
    res.render('company/job-list.ejs', { title: 'Quản lý tin đăng', user : req.session.user } )
})

export const companyRouter = router