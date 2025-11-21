import { authModel } from '~/models/authModel/authModel.js'

const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user

        console.log('User logged in:', user);

        req.session.save((err) => {
            if (err) return next(err);
            res.redirect('/')
        });

    } catch (error) {
        next(error)
    }
}

const logout = (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            console.error('Error destroying session:', err);
            return res.status(500).send('Could not log out.');
        }

        res.clearCookie('connect.sid');

        res.redirect('/');
    });
}

const register = async (req, res, next) => {
    try {
        const { email, password, role } = req.body
        const user = await authModel.register(email, password, role)

        req.session.user = user
        req.session.save((err) => {
            if (err) return next(err);

            if (role === 'Company') {
                res.redirect('/setup-company')
            } else {
                res.redirect('/setup-seeker')
            }
        });

    } catch (error) {
        next(error)
    }
}

const setupCompany = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        await authModel.setupCompany(userId, req.body)
        res.redirect('/')
    } catch (error) {
        next(error)
    }
}

const setupSeeker = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        await authModel.setupSeeker(userId, req.body)
        res.redirect('/')
    } catch (error) {
        next(error)
    }
}

export const authController = {
    register,
    login,
    logout,
    setupCompany,
    setupSeeker
}