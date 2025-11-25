import express from 'express'
import { homepageRouter } from './homepage/homepage'
import { authRouter } from './auth/authRouter'
import { pagesRouter } from './pages/pages'
import { jobRouter } from './job/jobRouter'

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)

router.use('/', jobRouter)

export const API = router