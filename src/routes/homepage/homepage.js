import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
    res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage' })
}
)

export const homepageRouter = router