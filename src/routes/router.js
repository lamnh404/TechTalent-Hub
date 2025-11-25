import express from 'express'
import { homepageRouter } from './homepage/homepage'
import { authRouter } from './auth/authRouter'
import { pagesRouter } from './pages/pages'
import { companyRouter } from './company/company'

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/company', companyRouter)

export const API = router