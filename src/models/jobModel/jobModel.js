import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import sql from 'mssql'

const createJob = async (jobData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, companyId, experienceRequired, applicationDeadline, openingCount } = jobData
        const jobResult = await pool.request()
            .input('jobTitle', jobTitle)
            .input('jobDescription', jobDescription)
            .input('salaryMin', salaryMin)
            .input('salaryMax', salaryMax)
            .input('location', location)
            .input('employmentType', employmentType)
            .input('companyId', companyId)
            .input('experienceRequired', experienceRequired)
            .input('applicationDeadline', applicationDeadline)
            .input('openingCount', openingCount)
            .query(`
                INSERT INTO [Job] ([CompanyID], [JobTitle], [JobDescription], [EmploymentType], [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], [ApplicationDeadline], [JobStatus], [PostedDate])
                VALUES (@companyId, @jobTitle, @jobDescription, @employmentType, @experienceRequired, @salaryMin, @salaryMax, @location, @openingCount, @applicationDeadline, 'Open', GETDATE());
            `)
        return null
    } catch (error) {
        console.log('Error creating job:', error)
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobById = async (jobId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT J.*, C.CompanyName, C.LogoURL, JM.ViewCount, JM.AppliedCount
                FROM [Job] J
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.JobID = @jobId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobsByCompanyId = async (companyId, page = 1, limit = 10) => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit

        // Get total count for pagination
        const countResult = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT COUNT(*) as total
                FROM [Job]
                WHERE CompanyID = @companyId
            `)
        const totalJobs = countResult.recordset[0].total
        const totalPages = Math.ceil(totalJobs / limit)

        const result = await pool.request()
            .input('companyId', companyId)
            .input('offset', offset)
            .input('limit', limit)
            .query(`
                SELECT J.*, JM.AppliedCount as Applicants, J.ApplicationDeadline as Deadline, J.JobStatus as Status
                FROM [Job] J
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.CompanyID = @companyId
                ORDER BY J.PostedDate DESC
                OFFSET @offset ROWS
                FETCH NEXT @limit ROWS ONLY
            `)

        return {
            jobs: result.recordset,
            currentPage: parseInt(page),
            totalPages,
            totalJobs
        }
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const deleteJob = async (jobId, companyId) => {
    try {
        const pool = GET_SQL_POOL()
        // Verify ownership before deleting
        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .query(`
                DELETE FROM [Job]
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }
        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateJobStatus = async (jobId, companyId, status) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .input('status', status)
            .query(`
                UPDATE [Job]
                SET JobStatus = @status
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }
        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateJob = async (jobId, companyId, jobData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, experienceRequired, applicationDeadline, openingCount } = jobData

        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .input('jobTitle', jobTitle)
            .input('jobDescription', jobDescription)
            .input('salaryMin', salaryMin)
            .input('salaryMax', salaryMax)
            .input('location', location)
            .input('employmentType', employmentType)
            .input('experienceRequired', experienceRequired)
            .input('applicationDeadline', applicationDeadline)
            .input('openingCount', openingCount)
            .query(`
                UPDATE [Job]
                SET 
                    JobTitle = @jobTitle,
                    JobDescription = @jobDescription,
                    SalaryMin = @salaryMin,
                    SalaryMax = @salaryMax,
                    Location = @location,
                    EmploymentType = @employmentType,
                    ExperienceRequired = @experienceRequired,
                    ApplicationDeadline = @applicationDeadline,
                    OpeningCount = @openingCount
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }
        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const jobModel = {
    createJob,
    getJobById,
    getJobsByCompanyId,
    deleteJob,
    updateJobStatus,
    updateJob
}
