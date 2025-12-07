import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import dayjs from 'dayjs'
import utc from 'dayjs/plugin/utc.js'
import timezone from 'dayjs/plugin/timezone.js'
import sql from 'mssql'
dayjs.extend(utc)
dayjs.extend(timezone)
import { userModel } from '~/models/authModel/userModel'

const createApplication = async (applicationData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobSeekerId, jobId } = applicationData
        let result = await pool.request()
            .input('jobSeekerId', jobSeekerId)
            .input('jobId', jobId)
            .query(`
                SELECT * FROM [Application] WHERE JobSeekerID = @jobSeekerId AND JobID = @jobId
            `)
        if (result.recordset.length > 0) {
            throw new ApiError(StatusCodes.BAD_REQUEST, 'You have already applied for this job')
        }
        let CVUrl = await pool.request()
            .input('jobSeekerId', jobSeekerId)
            .query(`
                SELECT CVFileUrl FROM [JobSeeker] WHERE JobSeekerID = @jobSeekerId
            `)
        if (!CVUrl.recordset.length > 0) {
            throw new ApiError(StatusCodes.BAD_REQUEST, 'You have not uploaded your CV')
        }
        result = await pool.request()
            .input('jobSeekerId', jobSeekerId)
            .input('jobId', jobId)
            .input('CVUrl', CVUrl.recordset[0].CVFileUrl)
            .query(`
                INSERT INTO [Application] (JobSeekerID, JobID, ApplicationDate, ApplicationStatus, isActive, CoverLetterURL)
                VALUES (@jobSeekerId, @jobId, GETDATE(), 'Submitted', 1, @CVUrl)
            `)

        try {
            const jobRes = await pool.request()
                .input('jobId', jobId)
                .query(`SELECT JobTitle, CompanyID FROM [Job] WHERE JobID = @jobId`)
            if (jobRes && jobRes.recordset && jobRes.recordset.length > 0) {
                const job = jobRes.recordset[0]
                const seekerRes = await pool.request()
                    .input('seekerId', jobSeekerId)
                    .query(`SELECT FirstName, LastName FROM [JobSeeker] WHERE JobSeekerID = @seekerId`)
                const seekerName = (seekerRes && seekerRes.recordset && seekerRes.recordset[0]) ? `${seekerRes.recordset[0].FirstName} ${seekerRes.recordset[0].LastName}` : jobSeekerId
                const content = `${seekerName} has applied to your job "${job.JobTitle || ''}".`
                await userModel.sendInAppNotification(job.CompanyID, 'Application', content)
            }
        } catch (nErr) {
        }

        try {
            const time = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss')
            await pool.request()
                .input('jobId', jobId)
                .input('time', sql.DateTime, time)
                .query(`
                    IF EXISTS (SELECT 1 FROM [JobMetrics] WHERE JobMetricID = @jobId)
                        UPDATE [JobMetrics]
                        SET AppliedCount = ISNULL(AppliedCount, 0) + 1,
                            LastUpdated = @time
                        WHERE JobMetricID = @jobId
                    ELSE
                        INSERT INTO [JobMetrics] (JobMetricID, AppliedCount, LikeCount, ViewCount, LastUpdated)
                        VALUES (@jobId, 1, 0, 0, @time)
                `)
        } catch (mErr) {
        }

        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getApplicationsBySeekerId = async (seekerId) => {
    try {
        const pool = GET_SQL_POOL()
        let result = await pool.request()
            .input('seekerId', seekerId)
            .query(`
                SELECT A.*, J.JobTitle, C.CompanyName, C.LogoURL, J.Location, J.EmploymentType
                FROM [Application] A
                JOIN [Job] J ON A.JobID = J.JobID
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                WHERE A.JobSeekerID = @seekerId
                ORDER BY A.ApplicationDate DESC
            `)
        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getCandidatesByCompanyId = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        let result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT A.*, J.JobTitle,
                       (JS.FirstName + ' ' + JS.LastName) as SeekerName,
                       U.Email as SeekerEmail, U.avatarURL as SeekerAvatar
                FROM [Application] A
                JOIN [Job] J ON A.JobID = J.JobID
                JOIN [JobSeeker] JS ON A.JobSeekerID = JS.JobSeekerID
                JOIN [User] U ON JS.JobSeekerID = U.UserID
                WHERE J.CompanyID = @companyId
                ORDER BY A.ApplicationDate DESC
            `)
        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getApplicationById = async (applicationId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('applicationId', applicationId)
            .query(`
                  SELECT A.ApplicationID, A.JobSeekerID, A.JobID, A.ApplicationDate, A.ApplicationStatus, A.CoverLetterURL,
                      J.JobTitle,
                      JS.FirstName, JS.LastName, JS.PhoneNumber, JS.CurrentLocation, JS.CVFileURL, JS.ProfileSummary,
                      U.Email as SeekerEmail, U.avatarURL as AvatarURL
                FROM [Application] A
                JOIN [Job] J ON A.JobID = J.JobID
                JOIN [JobSeeker] JS ON A.JobSeekerID = JS.JobSeekerID
                LEFT JOIN [User] U ON JS.JobSeekerID = U.UserID
                WHERE A.ApplicationID = @applicationId
            `)

        if (!result.recordset || result.recordset.length === 0) return null

        const app = result.recordset[0]

        // get skills
        const skillsRes = await pool.request()
            .input('seekerId', app.JobSeekerID)
            .query(`
                SELECT S.SkillName FROM [JobSeekerSkill] JSS
                JOIN [Skill] S ON JSS.SkillID = S.SkillID
                WHERE JSS.JobSeekerID = @seekerId
            `)

        app.SeekerName = `${app.FirstName} ${app.LastName}`
        app.SeekerSkills = skillsRes.recordset.map(r => r.SkillName)
        // Prefer the user's avatarURL if available; fall back to a sensible default
        app.SeekerAvatar = app.AvatarURL || '/images/default-avatar.png'
        app.CVUrl = app.CVFileURL

        return app
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateApplicationStatus = async (applicationId, status) => {
    try {
        const pool = GET_SQL_POOL()
        let result = await pool.request()
            .input('applicationId', applicationId)
            .input('status', status)
            .query(`
                UPDATE [Application]
                SET ApplicationStatus = @status
                WHERE ApplicationID = @applicationId
            `)

        // send notification to job seeker about status change
        try {
            const appRes = await pool.request()
                .input('applicationId', applicationId)
                .query(`SELECT JobSeekerID, JobID FROM [Application] WHERE ApplicationID = @applicationId`)
            if (appRes && appRes.recordset && appRes.recordset.length > 0) {
                const app = appRes.recordset[0]
                const jobRes = await pool.request()
                    .input('jobId', app.JobID)
                    .query(`SELECT JobTitle FROM [Job] WHERE JobID = @jobId`)
                const jobTitle = (jobRes && jobRes.recordset && jobRes.recordset[0]) ? jobRes.recordset[0].JobTitle : ''
                let notifType = 'Application'
                if (status === 'Interview') notifType = 'Interview'
                else if (status === 'Offered' || status === 'Offer') notifType = 'Offer'
                else if (status === 'Rejected') notifType = 'Rejection'
                const content = `Your application for "${jobTitle}" is now: ${status}`
                await userModel.sendInAppNotification(app.JobSeekerID, notifType, content)
            }
        } catch (nErr) {
        }
        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const hasApplied = async (seekerId, jobId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('seekerId', seekerId)
            .input('jobId', jobId)
            .query(`SELECT 1 AS Applied FROM [Application] WHERE JobSeekerID = @seekerId AND JobID = @jobId`)
        return result.recordset.length > 0
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const applicationModel = {
    createApplication,
    getApplicationsBySeekerId,
    getCandidatesByCompanyId,
    getApplicationById,
    updateApplicationStatus
    ,hasApplied
}
