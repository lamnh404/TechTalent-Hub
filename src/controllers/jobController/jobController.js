import { jobModel } from '~/models/jobModel/jobModel.js'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getJobDetails = async (req, res, next) => {
    try {
        const { jobId } = req.params
        const job = await jobModel.getJobById(jobId)

        if (!job) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'Job not found')
        }

        res.render('homepage/job-detail.ejs', { title: job.JobTitle, job, user: req.session.user })
    } catch (error) {
        res.render('homepage/job-detail.ejs', { title: 'Job Details', error: error.message, user: req.session.user })
    }
}

export const jobController = {
    getJobDetails
}
