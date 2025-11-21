import express from 'express'

const router = express.Router()

router.get('/', (req, res) => {
    console.log('Session user on homepage:', req.session.user);
    res.render('homepage/homepage.ejs', { title: 'Welcome to the Homepage', user : req.session.user } )
}
)

export const homepageRouter = router