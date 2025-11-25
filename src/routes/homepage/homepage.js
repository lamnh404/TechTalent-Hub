import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
    res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage', user : req.session.user } )
})

router.get('/jobs', (req, res) => {
    res.render('homepage/job-listing.ejs', { title: 'Job Listings', user : req.session.user } )
})
export const homepageRouter = router