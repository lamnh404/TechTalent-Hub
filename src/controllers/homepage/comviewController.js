import { companyModel } from '~/models/companyModel/companyModel'
import { jobModel } from '~/models/jobModel/jobModel'

const viewCompany = async (req, res, next) => {
    try {
        const companyId = req.params.companyId
        if (!companyId) return res.status(400).render('error/error.ejs', { message: 'Company ID is required' })

            const company = await companyModel.getCompanyProfile(companyId)
            const jobsResult = await jobModel.getJobsByCompanyId(companyId, 1, 50, '', 'Open')
            const openJobs = jobsResult && jobsResult.jobs ? jobsResult.jobs : []
            let reviews = []
            try {
                reviews = await companyModel.getCompanyReviews(companyId, 20)
            } catch (e) {
                reviews = []
            }

            res.render('homepage/company-detail.ejs', {
                title: company && company.CompanyName ? company.CompanyName : 'Company',
                user: req.session && req.session.user,
                company,
                openJobs,
                reviews
            })
    } catch (error) {
        next(error)
    }
}

const viewCompanies = async (req, res, next) => {
    try {
        const q = req.query.q || ''
        const page = parseInt(req.query.page) || 1
        const companies = await companyModel.getCompanies(q, page, 20)
        res.render('homepage/companies.ejs', {
            title: 'Companies',
            user: req.session && req.session.user,
            companies,
            query: q
        })
    } catch (error) {
        next(error)
    }
}

const postReview = async (req, res, next) => {
    try {
        const user = req.session && req.session.user
        if (!user || user.userType !== 'JobSeeker') return res.status(403).redirect('/auth/login')

        const companyId = req.params.companyId
        const { title, content, rating } = req.body
        const isAnonymous = req.body.isAnonymous ? 1 : 0
        if (!companyId || !title || !content || !rating) {
            return res.status(400).redirect(`/companies/${companyId}`)
        }

        await companyModel.addCompanyReview(companyId, user.id, title, content, parseInt(rating), isAnonymous)
        res.redirect(`/companies/${companyId}`)
    } catch (error) {
        next(error)
    }
}

export const comviewController = { 
    viewCompany, 
    viewCompanies,
    postReview
}
