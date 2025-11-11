import { authModel } from '~/models/authModel/authModel.js'


const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)

        res.send(user)

    } catch (error) {
        next(error)
    }
}


export const authController = {
    login
}