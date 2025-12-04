import { GET_SQL_POOL } from '~/config/SQLDatabase.js'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import dayjs from 'dayjs'
import utc from 'dayjs/plugin/utc.js'
import timezone from 'dayjs/plugin/timezone.js'
dayjs.extend(utc)
dayjs.extend(timezone)
import sql from 'mssql'

const createJob = async (jobData) => {
    const pool = GET_SQL_POOL()
    try {
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, companyId, experienceRequired, applicationDeadline, openingCount, skills } = jobData
        const time = dayjs().tz('Asia/Ho_Chi_Minh').format('YYYY-MM-DD HH:mm:ss')
        const jobResult = await pool.request()
            .input('jobTitle', jobTitle)
            .input('jobDescription', jobDescription)
            .input('salaryMin', salaryMin)
            .input('salaryMax', salaryMax)
            .input('location', location)
            .input('employmentType', employmentType)
            .input('companyId', companyId)
            .input('experienceRequired', experienceRequired)
            .input('applicationDeadline', applicationDeadline)
            .input('openingCount', openingCount)
            .input('jobStatus', 'Open')
            .input('postedDate', time)
            .query(`
                INSERT INTO [Job] ([CompanyID], [JobTitle], [JobDescription], [EmploymentType], [ExperienceRequired], [SalaryMin], [SalaryMax], [Location], [OpeningCount], [ApplicationDeadline], [JobStatus], [PostedDate])
                VALUES (@companyId, @jobTitle, @jobDescription, @employmentType, @experienceRequired, @salaryMin, @salaryMax, @location, @openingCount, @applicationDeadline, @jobStatus, @postedDate);
            `)
        console.log(jobTitle, companyId, time)
        const jobId = await findJobID(jobTitle, companyId, time)
        // Khong biet tai sao 
        console.log('hello this is insertedJob', jobId, 'end')

        if (skills && skills.length > 0) {
            for (const skillName of skills) {
                let skillId
                const skillCheck = await pool.request()
                    .input('SkillName', sql.NVarChar, skillName)
                    .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

                if (skillCheck.recordset.length > 0) {
                    skillId = skillCheck.recordset[0].SkillID
                } else {
                    const createSkill = await pool.request()
                        .input('SkillName', sql.NVarChar, skillName)
                        .query(`
                            INSERT INTO [Skill] (SkillName, PopularityScore) 
                            OUTPUT INSERTED.SkillID
                            VALUES (@SkillName, 0);
                        `)
                    skillId = createSkill.recordset[0].SkillID
                }

                await pool.request()
                    .input('JobID', jobId)
                    .input('SkillID', skillId)
                    .input('ProficiencyLevel', 'Intermediate')
                    .input('IsRequired', true)
                    .query(`
                        INSERT INTO [JobRequireSkill] (JobID, SkillID, ProficiencyLevel, IsRequired)
                        VALUES (@JobID, @SkillID, @ProficiencyLevel, @IsRequired);
                    `)
            }
        }

        return jobId
    } catch (error) {
        console.log('Error creating job:', error)
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

        if (result.recordset.length === 0) return null

        const job = result.recordset[0]

        // Get skills
        const skillsResult = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT S.SkillName
                FROM [JobRequireSkill] JRS
                JOIN [Skill] S ON JRS.SkillID = S.SkillID
                WHERE JRS.JobID = @jobId
            `)

        job.Skills = skillsResult.recordset.map(r => r.SkillName)

        return job
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobsByCompanyId = async (companyId, page = 1, limit = 10) => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit

        // Get total count for pagination
        const countResult = await pool.request()
            .input('companyId', companyId)
            .query(`
                SELECT COUNT(*) as total
                FROM [Job]
                WHERE CompanyID = @companyId
            `)
        const totalJobs = countResult.recordset[0].total
        const totalPages = Math.ceil(totalJobs / limit)

        const result = await pool.request()
            .input('companyId', companyId)
            .input('offset', offset)
            .input('limit', limit)
            .query(`
                SELECT J.*, JM.AppliedCount as Applicants, J.ApplicationDeadline as Deadline, J.JobStatus as Status
                FROM [Job] J
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.CompanyID = @companyId
                ORDER BY J.PostedDate DESC
                OFFSET @offset ROWS
                FETCH NEXT @limit ROWS ONLY
            `)

        return {
            jobs: result.recordset,
            currentPage: parseInt(page),
            totalPages,
            totalJobs
        }
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const deleteJob = async (jobId, companyId) => {
    try {
        const pool = GET_SQL_POOL()
        // Verify ownership before deleting
        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .query(`
                DELETE FROM [Job]
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }
        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateJobStatus = async (jobId, companyId, status) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .input('status', status)
            .query(`
                UPDATE [Job]
                SET JobStatus = @status
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }
        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const updateJob = async (jobId, companyId, jobData) => {
    const pool = GET_SQL_POOL()
    try {
        const { jobTitle, jobDescription, salaryMin, salaryMax, location, employmentType, experienceRequired, applicationDeadline, openingCount, skills } = jobData

        const result = await pool.request()
            .input('jobId', jobId)
            .input('companyId', companyId)
            .input('jobTitle', jobTitle)
            .input('jobDescription', jobDescription)
            .input('salaryMin', salaryMin)
            .input('salaryMax', salaryMax)
            .input('location', location)
            .input('employmentType', employmentType)
            .input('experienceRequired', experienceRequired)
            .input('applicationDeadline', applicationDeadline)
            .input('openingCount', openingCount)
            .query(`
                UPDATE [Job]
                SET 
                    JobTitle = @jobTitle,
                    JobDescription = @jobDescription,
                    SalaryMin = @salaryMin,
                    SalaryMax = @salaryMax,
                    Location = @location,
                    EmploymentType = @employmentType,
                    ExperienceRequired = @experienceRequired,
                    ApplicationDeadline = @applicationDeadline,
                    OpeningCount = @openingCount
                WHERE JobID = @jobId AND CompanyID = @companyId
            `)

        if (result.rowsAffected[0] === 0) {
            throw new Error('Job not found or unauthorized')
        }

        if (skills) {
            await pool.request()
                .input('JobID', jobId)
                .query(`DELETE FROM [JobRequireSkill] WHERE JobID = @JobID`)

            for (const skillName of skills) {
                let skillId
                const skillCheck = await pool.request()
                    .input('SkillName', sql.NVarChar, skillName)
                    .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

                if (skillCheck.recordset.length > 0) {
                    skillId = skillCheck.recordset[0].SkillID
                } else {
                    const createSkill = await pool.request()
                        .input('SkillName', sql.NVarChar, skillName)
                        .query(`
                            INSERT INTO [Skill] (SkillName, PopularityScore) 
                            OUTPUT INSERTED.SkillID
                            VALUES (@SkillName, 0)
                        `)
                    skillId = createSkill.recordset[0].SkillID
                }

                await pool.request()
                    .input('JobID', jobId)
                    .input('SkillID', skillId)
                    .input('ProficiencyLevel', 'Intermediate')
                    .input('IsRequired', true)
                    .query(`
                        INSERT INTO [JobRequireSkill] (JobID, SkillID, ProficiencyLevel, IsRequired)
                        VALUES (@JobID, @SkillID, @ProficiencyLevel, @IsRequired)
                    `)
            }
        }

        return true
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const findJobID = async (jobTitle, companyId, postedDate) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('jobTitle', jobTitle)
            .input('companyId', companyId)
            .input('postedDate', postedDate)
            .query(`
                SELECT JobID FROM [Job] WHERE JobTitle = @jobTitle AND CompanyID = @companyId AND PostedDate = @postedDate
            `)
        return result.recordset[0].JobID
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const jobModel = {
    createJob,
    getJobById,
    getJobsByCompanyId,
    deleteJob,
    updateJobStatus,
    updateJob,
    findJobID
}
