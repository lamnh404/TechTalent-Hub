import express from 'express'

const router = express.Router()

router.get('/dashboard', (req, res) => {
    res.render('company/dashboard.ejs', { title: 'Company Dashboard', user : req.session.user } )
})

router.get('/jobs/create', (req, res) => {
    res.render('company/post-job.ejs', { title: 'Create Job', user : req.session.user } )
})

router.get('/jobs', (req, res) => {
    res.render('company/job-list.ejs', { title: 'My Jobs Posts', user : req.session.user } )
})

router.get('/candidates', (req, res) => {
    res.render('company/candidates.ejs', { title: 'My Candidates', user : req.session.user } )
})

router.get('/profile', (req, res) => {
    res.render('company/profile.ejs', { title: 'Company Profile', user : req.session.user } )
})

export const companyRouter = router