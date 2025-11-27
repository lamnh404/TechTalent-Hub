import { userModel } from '~/models/userModel'

const getRole = async (req, res, next) => {
    try {
        const role = await userModel.getRole(req.session.user.id)
        res.json(role)
    } catch (error) {
        next(error)
    }
}

export const userController = {
    getRole
}