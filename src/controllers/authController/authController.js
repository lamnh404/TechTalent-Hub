import { authModel } from '~/models/authModel/authModel.js'

let globalUserID = null
let tempmail = null

const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user
        globalUserID = user.id

        console.log('User logged in:', user)

        req.session.save((err) => {
            if (err) return next(err)
            res.redirect('/')
        })

    } catch (error) {
        res.render('auth/login.ejs', { title: 'Login', error: error.message })
    }
}

// --- LOGOUT ---
const logout = (req, res) => {
    // Destroy session
    req.session.destroy((err) => {
        if (err) {
            console.error('Error destroying session:', err);
            return res.status(500).send('Could not log out.');
        }

        // 2. Clear cookie on client side
        res.clearCookie('connect.sid');

        // 3. Redirect to home page
        res.redirect('/');
    });
}

// --- REGISTER ---
const register = async (req, res, next) => {
    try {
        const { email, password, role } = req.body
        const user = await authModel.register(email, password, role)

        req.session.user = user
        globalUserID = user.id
        tempmail = email
        req.session.save((err) => {
            if (err) return next(err);

            if (role === 'Company') {
                res.redirect('/setup-company')
            } else {
                res.redirect('/setup-seeker')
            }
        });
    } catch (error) {
        res.render('auth/register.ejs', { title: 'Register', error: error.message })
    }
}

const setupCompany = async (req, res, next) => {
    try {
        const userId = globalUserID
        console.log(globalUserID, tempmail)
        if (!userId) {
            res.redirect('/register')
            await authModel.deleteMail(tempmail)
            return
        }
        await authModel.setupCompany(userId, req.body)
        res.redirect('/')
    } catch (error) {
        console.log(error)
        res.render('auth/setup-company.ejs', { title: 'Setup Company', error: error.message })
    }
}

const setupSeeker = async (req, res, next) => {
    try {
        const userId = globalUserID
        console.log(globalUserID, tempmail)
        if (!userId) {
            res.redirect('/register')
            await authModel.deleteMail(tempmail)
            return
        }
        await authModel.setupSeeker(userId, req.body)
        res.redirect('/')
    } catch (error) {
        console.log(error)
        res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: error.message })
    }
}

export const authController = {
    register,
    login,
    logout,
    setupCompany,
    setupSeeker
}