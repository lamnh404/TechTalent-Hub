import express from 'express'
import { homepageRouter } from './homepage/homepage'
import { authRouter } from './auth/authRouter'
import { pagesRouter } from './pages/pages'
import { companyRouter } from './company/company'
import { seekerRouter } from './seeker/seeker'

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/company', companyRouter)

router.use('/seeker', seekerRouter)

export const API = router