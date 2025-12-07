import { authModel } from '~/models/authModel/authModel.js'

const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user

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
            res.redirect('/login')
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

        const { FirstName, LastName, PhoneNumber, DateOfBirth, CVFileURL } = req.body

        if (!FirstName || FirstName.trim() === '') {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'First name is required' })
        }
        if (!LastName || LastName.trim() === '') {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'Last name is required' })
        }
        const phoneRegex = /^(0|\+84)\d{9,10}$/
        if (!PhoneNumber || PhoneNumber.trim() === '') {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'Phone number is required' })
        }
        if (!phoneRegex.test(PhoneNumber.trim())) {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'Invalid phone number (must be 10-11 digits and start with 0 or +84)' })
        }
        if (!DateOfBirth) {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'Date of birth is required' })
        }
        const dob = new Date(DateOfBirth)
        const today = new Date()
        let age = today.getFullYear() - dob.getFullYear()
        const m = today.getMonth() - dob.getMonth()
        if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
            age--
        }
        if (isNaN(dob.getTime()) || age < 15) {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'Invalid date of birth (must be at least 15 years old)' })
        }
        if (!CVFileURL || CVFileURL.trim() === '') {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'CV / Portfolio link is required' })
        }
        if (!CVFileURL.startsWith('https://')) {
            return res.render('auth/setup-seeker.ejs', { title: 'Setup Seeker', error: 'CV link must start with https://' })
        }

        const user = await authModel.setupSeeker(tempUser, req.body)

        delete req.session.tempRegister
        req.session.user = user

        req.session.save((err) => {
            if (err) return next(err)
            res.redirect('/login')
        })
    } catch (error) {
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