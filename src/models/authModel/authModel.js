import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'
import { compare, hash } from 'bcryptjs'
import { pickUserFields } from '~/utils/formatters'
import { GET_SQL_POOL } from '~/config/SQLDatabase.js'

const login = async (email, password) => {
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
            throw new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid email or password')
        }
        const isPasswordValid = await compare(password, user.passwordHash)

        if (!isPasswordValid) {
            throw new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid email or password')
        }
        return pickUserFields(user)
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const register = async (email, password, role) => {
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
        VALUES (@email, @passwordHash, @userType, 'Disabled', GETDATE())
      `)

        const userResult = await pool.request()
            .input('email', email)
            .query(`
            SELECT userId, email, passwordHash, userType, avatarUrl 
            FROM [User] 
            WHERE email = @email`)
        const newUser = userResult.recordset[0]

        return pickUserFields(newUser)
    } catch (error) {
        throw new Error(error)
    }
}

const deleteMail = async (email) => {
    const pool = GET_SQL_POOL()
    await pool.request()
        .input('email', email)
        .query('DELETE FROM [User] WHERE Email = @email')
}

const setupCompany = async (userId, data) => {
    const pool = GET_SQL_POOL()
    try {
        const { companyName, industry, size, website, foundedYear, logoUrl, description } = data

        await pool.request()
            .input('userId', userId)
            .input('companyName', companyName)
            .input('industry', industry)
            .input('size', size)
            .input('website', website)
            .input('foundedYear', foundedYear)
            .input('logoUrl', logoUrl)
            .input('description', description || '')
            .query(`
                INSERT INTO [Company] (CompanyID, CompanyName, Industry, CompanySize, CompanyWebsite, FounderYear, LogoURL, CompanyDescription, VerificationStatus)
                VALUES (@userId, @companyName, @industry, @size, @website, @foundedYear, @logoUrl, @description, 'PENDING')
            `)

        await pool.request()
            .input('userId', userId)
            .query('UPDATE [User] SET AccountStatus = \'Active\' WHERE UserId = @userId')

        return { message: 'Company setup successful' }
    } catch (error) {
        // Rollback: Delete the user if setup fails
        try {
            await pool.request()
                .input('userId', userId)
                .query('DELETE FROM [User] WHERE UserId = @userId')
        } catch (deleteError) {
            console.error('Failed to rollback user creation:', deleteError)
        }
        throw new Error(error)
    }
}

const setupSeeker = async (userId, data) => {
    const pool = GET_SQL_POOL()
    try {
        const { firstName, lastName, experienceLevel, location, cvUrl, summary } = data

        await pool.request()
            .input('userId', userId)
            .input('firstName', firstName)
            .input('lastName', lastName)
            .input('experienceLevel', experienceLevel)
            .input('location', location)
            .input('cvUrl', cvUrl)
            .input('summary', summary || '')
            .query(`
                INSERT INTO [JobSeeker] (JobSeekerID, FirstName, LastName, ExperienceLevel, CurrentLocation, CVFileURL, ProfileSummary)
                VALUES (@userId, @firstName, @lastName, @experienceLevel, @location, @cvUrl, @summary)
            `)

        await pool.request()
            .input('userId', userId)
            .query('UPDATE [User] SET AccountStatus = \'Active\' WHERE UserId = @userId')

        return { message: 'JobSeeker setup successful' }
    } catch (error) {
        // Rollback: Delete the user if setup fails
        try {
            await pool.request()
                .input('userId', userId)
                .query('DELETE FROM [User] WHERE UserId = @userId')
        } catch (deleteError) {
            console.error('Failed to rollback user creation:', deleteError)
        }
        throw new Error(error)
    }
}

export const authModel = {
    login,
    register,
    setupCompany,
    setupSeeker,
    deleteMail
}