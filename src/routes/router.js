import express from 'express'
import { homepageRouter } from '~/routes/homepage/homepage'
import { authRouter } from '~/routes/auth/authRouter'
import { pagesRouter } from '~/routes/pages/pages'
import { companyRouter } from './company/company'
import { jobRouter } from '~/routes/job/jobRouter'
import { applicationRouter } from '~/routes/job/applicationRouter'

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/company', companyRouter)

router.use('/', jobRouter)

router.use('/', applicationRouter)

export const API = router