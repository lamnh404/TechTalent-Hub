import { companyModel } from '~/models/companyModel/companyModel.js'
import { jobModel } from '~/models/jobModel/jobModel.js'
import { applicationModel } from '~/models/applyModel/applicationModel.js'
import { seekerModel } from '~/models/seekerModel/seekerModel.js'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getDashboard = async (req, res, next) => {
    try {
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
        const companyId = req.session.user.id
        const page = parseInt(req.query.page) || 1
        const limit = 10

        const { jobs, currentPage, totalPages, totalJobs } = await jobModel.getJobsByCompanyId(companyId, page, limit)

        res.render('company/job-list.ejs', {
            title: 'My Jobs Posts',
            user: req.session.user,
            jobs,
            currentPage,
            totalPages,
            totalJobs
        })
    } catch (error) {
        next(error)
    }
}

const getCandidates = async (req, res, next) => {
    try {
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
        const companyId = req.session.user.id
        await companyModel.updateCompanyProfile(companyId, req.body)

        res.redirect('/company/profile?success=true')
    } catch (error) {
        next(error)
    }
}

const getCreateJobPage = async (req, res, next) => {
    try {
        const availableSkills = await seekerModel.getAvailableSkills()
        res.render('company/post-job.ejs', {
            title: 'Post A Job',
            user: req.session.user,
            availableSkills
        })
    } catch (error) {
        next(error)
    }
}

const createJob = async (req, res, next) => {
    try {
        const { JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, ExperienceRequired, ApplicationDeadline, OpeningCount, skills } = req.body
        const companyId = req.session.user.id

        // Parse skills from comma-separated string if needed, or use as array if already array
        const skillsArray = skills ? skills.split(',').filter(s => s.trim() !== '') : []

        await jobModel.createJob({
            jobTitle: JobTitle,
            jobDescription: JobDescription,
            salaryMin: SalaryMin,
            salaryMax: SalaryMax,
            location: Location,
            employmentType: EmploymentType,
            experienceRequired: ExperienceRequired,
            applicationDeadline: ApplicationDeadline,
            openingCount: OpeningCount,
            companyId: companyId,
            skills: skillsArray
        })

        res.redirect('/company/jobs')
    } catch (error) {
        console.log(error)
        const availableSkills = await seekerModel.getAvailableSkills()
        res.render('company/post-job.ejs', {
            title: 'Post A Job',
            error: error.message,
            user: req.session.user,
            availableSkills,
            job: req.body // Pass back submitted data
        })
    }
}

const deleteJob = async (req, res, next) => {
    try {
        const { id } = req.params
        const companyId = req.session.user.id

        await jobModel.deleteJob(id, companyId)

        res.redirect('/company/jobs')
    } catch (error) {
        next(error)
    }
}

const toggleJobStatus = async (req, res, next) => {
    try {
        const { id } = req.params
        const { status } = req.body // 'Open' or 'Closed'
        const companyId = req.session.user.id

        await jobModel.updateJobStatus(id, companyId, status)

        res.redirect('/company/jobs')
    } catch (error) {
        next(error)
    }
}

const getEditJobPage = async (req, res, next) => {
    try {
        const { id } = req.params
        const companyId = req.session.user.id

        const job = await jobModel.getJobById(id)

        if (!job || job.CompanyID !== companyId) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'Job not found or unauthorized')
        }

        const availableSkills = await seekerModel.getAvailableSkills()

        res.render('company/post-job.ejs', {
            title: 'Edit Job',
            user: req.session.user,
            job,
            isEdit: true,
            availableSkills
        })
    } catch (error) {
        next(error)
    }
}

const updateJob = async (req, res, next) => {
    const { id } = req.params
    const job = await jobModel.getJobById(id)
    try {
        const companyId = req.session.user.id

        const { JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, ExperienceRequired, ApplicationDeadline, OpeningCount, skills } = req.body

        const skillsArray = skills ? skills.split(',').filter(s => s.trim() !== '') : []

        await jobModel.updateJob(id, companyId, {
            jobTitle: JobTitle,
            jobDescription: JobDescription,
            salaryMin: SalaryMin,
            salaryMax: SalaryMax,
            location: Location,
            employmentType: EmploymentType,
            experienceRequired: ExperienceRequired,
            applicationDeadline: ApplicationDeadline,
            openingCount: OpeningCount,
            skills: skillsArray
        })

        res.redirect('/company/jobs')
    } catch (error) {
        console.log(error)
        const availableSkills = await seekerModel.getAvailableSkills()
        res.render('company/post-job.ejs', {
            title: 'Edit Job',
            error: error.message,
            user: req.session.user,
            job,
            isEdit: true,
            availableSkills
        })
    }
}

const updateApplicationStatus = async (req, res, next) => {
    try {
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
    updateApplicationStatus,
    deleteJob,
    toggleJobStatus,
    getEditJobPage,
    updateJob
}
