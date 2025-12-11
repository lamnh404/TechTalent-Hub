import { adminModel } from '~/models/adminModel/adminModel'

const viewDashboard = async (req, res, next) => {
    try {
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

const viewUsers = async (req, res, next) => {
    try {
        const user = req.session && req.session.user
        if (!user || user.userType !== 'Admin') return res.redirect('/auth/login')

        const page = parseInt(req.query.page) || 1
        const limit = parseInt(req.query.limit) || 50
        const search = req.query.search || ''

        const userList = await adminModel.getAllUsers(page, limit, search)

        res.render('admin/users.ejs', {
            title: 'User Management',
            user: user,
            userList
        })
    } catch (error) {
        next(error)
    }
}

const viewJobs = async (req, res, next) => {
    try {
        const user = req.session && req.session.user
        if (!user || user.userType !== 'Admin') return res.redirect('/auth/login')

        const page = parseInt(req.query.page) || 1
        const limit = parseInt(req.query.limit) || 50
        const search = req.query.search || ''

        const allJobs = await adminModel.getAllJobs(page, limit, search)

        res.render('admin/jobs.ejs', {
            title: 'Jobs Management',
            user: req.session && req.session.user,
            allJobs
        })
    } catch (error) {
        next(error)
    }
}

export const adminController = {
    viewDashboard, 
    viewUsers, 
    viewJobs
}
