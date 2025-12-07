import { userModel } from '~/models/authModel/userModel'
import { authModel } from '~/models/authModel/authModel'

const getRole = async (req, res, next) => {
    try {
        const role = await userModel.getRole(req.session.user.id)
        res.json(role)
    } catch (error) {
        next(error)
    }
}

const getNotifications = async (req, res, next) => {
    try {
        if (!req.session || !req.session.user) return res.status(401).json({ message: 'Unauthorized' })
        const userId = req.session.user.id
        const notifications = await userModel.getNotifications(userId)
        res.json({ notifications })
    } catch (error) {
        next(error)
    }
}

const viewSettings = async (req, res, next) => {
    try {
        if (!req.session || !req.session.user) return res.redirect('/auth/login')

        const { success: succ, error: errMsg } = req.query
        let success = undefined
        let error = undefined
        if (succ === 'password') success = 'Password changed successfully.'
        if (errMsg === 'missing_fields') error = 'Please fill all password fields.'
        if (errMsg === 'password_mismatch') error = 'New password and confirmation do not match.'
        if (errMsg && !error) error = errMsg

        res.render('seeker/setting.ejs', {
            title: 'Settings',
            user: req.session.user,
            activePage: 'settings',
            success,
            error
        })
    } catch (err) {
        next(err)
    }
}

const postChangePassword = async (req, res, next) => {
    try {
        if (!req.session || !req.session.user) return res.redirect('/auth/login')
        const userId = req.session.user.id
        const { currentPassword, newPassword, confirmPassword } = req.body

        if (!currentPassword || !newPassword || !confirmPassword) {
            return res.redirect('/settings?error=missing_fields')
        }
        if (newPassword !== confirmPassword) {
            return res.redirect('/settings?error=password_mismatch')
        }

        await authModel.changePassword(userId, currentPassword, newPassword)
        res.redirect('/settings?success=password')
    } catch (err) {
        if (err && err.statusCode) {
            return res.redirect(`/settings?error=${encodeURIComponent(err.message)}`)
        }
        next(err)
    }
}

export const userController = {
    getRole,
    getNotifications,
    viewSettings,
    postChangePassword
}