import express from 'express'

const router = express.Router()

router.get('/login', (req, res) => {
    res.render('auth/login.ejs', { title: 'Login' });
});

// router.post('/login'
// )
export const authRouter = router