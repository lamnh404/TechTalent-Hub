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
                SELECT userId, email, passwordHash, userType
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
            throw new ApiError(StatusCodes.CONFLICT, 'Email already exists')
        }

        const passwordHash = await hash(password, 12)

        return { email, passwordHash, role }
    } catch (error) {
        throw new Error(error)
    }
}

const setupCompany = async (userData, profileData) => {
    const {email, passwordHash, role} = userData
    try {
        const pool = GET_SQL_POOL()

        const { CompanyName, Industry, CompanySize, CompanyWebsite, FoundedYear, LogoURL, CompanyDescription, CompanyAddress } = profileData

        const userResult = await pool.request()
            .input('email', email)
            .input('passwordHash', passwordHash)
            .input('userType', role)
            .query(`
                INSERT INTO [User] (Email, PasswordHash, UserType, AccountStatus, RegistrationDate)
                VALUES (@email, @passwordHash, @userType, 'Active', GETDATE())
            `)

        const regUser = await pool.request()
            .input('email', email)
            .query('SELECT userId FROM [User] WHERE email = @email')

        const userId = regUser.recordset[0].userId

        await pool.request()
            .input('userId', userId)
            .input('companyName', CompanyName)
            .input('industry', Industry)
            .input('size', CompanySize)
            .input('website', CompanyWebsite)
            .input('foundedYear', FoundedYear)
            .input('logoUrl', LogoURL)
            .input('description', CompanyDescription || '')
            .query(`
                INSERT INTO [Company] (CompanyID, CompanyName, Industry, CompanySize, CompanyWebsite, FoundedYear, LogoURL, CompanyDescription, VerificationStatus)
                VALUES (@userId, @companyName, @industry, @size, @website, @foundedYear, @logoUrl, @description, 'PENDING')
            `)

        if (CompanyAddress) {
            await pool.request()
                .input('companyId', userId)
                .input('address', CompanyAddress)
                .query(`
                    MERGE INTO [CompanyLocation] AS Target
                    USING (VALUES (@companyId, @address)) AS Source (CompanyID, Address)
                    ON Target.CompanyID = Source.CompanyID
                    WHEN MATCHED THEN
                        UPDATE SET Address = Source.Address
                    WHEN NOT MATCHED THEN
                        INSERT (CompanyID, Address) VALUES (Source.CompanyID, Source.Address);
                `)
        }

        return { userId, ...userData }
    } catch (error) {
        const pool = GET_SQL_POOL()
        try {
            await pool.request()
                .input('email', email)
                .query('DELETE FROM [User] WHERE email = @email')
        }
        catch (error) {
            console.log(error)
        }
        throw new Error(error)
    }
}

const setupSeeker = async (userData, profileData) => {
    const {email, passwordHash, role} = userData
    try {
        const pool = GET_SQL_POOL()

        const { FirstName, LastName, PhoneNumber, Gender, DateOfBirth, title, ExperienceLevel, CurrentLocation, skills, CVFileURL, summary } = profileData

        const userResult = await pool.request()
            .input('email', email)
            .input('passwordHash', passwordHash)
            .input('userType', role)
            .query(`
                INSERT INTO [User] (Email, PasswordHash, UserType, AccountStatus, RegistrationDate)
                VALUES (@email, @passwordHash, @userType, 'Active', GETDATE())
            `)

        const regUser = await pool.request()
            .input('email', email)
            .query('SELECT userId FROM [User] WHERE email = @email')

        const userId = regUser.recordset[0].userId

        await pool.request()
            .input('userId', userId)
            .input('firstName', FirstName)
            .input('lastName', LastName)
            .input('phoneNumber', PhoneNumber)
            .input('gender', Gender)
            .input('dateOfBirth', DateOfBirth)
            .input('professionalTitle', title || '')
            .input('experienceLevel', ExperienceLevel)
            .input('currentLocation', CurrentLocation)
            .input('cvUrl', CVFileURL)
            .query(`
                INSERT INTO [JobSeeker] (
                    JobSeekerID, FirstName, LastName, PhoneNumber, Gender, DateOfBirth, 
                    ExperienceLevel, CurrentLocation, CVFileURL, ProfileSummary
                )
                VALUES (
                    @userId, @firstName, @lastName, @phoneNumber, @gender, @dateOfBirth, 
                    @experienceLevel, @currentLocation, @cvUrl, @professionalTitle
                )
            `)

        return { userId, ...userData }
    } catch (error) {
        const pool = GET_SQL_POOL()
        try {
            await pool.request()
                .input('email', email)
                .query('DELETE FROM [User] WHERE email = @email')
        } catch (error) {
            console.log(error)
        }
        throw new Error(error)
    }
}

export const authModel = {
    login,
    register,
    setupCompany,
    setupSeeker
}

authModel.changePassword = async (userId, currentPassword, newPassword) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('userId', userId)
            .query('SELECT userId, PasswordHash FROM [User] WHERE userId = @userId')

        const user = result.recordset[0]
        if (!user) throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')

        const isMatch = await compare(currentPassword, user.PasswordHash)
        if (!isMatch) throw new ApiError(StatusCodes.UNAUTHORIZED, 'Current password is incorrect')

        const newHash = await hash(newPassword, 12)
        await pool.request()
            .input('userId', userId)
            .input('passwordHash', newHash)
            .query('UPDATE [User] SET PasswordHash = @passwordHash WHERE userId = @userId')

        return true
    } catch (err) {
        if (err instanceof ApiError) throw err
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}