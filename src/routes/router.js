import express from 'express'
import { homepageRouter } from './homepage/homepage'
import { authRouter } from './auth/authRouter'


const router = express.Router()

router.use('/', homepageRouter)

router.use('/', authRouter)


export const API = router