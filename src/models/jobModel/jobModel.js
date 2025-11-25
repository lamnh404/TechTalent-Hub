import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const createJob = async (jobData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, companyId } = jobData

        const result = await pool.request()
            .input('jobTitle', jobTitle)
            .input('jobDescription', jobDescription)
            .input('salaryMin', salaryMin)
            .input('salaryMax', salaryMax)
            .input('location', location)
            .input('employmentType', employmentType)
            .input('companyId', companyId)
            .query(`
                INSERT INTO [Job] (JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, PostedDate, CompanyID)
                VALUES (@jobTitle, @jobDescription, @salaryMin, @salaryMax, @location, @employmentType, GETDATE(), @companyId)
            `)

        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobById = async (jobId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT J.*, C.CompanyName, C.LogoURL
                FROM [Job] J
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                WHERE J.JobID = @jobId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobsByCompanyId = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT *
                FROM [Job]
                WHERE CompanyID = @companyId
                ORDER BY PostedDate DESC
            `)
        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const jobModel = {
    createJob,
    getJobById,
    getJobsByCompanyId
}
