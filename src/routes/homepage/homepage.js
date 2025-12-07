import express from 'express'

const router = express.Router()

import searchController from "~/controllers/jobController/searchController";
import { jobModel } from '~/models/jobModel/jobModel.js'
import { comviewController } from '~/controllers/homepage/comviewController'

router.get('/', async (req, res, next) => {
    try {
        const featuredJobs = await jobModel.getLatestJobs(3)
        res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage', user: req.session.user, featuredJobs })
    } catch (err) {
        next(err)
    }
})
router.get('/jobs', searchController.searchJobs)
router.get('/companies', comviewController.viewCompanies)
router.get('/companies/:companyId', comviewController.viewCompany)
router.post('/companies/:companyId/review', comviewController.postReview)

export const homepageRouter = router