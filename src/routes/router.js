import express from 'express'
import { homepageRouter } from './homepage/homepage'
import { authRouter } from './auth/authRouter'
import { pagesRouter } from './pages/pages'

const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)

router.use('/', pagesRouter)


export const API = router