import { authModel } from '~/models/authModel/authModel.js'
import { regModel } from '~/models/authModel/regModel.js'


const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user

        res.redirect('/')

    } catch (error) {
        next(error)
    }
}

const register = async (req, res, next) => {
    try {
        const { name, email, password, role } = req.body
        const user = await regModel.register(name, email, password, role)
        res.redirect('/login')

    } catch (error) {
        next(error)
    }
}

export const authController = {
    login,
    register
}