import express from 'express'

const router = express.Router()

router.get('/dashboard', (req, res) => {
    res.render('company/dashboard.ejs', { title: 'Company Dashboard', user : req.session.user } )
})

router.get('/my-applications', (req, res) => {
    res.render('seeker/my-applications.ejs', { title: 'My Applications', user : req.session.user } )
})

router.get('/profile', (req, res) => {
    res.render('seeker/profile.ejs', { title: 'My Profile', user : req.session.user } )
})

router.get('/saved-jobs', (req, res) => {
    res.render('seeker/saved-jobs.ejs', { title: 'Saved Jobs', user : req.session.user } )
})

export const seekerRouter = router