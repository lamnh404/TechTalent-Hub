import { adminModel } from '~/models/adminModel/adminModel'

const viewDashboard = async (req, res, next) => {
    try {
        // simple auth: only allow admin userType
        const user = req.session && req.session.user
        if (!user || user.userType !== 'Admin') return res.redirect('/auth/login')

        const stats = await adminModel.getAdminStats()
        const activities = await adminModel.getRecentActivities(10)

        res.render('admin/dashboard.ejs', {
            title: 'Admin Dashboard',
            user: user,
            adminStats: stats,
            recentActivities: activities
        })
    } catch (error) {
        next(error)
    }
}

export const adminController = {
    viewDashboard
}
