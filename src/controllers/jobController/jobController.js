import { jobModel } from '~/models/jobModel/jobModel.js'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getCreateJobPage = (req, res) => {
    res.render('company/post-job.ejs', { title: 'Post A Job', user: req.session.user })
}

const createJob = async (req, res, next) => {
    try {
        const { JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, ExperienceRequired, ApplicationDeadline, skills } = req.body

        if (!req.session.user) {
            return res.status(StatusCodes.UNAUTHORIZED).send('User not authenticated')
        }

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
        res.render('company/post-job.ejs', { title: 'Post A Job', error: error.message, user: req.session.user })
    }
}

const getJobDetails = async (req, res, next) => {
    try {
        const { jobId } = req.params
        const job = await jobModel.getJobById(jobId)

        if (!job) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'Job not found')
        }

        res.render('homepage/job-detail.ejs', { title: job.JobTitle, job, user: req.session.user })
    } catch (error) {
        next(error)
    }
}

const getCompanyJobs = async (req, res, next) => {
    try {
        if (!req.session.user) {
            return res.status(StatusCodes.UNAUTHORIZED).send('User not authenticated')
        }

        const companyId = req.session.user.id
        const jobs = await jobModel.getJobsByCompanyId(companyId)

        res.render('company/job-list.ejs', { title: 'My Job Posts', jobs, user: req.session.user })
    } catch (error) {
        next(error)
    }
}

export const jobController = {
    getCreateJobPage,
    createJob,
    getJobDetails,
    getCompanyJobs
}
