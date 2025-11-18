import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'
import { compare } from 'bcryptjs'
import { pickUserFields } from '~/utils/formatters'
import {GET_SQL_POOL} from '~/config/SQLDatabase.js'

const login = async(email, password) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('email', email)
            .query(`
                SELECT userId, email, passwordHash, userType, avatarUrl 
                FROM [User] 
                WHERE email = @email`)
        const user = result.recordset[0]

        if (!user) {
            throw new ApiError('Invalid email or password', StatusCodes.UNAUTHORIZED)
        }
        const isPasswordValid =  await compare(password, user.passwordHash)

        if (!isPasswordValid) {
            throw new ApiError('Invalid email or password', StatusCodes.UNAUTHORIZED)
        }

        return pickUserFields(user)
    } catch (error) {
        throw new Error(error)
    }
}

export const authModel = {
    login
}