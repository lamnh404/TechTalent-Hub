import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const createApplication = async (applicationData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobSeekerId, jobId } = applicationData

        const result = await pool.request()
            .input('jobSeekerId', jobSeekerId)
            .input('jobId', jobId)
            .query(`
                INSERT INTO [Application] (JobSeekerID, JobID, ApplicationDate, ApplicationStatus, isActive)
                VALUES (@jobSeekerId, @jobId, GETDATE(), 'Submitted', 1)
            `)

        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getApplicationsBySeekerId = async (seekerId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
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
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT A.*, J.JobTitle, (JS.FirstName + ' ' + JS.LastName) as SeekerName, U.Email as SeekerEmail, U.AvatarURL as SeekerAvatar
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

const updateApplicationStatus = async (applicationId, status) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('applicationId', applicationId)
            .input('status', status)
            .query(`
                UPDATE [Application]
                SET ApplicationStatus = @status
                WHERE ApplicationID = @applicationId
            `)
        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const applicationModel = {
    createApplication,
    getApplicationsBySeekerId,
    getCandidatesByCompanyId,
    updateApplicationStatus
}
