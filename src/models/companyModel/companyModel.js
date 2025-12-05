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
        const { CompanyName, FoundedYear, Industry, CompanySize, CompanyWebsite, CompanyAddress, CompanyDescription, LogoURL } = profileData
        await pool.request()
            .input('companyId', companyId)
            .input('companyName', CompanyName)
            .input('foundedYear', FoundedYear)
            .input('industry', Industry)
            .input('companySize', CompanySize)
            .input('companyWebsite', CompanyWebsite)
            .input('companyDescription', CompanyDescription)
            .input('logoUrl', LogoURL)
            .query(`
                UPDATE [Company]
                SET CompanyName = @companyName,
                    FoundedYear = @foundedYear,
                    Industry = @industry,
                    CompanySize = @companySize,
                    CompanyWebsite = @companyWebsite,
                    CompanyDescription = @companyDescription,
                    LogoURL = @logoUrl
                WHERE CompanyID = @companyId
            `)
        await pool.request()
            .input('companyId', companyId)
            .query(`DELETE FROM [CompanyLocation] WHERE CompanyID = @companyId`)

        if (CompanyAddress && String(CompanyAddress).trim() !== '') {
            await pool.request()
                .input('companyId', companyId)
                .input('address', CompanyAddress)
                .query(`INSERT INTO [CompanyLocation] (CompanyID, Address) VALUES (@companyId, @address)`)
        }

        return true
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
                    (SELECT COUNT(*) FROM [Application] A JOIN [Job] J ON A.JobID = J.JobID WHERE J.CompanyID = @companyId AND A.ApplicationStatus = 'Submitted') as newCandidates,
                    (SELECT COUNT(*) FROM [Job] WHERE CompanyID = @companyId AND PostedDate >= DATEADD(MONTH, -1, GETDATE())) as newJobsThisMonth
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

const addCompanyReview = async (companyId, jobSeekerId, title, content, rating, isAnonymous = 1) => {
    try {
        const pool = GET_SQL_POOL()
        const request = pool.request()
            .input('companyId', companyId)
            .input('jobSeekerId', jobSeekerId)
            .input('title', title)
            .input('content', content)
            .input('rating', rating)
            .input('isAnonymous', isAnonymous)

        const result = await request.query(`
            INSERT INTO [ReviewCompany] (JobSeekerID, CompanyID, ReviewTitle, ReviewDate, ReviewText, Rating, VerificationStatus, IsAnonymous)
            VALUES (@jobSeekerId, @companyId, @title, GETDATE(), @content, @rating, 'Pending', @isAnonymous);
        `)
        return result
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getCompanyReviews = async (companyId, limit = 20) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .input('limit', sql.Int, limit)
            .query(`
                SELECT TOP (@limit) R.ReviewID, R.ReviewTitle, R.ReviewText, R.Rating, R.ReviewDate, R.IsAnonymous,
                       JS.FirstName, JS.LastName, JS.CVFileURL, U.Email
                FROM [ReviewCompany] R
                LEFT JOIN [JobSeeker] JS ON R.JobSeekerID = JS.JobSeekerID
                LEFT JOIN [User] U ON JS.JobSeekerID = U.UserID
                WHERE R.CompanyID = @companyId AND R.VerificationStatus = 'Verified'
                ORDER BY R.ReviewDate DESC
            `)
        return result.recordset.map(r => ({
            ReviewID: r.ReviewID,
            ReviewerName: r.IsAnonymous ? 'Anonymous' : ((r.FirstName || '') + ' ' + (r.LastName || '')).trim(),
            ReviewerAvatar: r.CVFileURL || '/images/default-avatar.png',
            ReviewDate: r.ReviewDate,
            Rating: r.Rating,
            ReviewTitle: r.ReviewTitle,
            ReviewText: r.ReviewText
        }))
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getCompanies = async (search = '', page = 1, limit = 20) => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit
        const request = pool.request()
            .input('limit', sql.Int, limit)
            .input('offset', sql.Int, offset)
        let where = ''
        if (search && search.trim().length > 0) {
            request.input('search', sql.NVarChar, `%${search}%`)
            where = "WHERE CompanyName LIKE @search OR Industry LIKE @search"
        }
        const result = await request.query(`
            SELECT C.CompanyID, C.CompanyName, C.LogoURL, C.Industry, C.CompanySize
            FROM [Company] C
            ${where}
            ORDER BY C.CompanyName
            OFFSET @offset ROWS
            FETCH NEXT @limit ROWS ONLY
        `)
        return result.recordset || []
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getApplicationStatisticsByCompany = async (companyId, startDate = null, endDate = null) => {
    try {
        const pool = GET_SQL_POOL()
        const request = pool.request()
        // use proper SQL types; accept null to let proc use defaults
        request.input('p_StartDate', sql.DateTime, startDate || null)
        request.input('p_EndDate', sql.DateTime, endDate || null)

        const result = await request.execute('dbo.sp_GetApplicationStatisticsByCompany')

        const rows = result.recordset || []
        // stored proc returns aggregated rows for companies with applications in range
        const match = rows.find(r => String(r.CompanyID) === String(companyId))
        // if no row found, return null to indicate no applications in the range
        return match || null
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const companyModel = {
    getCompanyProfile,
    updateCompanyProfile,
    getDashboardStats,
    getRecentJobs
    ,getApplicationStatisticsByCompany
    ,getCompanies
    ,addCompanyReview
    ,getCompanyReviews
}
