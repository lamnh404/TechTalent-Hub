import express from 'express';

const router = express.Router();

router.get('/about', (req, res) => {
    res.render('pages/about.ejs', { title: 'About Us' });
})
router.get('/contact', (req, res) => {
    res.render('pages/contact.ejs', { title: 'Contact Us' });
})
router.get('/privacy', (req, res) => {
    res.render('pages/privacy.ejs', { title: 'Privacy Policy' });
});
router.get('/terms', (req, res) => {
    res.render('pages/terms.ejs', { title: 'Terms and Conditions' });
})

export const pagesRouter = router;