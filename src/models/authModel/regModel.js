import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'
import { hash } from 'bcryptjs'
import { pickUserFields } from '~/utils/formatters'
import { GET_SQL_POOL } from '~/config/SQLDatabase.js'

const register = async (name, email, password, role) => {
    try {
        const pool = GET_SQL_POOL()

        const existingUser = await pool.request()
            .input('email', email)
            .query('SELECT userId FROM [User] WHERE email = @email')

        if (existingUser.recordset.length > 0) {
            throw new ApiError('Email already exists', StatusCodes.CONFLICT)
        }

        const passwordHash = await hash(password, 12)
        await pool.request()
            .input('email', email)
            .input('passwordHash', passwordHash)
            .input('userType', role)
            .query(`
        INSERT INTO [User] (Email, PasswordHash, UserType, AccountStatus, RegistrationDate)
        VALUES (@email, @passwordHash, @userType, 'Active', GETDATE())
      `)

        const userResult = await pool.request()
            .input('email', email)
            .query('SELECT * FROM [User] WHERE email = @email')

        const newUser = userResult.recordset[0]
        const newUserId = newUser.UserId

        if (role === 'Company') {
            await pool.request()
                .input('companyId', newUserId)
                .input('companyName', name)
                .query(`
          INSERT INTO [Company] (CompanyID, CompanyName, VerificationStatus)
          VALUES (@companyId, @companyName, 'PENDING')
        `)

        } else if (role === 'JobSeeker') {
            const nameParts = name.trim().split(/\s+/)
            const firstName = nameParts[0]
            const lastName = nameParts.slice(1).join(' ') || ''

            await pool.request()
                .input('jobSeekerId', newUserId)
                .input('firstName', firstName)
                .input('lastName', lastName)
                .query(`
          INSERT INTO [JobSeeker] (JobSeekerID, FirstName, LastName)
          VALUES (@jobSeekerId, @firstName, @lastName)
        `)
        }

        return pickUserFields(newUser)

    } catch (error) {
        throw new Error(error)
    }
}

export const regModel = {
    register
}