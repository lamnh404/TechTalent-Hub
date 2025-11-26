import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
    res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage', user : req.session.user } )
})

router.get('/jobs', (req, res) => {
    res.render('homepage/job-listing.ejs', { title: 'Job Listings', user : req.session.user } )
})

router.get('/jobs/:id', (req, res) => {
    const jobId = req.params.id;
    res.render('homepage/job-detail.ejs', { title: 'Job Detail', user : req.session.user, jobId } )
})
export const homepageRouter = router