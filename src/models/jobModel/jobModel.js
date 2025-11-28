import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import sql from 'mssql'

const createJob = async (jobData) => {
    try {
        const pool = GET_SQL_POOL()
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, companyId, experienceRequired, applicationDeadline, skills } = jobData

        const transaction = new sql.Transaction(pool)
        await transaction.begin()

        try {
            const request = new sql.Request(transaction)

            // 1. Insert Job
            const jobResult = await request
                .input('jobTitle', sql.NVarChar, jobTitle)
                .input('jobDescription', sql.NVarChar, jobDescription)
                .input('salaryMin', sql.Decimal(15, 2), salaryMin)
                .input('salaryMax', sql.Decimal(15, 2), salaryMax)
                .input('location', sql.NVarChar, location)
                .input('employmentType', sql.NVarChar, employmentType)
                .input('companyId', sql.NVarChar, companyId)
                .input('experienceRequired', sql.SmallInt, experienceRequired || 0)
                .input('applicationDeadline', sql.DateTime2, applicationDeadline || null)
                .query(`
                    DECLARE @NewJobID NVARCHAR(128) = NEWID();
                    INSERT INTO [Job] (JobID, JobTitle, JobDescription, SalaryMin, SalaryMax, Location, EmploymentType, PostedDate, CompanyID, ExperienceRequired, ApplicationDeadline, JobStatus)
                    VALUES (@NewJobID, @jobTitle, @jobDescription, @salaryMin, @salaryMax, @location, @employmentType, GETDATE(), @companyId, @experienceRequired, @applicationDeadline, 'Open');
                    SELECT @NewJobID AS JobID;
                `)

            const newJobId = jobResult.recordset[0].JobID

            // 2. Insert JobMetrics
            await request.query(`
                INSERT INTO [JobMetrics] (JobMetricID, AppliedCount, LikeCount, ViewCount, LastUpdated)
                VALUES ('${newJobId}', 0, 0, 0, GETDATE())
            `)

            // 3. Handle Skills
            if (skills && typeof skills === 'string') {
                const skillList = skills.split(',').map(s => s.trim()).filter(s => s)

                for (const skillName of skillList) {
                    // Check if skill exists
                    let skillIdResult = await request.query(`SELECT SkillID FROM [Skill] WHERE SkillName = N'${skillName}'`)
                    let skillId

                    if (skillIdResult.recordset.length > 0) {
                        skillId = skillIdResult.recordset[0].SkillID
                    } else {
                        // Create new skill
                        const insertSkillResult = await request.query(`
                            INSERT INTO [Skill] (SkillName, PopularityScore) VALUES (N'${skillName}', 0);
                            SELECT SCOPE_IDENTITY() AS SkillID;
                        `)
                        skillId = insertSkillResult.recordset[0].SkillID
                    }

                    // Link Job and Skill
                    await request.query(`
                        INSERT INTO [JobRequireSkill] (JobID, SkillID, ProficiencyLevel, IsRequired)
                        VALUES ('${newJobId}', ${skillId}, 'Intermediate', 1)
                    `)
                }
            }

            await transaction.commit()
            return newJobId

        } catch (err) {
            await transaction.rollback()
            throw err
        }

    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobById = async (jobId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT J.*, C.CompanyName, C.LogoURL, JM.ViewCount, JM.AppliedCount
                FROM [Job] J
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.JobID = @jobId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobsByCompanyId = async (companyId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT J.*, JM.AppliedCount as Applicants, J.ApplicationDeadline as Deadline, J.JobStatus as Status
                FROM [Job] J
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.CompanyID = @companyId
                ORDER BY J.PostedDate DESC
            `)
        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const jobModel = {
    createJob,
    getJobById,
    getJobsByCompanyId
}
