import { jobModel } from '~/models/jobModel/jobModel.js'
import { applicationModel } from '~/models/applyModel/applicationModel'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'

const getJobDetails = async (req, res, next) => {
    try {
        const { jobId } = req.params
        const job = await jobModel.getJobById(jobId)

        if (!job) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'Job not found')
        }

        let hasApplied = false
        if (req.session && req.session.user && req.session.user.userType === 'JobSeeker') {
            try {
                hasApplied = await applicationModel.hasApplied(req.session.user.id, jobId)
            } catch (e) {
                hasApplied = false
            }
        }

        res.render('homepage/job-detail.ejs', { title: job.JobTitle, job, user: req.session.user, hasApplied })
    } catch (error) {
        res.render('homepage/job-detail.ejs', { title: 'Job Details', error: error.message, user: req.session.user, hasApplied: false })
    }
}

export const jobController = {
    getJobDetails
}
