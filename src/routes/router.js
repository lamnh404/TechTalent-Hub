import express from 'express'
import { homepageRouter } from '~/routes/homepage/homepage'
import { authRouter } from '~/routes/auth/authRouter'
import { pagesRouter } from '~/routes/pages/pages'
import { companyRouter } from './company/company'
import { seekerRouter } from './seeker/seeker'
import { settingsRouter } from './settings/settings'
import { adminRouter } from "~/routes/admin/admin";
import { jobRouter } from "~/routes/job/jobRouter";
import isAuthorized from '~/middlewares/authorizedMiddleware'
import { applicationRouter } from "~/routes/job/applicationRouter";

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/company', isAuthorized, companyRouter)

router.use('/seeker', isAuthorized, seekerRouter)

router.use('/settings', isAuthorized, settingsRouter)

router.use('/admin', isAuthorized, adminRouter)

router.use('/', jobRouter)

router.use('/', applicationRouter)
export const API = router