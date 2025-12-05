import express from 'express'

const router = express.Router()

import searchController from "~/controllers/jobController/searchController";
import { jobModel } from '~/models/jobModel/jobModel.js'
import { companyController } from '~/controllers/homepage/companyController'

router.get('/', async (req, res, next) => {
    try {
        const featuredJobs = await jobModel.getLatestJobs(3)
        res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage', user: req.session.user, featuredJobs })
    } catch (err) {
        next(err)
    }
})
router.get('/jobs', searchController.searchJobs)
router.get('/companies', companyController.viewCompanies)
router.get('/companies/:companyId', companyController.viewCompany)
router.post('/companies/:companyId/review', companyController.postReview)

export const homepageRouter = router