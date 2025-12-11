import { GET_SQL_POOL } from '~/config/SQLDatabase'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const getAdminStats = async () => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .query(`
                SELECT
                    (SELECT COUNT(1) FROM [User] WHERE UserType = 'JobSeeker') AS TotalJobSeekers,
                    (SELECT COUNT(1) FROM [User] WHERE UserType = 'Company') AS TotalCompanies,
                    (SELECT COUNT(1) FROM [Job] WHERE JobStatus = 'Open') AS ActiveJobs,
                    (SELECT COUNT(1) FROM [ReviewCompany] WHERE VerificationStatus = 'Pending') AS NewReports
            `)
        return result.recordset && result.recordset[0] ? {
            totalUsers: (result.recordset[0].TotalJobSeekers || 0) + 0,
            totalCompanies: result.recordset[0].TotalCompanies || 0,
            activeJobs: result.recordset[0].ActiveJobs || 0,
            newReports: result.recordset[0].NewReports || 0
        } : { totalUsers: 0, totalCompanies: 0, activeJobs: 0, newReports: 0 }
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getRecentActivities = async (limit = 10) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('limit', limit)
            .query(`
                SELECT TOP (@limit)
                    'Job' AS ActivityType,
                    J.CompanyID AS Actor,
                    C.CompanyName AS ActorName,
                    'Posted a new job' AS Action,
                    J.JobTitle AS Target,
                    J.PostedDate AS Time,
                    'briefcase' AS Icon,
                    'primary' AS Color
                FROM [Job] J
                LEFT JOIN [Company] C ON J.CompanyID = C.CompanyID
                ORDER BY J.PostedDate DESC
            `)

        return (result.recordset || []).map(r => ({
            id: r.JobID || Math.floor(Math.random() * 100000),
            user: r.ActorName || r.Actor || 'System',
            action: r.Action || 'Activity',
            target: r.Target || '',
            time: r.Time ? new Date(r.Time).toLocaleString() : '',
            icon: r.Icon || 'bell',
            color: r.Color || 'secondary'
        }))
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getAllUsers = async (page = 1, limit = 50, search = '') => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit
        const request = pool.request()
            .input('limit', limit)
            .input('offset', offset)

        let where = ''
        if (search && search.trim().length > 0) {
            request.input('search', `%${search}%`)
            where = "WHERE U.Email LIKE @search OR JS.FirstName LIKE @search OR JS.LastName LIKE @search OR C.CompanyName LIKE @search"
        }

        const result = await request.query(`
            SELECT U.UserId, U.Email, U.avatarURL AS avatar, U.RegistrationDate AS joinDate, U.AccountStatus AS status, U.UserType AS role,
                   COALESCE(NULLIF(CONCAT(JS.FirstName, ' ', JS.LastName), ' '), C.CompanyName, U.Email) AS name
            FROM [User] U
            LEFT JOIN [JobSeeker] JS ON U.UserId = JS.JobSeekerID
            LEFT JOIN [Company] C ON U.UserId = C.CompanyID
            ${where}
            ORDER BY U.RegistrationDate DESC
            OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY
        `)

        return result.recordset || []
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getAllJobs = async (page = 1, limit = 50, search = '') => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit
        const request = pool.request()
            .input('limit', limit)
            .input('offset', offset)

        let where = ''
        if (search && search.trim().length > 0) {
            request.input('search', `%${search}%`)
            where = "WHERE J.JobTitle LIKE @search OR C.CompanyName LIKE @search"
        }

        const result = await request.query(`
            SELECT J.JobID AS id, J.JobTitle AS title, C.CompanyName AS company, C.CompanyName AS postedBy, J.PostedDate AS postedDate, J.JobStatus AS status,
                   0 AS reports
            FROM [Job] J
            LEFT JOIN [Company] C ON J.CompanyID = C.CompanyID
            ${where}
            ORDER BY J.PostedDate DESC
            OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY
        `)

        return (result.recordset || []).map(r => ({
            id: r.id,
            title: r.title,
            company: r.company,
            postedBy: r.postedBy,
            postedDate: r.postedDate,
            status: r.status,
            reports: r.reports || 0
        }))
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const adminModel = {
    getAdminStats,
    getRecentActivities,
    getAllUsers,
    getAllJobs
}
