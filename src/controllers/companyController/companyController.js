import { companyModel } from '~/models/companyModel/companyModel.js'
import { jobModel } from '~/models/jobModel/jobModel.js'
import { applicationModel } from '~/models/applyModel/applicationModel.js'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getDashboard = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const companyId = req.session.user.id
        const stats = await companyModel.getDashboardStats(companyId)
        const recentJobs = await companyModel.getRecentJobs(companyId)

        res.render('company/dashboard.ejs', {
            title: 'Company Dashboard',
            user: req.session.user,
            stats,
            recentJobs
        })
    } catch (error) {
        next(error)
    }
}

const getJobs = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const companyId = req.session.user.id
        const jobs = await jobModel.getJobsByCompanyId(companyId)

        res.render('company/job-list.ejs', {
            title: 'My Jobs Posts',
            user: req.session.user,
            jobs
        })
    } catch (error) {
        next(error)
    }
}

const getCandidates = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const companyId = req.session.user.id
        const candidates = await applicationModel.getCandidatesByCompanyId(companyId)

        res.render('company/candidates.ejs', {
            title: 'My Candidates',
            user: req.session.user,
            candidates
        })
    } catch (error) {
        next(error)
    }
}

const getProfile = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const companyId = req.session.user.id
        const company = await companyModel.getCompanyProfile(companyId)

        res.render('company/profile.ejs', {
            title: 'Company Profile',
            user: req.session.user,
            company,
            success: req.query.success === 'true'
        })
    } catch (error) {
        next(error)
    }
}

const updateProfile = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const companyId = req.session.user.id
        await companyModel.updateCompanyProfile(companyId, req.body)

        res.redirect('/company/profile?success=true')
    } catch (error) {
        next(error)
    }
}

const getCreateJobPage = (req, res) => {
    if (!req.session.user) {
        return res.redirect('/auth/login')
    }
    res.render('company/post-job.ejs', { title: 'Post A Job', user: req.session.user })
}

const createJob = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.redirect('/auth/login')
        }
        const { JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, ExperienceRequired, ApplicationDeadline, skills } = req.body
        const companyId = req.session.user.id

        await jobModel.createJob({
            jobTitle: JobTitle,
            jobDescription: JobDescription,
            salaryMin: SalaryMin,
            salaryMax: SalaryMax,
            location: Location,
            employmentType: EmploymentType,
            experienceRequired: ExperienceRequired,
            applicationDeadline: ApplicationDeadline,
            skills: skills,
            companyId
        })

        res.redirect('/company/jobs')
    } catch (error) {
        res.render('company/post-job.ejs', {
            title: 'Post A Job',
            error: error.message,
            user: req.session.user
        })
    }
}

const updateApplicationStatus = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.status(StatusCodes.UNAUTHORIZED).json({ message: 'Unauthorized' })
        }
        const { applicationId } = req.params
        const { status } = req.body

        await applicationModel.updateApplicationStatus(applicationId, status)

        res.status(StatusCodes.OK).json({ message: 'Status updated successfully' })
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ message: error.message })
    }
}

export const companyController = {
    getDashboard,
    getJobs,
    getCandidates,
    getProfile,
    updateProfile,
    getCreateJobPage,
    createJob,
    updateApplicationStatus
}
