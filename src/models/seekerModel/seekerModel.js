import sql from 'mssql'
import { GET_SQL_POOL } from '~/config/SQLDatabase'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const getProfile = async (userId) => {
    try {
        const pool = GET_SQL_POOL()

        const seekerResult = await pool.request()
            .input('UserId', userId)
            .query(`
                SELECT 
                    js.JobSeekerID,
                    js.FirstName,
                    js.LastName,
                    js.PhoneNumber,
                    js.CurrentLocation,
                    js.Gender,
                    js.DateOfBirth,
                    js.ExperienceLevel,
                    js.ProfileSummary,
                    js.CVFileURL,
                    u.Email,
                    u.avatarURL,
                    u.UserType
                FROM [JobSeeker] js
                JOIN [User] u ON js.JobSeekerID = u.UserId
                WHERE js.JobSeekerID = @UserId
            `)

        if (seekerResult.recordset.length === 0) {
            return null
        }

        const seeker = seekerResult.recordset[0]

        const skillsResult = await pool.request()
            .input('JobSeekerID', sql.NVarChar, userId)
            .query(`
                SELECT 
                    s.SkillID,
                    s.SkillName,
                    jss.ProficiencyLevel,
                    jss.YearOfExperience,
                    s.PopularityScore
                FROM [JobSeekerSkill] jss
                JOIN [Skill] s ON jss.SkillID = s.SkillID
                WHERE jss.JobSeekerID = @JobSeekerID
            `)

        seeker.Skills = skillsResult.recordset

        return seeker
    } catch (err) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

const updateProfile = async (userId, profileData) => {
    try {
        const pool = GET_SQL_POOL()

        await pool.request()
            .input('JobSeekerID', userId)
            .input('FirstName', profileData.FirstName)
            .input('LastName', profileData.LastName)
            .input('PhoneNumber', profileData.PhoneNumber)
            .input('CurrentLocation', profileData.CurrentLocation)
            .input('ProfileSummary', profileData.ProfileSummary)
            .input('ExperienceLevel', profileData.ExperienceLevel || null)
            .input('DateOfBirth', profileData.DateOfBirth || null)
            .query(`
                UPDATE [JobSeeker]
                SET 
                    FirstName = @FirstName,
                    LastName = @LastName,
                    PhoneNumber = @PhoneNumber,
                    CurrentLocation = @CurrentLocation,
                    ProfileSummary = @ProfileSummary,
                    ExperienceLevel = @ExperienceLevel,
                    DateOfBirth = @DateOfBirth
                WHERE JobSeekerID = @JobSeekerID
            `)

        return true
    } catch (err) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

// updateDateOfBirth removed — DateOfBirth is updated via updateProfile

const updateSkills = async (userId, skills) => {
    const pool = GET_SQL_POOL()
    const transaction = new sql.Transaction(pool)

    try {
        await transaction.begin()

        await transaction.request()
            .input('JobSeekerID', userId)
            .query(`DELETE FROM [JobSeekerSkill] WHERE JobSeekerID = @JobSeekerID`)
        if (skills && skills.length > 0) {
            for (const skill of skills) {
                let skillId = skill.SkillID

                if (!skillId) {
                    const skillCheck = await transaction.request()
                        .input('SkillName', sql.NVarChar, skill.SkillName)
                        .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

                    if (skillCheck.recordset.length > 0) {
                        skillId = skillCheck.recordset[0].SkillID
                    } else {
                        const createSkill = await transaction.request()
                            .input('SkillName', sql.NVarChar, skill.SkillName)
                            .query(`
                                INSERT INTO [Skill] (SkillName, PopularityScore) 
                                OUTPUT INSERTED.SkillID
                                VALUES (@SkillName, 0)
                            `)
                        skillId = createSkill.recordset[0].SkillID
                    }
                }

                await transaction.request()
                    .input('JobSeekerID', userId)
                    .input('SkillID', skillId)
                    .input('ProficiencyLevel', skill.ProficiencyLevel)
                    .input('YearOfExperience', skill.YearOfExperience)
                    .query(`
                        INSERT INTO [JobSeekerSkill] (JobSeekerID, SkillID, ProficiencyLevel, YearOfExperience)
                        VALUES (@JobSeekerID, @SkillID, @ProficiencyLevel, @YearOfExperience)
                    `)
            }
        }

        await transaction.commit()
        return true
    } catch (err) {
        await transaction.rollback()
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

const getSkills = async (userId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('JobSeekerID', sql.NVarChar, userId)
            .query(`
                SELECT 
                    s.SkillID,
                    s.SkillName,
                    jss.ProficiencyLevel,
                    jss.YearOfExperience,
                    s.PopularityScore
                FROM [JobSeekerSkill] jss
                JOIN [Skill] s ON jss.SkillID = s.SkillID
                WHERE jss.JobSeekerID = @JobSeekerID
            `)
        return result.recordset
    } catch (err) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

// recalcSkillPopularity removed — not needed anymore

const addSkill = async (userId, skillData) => {
    const pool = GET_SQL_POOL()
    const transaction = new sql.Transaction(pool)

    try {
        await transaction.begin()

        let skillId = skillData.SkillID

        if (!skillId) {
            const skillCheck = await transaction.request()
                .input('SkillName', sql.NVarChar, skillData.SkillName)
                .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

            if (skillCheck.recordset.length > 0) {
                skillId = skillCheck.recordset[0].SkillID
            } else {
                const createSkill = await transaction.request()
                    .input('SkillName', sql.NVarChar, skillData.SkillName)
                    .query(`
                        INSERT INTO [Skill] (SkillName, PopularityScore) 
                        OUTPUT INSERTED.SkillID
                        VALUES (@SkillName, 0)
                    `)
                skillId = createSkill.recordset[0].SkillID
            }
        }

        // Check if user already has this skill
        const existingSkill = await transaction.request()
            .input('JobSeekerID', userId)
            .input('SkillID', skillId)
            .query(`SELECT * FROM [JobSeekerSkill] WHERE JobSeekerID = @JobSeekerID AND SkillID = @SkillID`)

        if (existingSkill.recordset.length > 0) {
            // Update existing skill
            await transaction.request()
                .input('JobSeekerID', userId)
                .input('SkillID', skillId)
                .input('ProficiencyLevel', skillData.ProficiencyLevel)
                .input('YearOfExperience', skillData.YearOfExperience)
                .query(`
                    UPDATE [JobSeekerSkill]
                    SET ProficiencyLevel = @ProficiencyLevel, YearOfExperience = @YearOfExperience
                    WHERE JobSeekerID = @JobSeekerID AND SkillID = @SkillID
                `)
        } else {
            // Insert new skill
            await transaction.request()
                .input('JobSeekerID', userId)
                .input('SkillID', skillId)
                .input('ProficiencyLevel', skillData.ProficiencyLevel)
                .input('YearOfExperience', skillData.YearOfExperience)
                .query(`
                    INSERT INTO [JobSeekerSkill] (JobSeekerID, SkillID, ProficiencyLevel, YearOfExperience)
                    VALUES (@JobSeekerID, @SkillID, @ProficiencyLevel, @YearOfExperience)
                `)
        }

        await transaction.commit()
        return true
    } catch (err) {
        await transaction.rollback()
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

const deleteSkill = async (userId, skillId) => {
    try {
        const pool = GET_SQL_POOL()
        await pool.request()
            .input('JobSeekerID', userId)
            .input('SkillID', skillId)
            .query(`DELETE FROM [JobSeekerSkill] WHERE JobSeekerID = @JobSeekerID AND SkillID = @SkillID`)
        return true
    } catch (err) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

const getAvailableSkills = async () => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request().query(`SELECT SkillID, SkillName FROM [Skill] ORDER BY SkillName`)
        return result.recordset
    } catch (err) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, err.message)
    }
}

export const seekerModel = {
    getProfile,
    updateProfile,
    updateSkills,
    getSkills,
    addSkill,
    deleteSkill,
    getAvailableSkills
}
