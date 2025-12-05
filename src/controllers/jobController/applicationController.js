import { StatusCodes } from 'http-status-codes'
import { applicationModel } from '~/models/applyModel/applicationModel'
import { jobModel } from '~/models/jobModel/jobModel'

const createApplication = async (req, res, next) => {
    try {
        const { jobId } = req.body
        const user = req.session.user

        if (!user || user.userType !== 'JobSeeker') {
            return res.redirect('/login')
        }

        await applicationModel.createApplication({
            jobSeekerId: user.id,
            jobId: jobId
        })

        res.redirect('/seeker/applications')
    } catch (error) {
        try {
            const job = await jobModel.getJobById(req.body.jobId)
            if (!job) {
                return res.redirect(`/jobs?error=${encodeURIComponent(error.message)}`)
            }
            return res.render('homepage/job-detail.ejs', { title: job.JobTitle || 'Job Details', job, user: req.session.user, error: error.message })
        } catch (e) {
            return res.redirect(`/jobs/${req.body.jobId}?error=${encodeURIComponent(error.message)}`)
        }
    }
}

const getSeekerApplications = async (req, res, next) => {
    try {
        const user = req.session.user

        if (!user || user.userType !== 'JobSeeker') {
            return res.redirect('/login')
        }

        const applications = await applicationModel.getApplicationsBySeekerId(user.id)

        res.render('seeker/my-applications.ejs', {
            applications,
            title: 'My Applications',
            user: user
        })
    } catch (error) {
        next(error)
    }
}

const getCompanyCandidates = async (req, res, next) => {
    try {
        const user = req.session.user

        if (!user || user.userType !== 'Company') {
            return res.redirect('/login')
        }

        const candidates = await applicationModel.getCandidatesByCompanyId(user.id)

        res.render('company/candidates', {
            candidates,
            title: 'Candidates',
            user: user
        })
    } catch (error) {
        next(error)
    }
}

const updateStatus = async (req, res, next) => {
    try {
        const { applicationId } = req.params
        const { status } = req.body
        const user = req.session.user

        if (!user || user.userType !== 'Company') {
            return res.status(StatusCodes.FORBIDDEN).json({ message: 'Unauthorized' })
        }

        await applicationModel.updateApplicationStatus(applicationId, status)

        res.status(StatusCodes.OK).json({ message: 'Status updated successfully' })
    } catch (error) {
        next(error)
    }
}

export const applicationController = {
    createApplication,
    getSeekerApplications,
    getCompanyCandidates,
    updateStatus
}
