import { authModel } from '~/models/authModel/authModel.js'

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

const logout = (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            console.error('Error destroying session:', err)
            return res.status(500).send('Could not log out')
        }

        res.clearCookie('connect.sid')

        res.redirect('/')
    })
}

const register = async (req, res, next) => {
    try {
        const { email, password, role } = req.body
        const tempUser = await authModel.register(email, password, role)

        req.session.tempRegister = tempUser
        req.session.save((err) => {
            if (err) return next(err)

            if (role === 'Company') {
                res.redirect('/setup-company')
            } else {
                res.redirect('/setup-seeker')
            }
        })

    } catch (error) {
        res.render('auth/register.ejs', { title: 'Register', error: error.message })
    }
}

const setupCompany = async (req, res, next) => {
    try {
        const tempUser = req.session.tempRegister
        if (!tempUser) {
            return res.redirect('/register')
        }

        const user = await authModel.setupCompany(tempUser, req.body)

        delete req.session.tempRegister
        req.session.user = user

        req.session.save((err) => {
            if (err) return next(err)
            res.redirect('/')
        })
    } catch (error) {
        res.render('auth/setup-company.ejs', { title: 'Setup Company', error: error.message })
    }
}

const setupSeeker = async (req, res, next) => {
    try {
        const tempUser = req.session.tempRegister
        if (!tempUser) {
            return res.redirect('/register')
        }

        const user = await authModel.setupSeeker(tempUser, req.body)

        delete req.session.tempRegister
        req.session.user = user

        req.session.save((err) => {
            if (err) return next(err)
            res.redirect('/')
        })
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