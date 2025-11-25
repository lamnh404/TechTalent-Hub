import { jobModel } from '~/models/jobModel/jobModel.js'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getCreateJobPage = (req, res) => {
    res.render('jobs/jobCreate.ejs', { title: 'Create Job', user: req.session.user })
}

const createJob = async (req, res, next) => {
    try {
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType } = req.body

        if (!req.session.user) {
            return res.status(StatusCodes.UNAUTHORIZED).send('User not authenticated')
        }

        const companyId = req.session.user.id

        await jobModel.createJob({
            jobTitle,
            jobDescription,
            salaryMin,
            salaryMax,
            location,
            employmentType,
            companyId
        })

        res.redirect('/')
    } catch (error) {
        res.render('jobs/jobCreate.ejs', { title: 'Create Job', error: error.message, user: req.session.user })
    }
}

const getJobDetails = async (req, res, next) => {
    try {
        const { jobId } = req.params
        const job = await jobModel.getJobById(jobId)

        if (!job) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'Job not found')
        }

        res.render('jobs/jobDetails.ejs', { title: job.JobTitle, job, user: req.session.user })
    } catch (error) {
        next(error)
    }
}

export const jobController = {
    getCreateJobPage,
    createJob,
    getJobDetails
}
