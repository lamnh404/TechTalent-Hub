import { GET_MYSQL_CONNECTION } from '~/config/mysqlDatabase'
import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'
import { compare } from 'bcryptjs'
import { pickUserFields } from '~/utils/formatters'


const login = async(email, password) => {
    try {
        const connection = await GET_MYSQL_CONNECTION()
        const [rows] = await connection.execute(
            'SELECT * FROM User WHERE email = ? AND accountStatus = ?',
            [email, 'active']
        )
        if (rows.length === 0) {
            throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
        }
        const user = rows[0]

        const isPasswordValid = await compare(password, user.PasswordHash)

        if (!isPasswordValid) {
            throw new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid password')
        }

        return pickUserFields(user)


    } catch (error) {
        console.error('error during login:', error)
        throw error
    }
}

export const authModel = {
    login
}