import { StatusCodes } from 'http-status-codes'
import { ApiError } from '~/utils/ApiError'
import { hash } from 'bcryptjs'
import { pickUserFields } from '~/utils/formatters'
import { GET_SQL_POOL } from '~/config/SQLDatabase.js'

const register = async (email, password, role, extraData) => {
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
            const { companyName, companySize, industry, description, website, logoUrl, address } = extraData

            await pool.request()
                .input('companyId', newUserId)
                .input('companyName', companyName)
                .input('founderYear', extraData.founderYear || null)
                .input('companySize', companySize || null)
                .input('industry', industry || null)
                .input('description', description || null)
                .input('website', website || null)
                .input('logoUrl', logoUrl || null)
                .query(`
          INSERT INTO [Company] (CompanyID, CompanyName, FounderYear, CompanySize, Industry, CompanyDescription, CompanyWebsite, VerificationStatus, LogoURL)
          VALUES (@companyId, @companyName, @founderYear, @companySize, @industry, @description, @website, 'PENDING', @logoUrl)
        `)

            if (address) {
                await pool.request()
                    .input('companyId', newUserId)
                    .input('address', address)
                    .query(`
            INSERT INTO [CompanyLocation] (CompanyID, Address)
            VALUES (@companyId, @address)
          `)
            }

        } else if (role === 'JobSeeker') {
            const { firstName, lastName, phoneNumber, gender, dateOfBirth, currentLocation, experienceLevel, profileSummary, cvFileUrl } = extraData

            await pool.request()
                .input('jobSeekerId', newUserId)
                .input('firstName', firstName)
                .input('lastName', lastName)
                .input('phoneNumber', phoneNumber || null)
                .input('gender', gender || null)
                .input('dateOfBirth', dateOfBirth || null)
                .input('currentLocation', currentLocation || null)
                .input('experienceLevel', experienceLevel || null)
                .input('profileSummary', profileSummary || null)
                .input('cvFileUrl', cvFileUrl || null)
                .query(`
          INSERT INTO [JobSeeker] (JobSeekerID, FirstName, LastName, PhoneNumber, Gender, DateOfBirth, CurrentLocation, ExperienceLevel, ProfileSummary, CVFileURL)
          VALUES (@jobSeekerId, @firstName, @lastName, @phoneNumber, @gender, @dateOfBirth, @currentLocation, @experienceLevel, @profileSummary, @cvFileUrl)
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