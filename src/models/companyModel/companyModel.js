import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import sql from 'mssql'

const getCompanyProfile = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT C.*, CL.Address as CompanyAddress
                FROM [Company] C
                LEFT JOIN [CompanyLocation] CL ON C.CompanyID = CL.CompanyID
                WHERE C.CompanyID = @companyId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateCompanyProfile = async (companyId, profileData) => {
    try {
        const pool = GET_SQL_POOL()
        const { CompanyName, FounderYear, Industry, CompanySize, CompanyWebsite, CompanyAddress, CompanyDescription, LogoURL } = profileData

        const transaction = new sql.Transaction(pool)
        await transaction.begin()

        try {
            const request = new sql.Request(transaction)

            // Update Company table
            await request
                .input('companyId', companyId)
                .input('companyName', CompanyName)
                .input('founderYear', FounderYear)
                .input('industry', Industry)
                .input('companySize', CompanySize)
                .input('companyWebsite', CompanyWebsite)
                .input('companyDescription', CompanyDescription)
                .input('logoUrl', LogoURL)
                .query(`
                    UPDATE [Company]
                    SET CompanyName = @companyName,
                        FounderYear = @founderYear,
                        Industry = @industry,
                        CompanySize = @companySize,
                        CompanyWebsite = @companyWebsite,
                        CompanyDescription = @companyDescription,
                        LogoURL = @logoUrl
                    WHERE CompanyID = @companyId
                `)

            // Update or Insert CompanyLocation
            // First check if location exists
            const locationCheck = await request.query(`SELECT * FROM [CompanyLocation] WHERE CompanyID = '${companyId}'`)

            if (locationCheck.recordset.length > 0) {
                await request
                    .input('address', CompanyAddress)
                    .query(`
                        UPDATE [CompanyLocation]
                        SET Address = @address
                        WHERE CompanyID = '${companyId}'
                    `)
            } else {
                await request
                    .input('address', CompanyAddress)
                    .query(`
                        INSERT INTO [CompanyLocation] (CompanyID, Address)
                        VALUES ('${companyId}', @address)
                    `)
            }

            await transaction.commit()
            return true
        } catch (err) {
            await transaction.rollback()
            throw err
        }
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getDashboardStats = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT
                    (SELECT COUNT(*) FROM [Job] WHERE CompanyID = @companyId AND JobStatus = 'Open') as activeJobs,
                    (SELECT COUNT(*) FROM [Application] A JOIN [Job] J ON A.JobID = J.JobID WHERE J.CompanyID = @companyId) as totalApplications,
                    (SELECT ISNULL(SUM(ViewCount), 0) FROM [JobMetrics] JM JOIN [Job] J ON JM.JobMetricID = J.JobID WHERE J.CompanyID = @companyId) as totalViews,
                    (SELECT COUNT(*) FROM [Application] A JOIN [Job] J ON A.JobID = J.JobID WHERE J.CompanyID = @companyId AND A.ApplicationStatus = 'Submitted') as newCandidates
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getRecentJobs = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT TOP 5 J.JobID, J.JobTitle, J.PostedDate, J.JobStatus as Status, JM.AppliedCount as Applicants
                FROM [Job] J
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.CompanyID = @companyId
                ORDER BY J.PostedDate DESC
            `)
        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const companyModel = {
    getCompanyProfile,
    updateCompanyProfile,
    getDashboardStats,
    getRecentJobs
}
