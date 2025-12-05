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
        // Basic recent activities: job posts, new users, system notifications (best-effort)
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

        // Map to view-friendly shape. If no rows, return empty array.
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

export const adminModel = {
    getAdminStats,
    getRecentActivities
}
