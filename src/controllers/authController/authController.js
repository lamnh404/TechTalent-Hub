import { authModel } from '~/models/authModel/authModel.js'
import { regModel } from '~/models/authModel/regModel.js'

// --- LOGIN ---
const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user

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
        const { name, email, password, role } = req.body
        const user = await regModel.register(name, email, password, role)
        
        // After registration, redirect to login
        res.redirect('/auth/login') 

    } catch (error) {
        next(error)
    }
}

// --- EXPORT ---
export const authController = {
    register,
    register,
    login,
    logout,
    setupCompany,
    setupSeeker
}