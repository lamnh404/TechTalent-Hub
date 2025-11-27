import express from 'express'
import { homepageRouter } from '~/routes/homepage/homepage'
import { authRouter } from '~/routes/auth/authRouter'
import { pagesRouter } from '~/routes/pages/pages'
import { companyRouter } from './company/company'
import { seekerRouter } from './seeker/seeker'
import {adminRouter} from "~/routes/admin/admin";

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/company', companyRouter)

router.use('/seeker', seekerRouter)

router.use('/admin', adminRouter)
export const API = router