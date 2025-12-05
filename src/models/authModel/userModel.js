// User model schema and validation will be added here in the future
import { GET_SQL_POOL } from '~/config/SQLDatabase'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const getRole = async (userId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('userId', userId)
            .query(`
                SELECT UserType
                FROM [User]
                WHERE UserID = @userId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const userModel = {
    getRole
}
