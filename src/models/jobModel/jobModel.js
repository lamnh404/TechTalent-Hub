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
        const time = dayjs().utc().format('YYYY-MM-DD HH:mm:ss')
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

        const jobId = jobResult.recordset[0].JobID
        try {
            await pool.request()
                .input('JobMetricID', jobId)
                .input('lastUpdated', time)
                .query(`
                    IF NOT EXISTS (SELECT 1 FROM [JobMetrics] WHERE JobMetricID = @JobMetricID)
                    INSERT INTO [JobMetrics] (JobMetricID, AppliedCount, LikeCount, ViewCount, LastUpdated)
                    VALUES (@JobMetricID, 0, 0, 0, @lastUpdated)
                `)
        } catch (mErr) {
            console.warn('Failed to create JobMetrics for job', jobId, mErr.message)
        }

        if (skills && skills.length > 0) {
            for (const skill of skills) {
                const skillName = skill.SkillName
                const proficiencyLevel = skill.ProficiencyLevel
                const isRequired = skill.IsRequired || 0

                let skillId
                const skillCheck = await pool.request()
                    .input('SkillName', skillName)
                    .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

                if (skillCheck.recordset.length > 0) {
                    skillId = skillCheck.recordset[0].SkillID
                } else {
                    const createSkill = await pool.request()
                        .input('SkillName', skillName)
                        .query(`
                            INSERT INTO [Skill] (SkillName) 
                            VALUES (@SkillName);
                        `)
                    skillId = createSkill.recordset[0].SkillID
                }

                await pool.request()
                    .input('JobID', jobId)
                    .input('SkillID', skillId)
                    .input('ProficiencyLevel', proficiencyLevel)
                    .input('IsRequired', isRequired)
                    .query(`
                        INSERT INTO [JobRequireSkill] (JobID, SkillID, ProficiencyLevel, IsRequired)
                        VALUES (@JobID, @SkillID, @ProficiencyLevel, @IsRequired);
                    `)
            }
        }

        return jobId
    } catch (error) {
        const raw = error && error.message ? error.message : String(error)
        let friendly = 'Internal server error'

        if (/CK_Job_Deadline|CHECK constraint.*Deadline|Deadline/.test(raw)) {
            friendly = 'Invalid deadline: Deadline must be a date later than today.'
        } else if (/CK_|CHECK constraint/.test(raw)) {
            friendly = 'Invalid data: one of the fields failed validation.'
        } else if (/UNIQUE KEY|UNIQUE constraint|Violation of UNIQUE KEY/.test(raw)) {
            friendly = 'Duplicate value: a record with the same unique field already exists.'
        } else if (/FOREIGN KEY constraint|REFERENCE constraint/.test(raw)) {
            friendly = 'Invalid reference: related record not found.'
        } else if (/Cannot insert the value NULL/i.test(raw)) {
            friendly = 'Missing required field: please ensure all required fields are provided.'
        } else {
            friendly = raw
        }

        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, friendly)
    }
}

const getJobById = async (jobId) => {
    try {
        const pool = GET_SQL_POOL()
        const time = dayjs().utc().format('YYYY-MM-DD HH:mm:ss')

        await pool.request()
            .input('jobId', jobId)
            .input('time', time)
            .query(`
                IF EXISTS (SELECT 1 FROM [JobMetrics] WHERE JobMetricID = @jobId)
                    UPDATE [JobMetrics]
                    SET ViewCount = ISNULL(ViewCount, 0) + 1,
                        LastUpdated = @time
                    WHERE JobMetricID = @jobId
                ELSE
                    INSERT INTO [JobMetrics] (JobMetricID, AppliedCount, LikeCount, ViewCount, LastUpdated)
                    VALUES (@jobId, 0, 0, 1, @time)
            `)

        const result = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT
                    J.JobID,
                    J.CompanyID,
                    J.JobTitle,
                    J.JobDescription,
                    J.SalaryMin,
                    J.SalaryMax,
                    J.Location,
                    J.EmploymentType,
                    J.PostedDate,
                    J.ExperienceRequired,
                    J.ApplicationDeadline,
                    J.OpeningCount,
                    J.JobStatus,
                    C.CompanyName,
                    C.LogoURL AS LogoURL,
                    JM.ViewCount,
                    JM.AppliedCount
                FROM [Job] J
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                WHERE J.JobID = @jobId
            `)

        if (result.recordset.length === 0) return null

        const job = result.recordset[0]
        const skillsResult = await pool.request()
            .input('jobId', jobId)
            .query(`
                SELECT S.SkillName, JRS.ProficiencyLevel, JRS.IsRequired
                FROM [JobRequireSkill] JRS
                JOIN [Skill] S ON JRS.SkillID = S.SkillID
                WHERE JRS.JobID = @jobId
            `)

        job.Skills = skillsResult.recordset.map(r => ({
            SkillName: r.SkillName,
            ProficiencyLevel: r.ProficiencyLevel,
            IsRequired: r.IsRequired
        }))

        return job
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getLatestJobs = async (limit = 6) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('limit', limit)
            .query(`
                SELECT
                    J.JobID,
                    J.JobTitle,
                    J.PostedDate,
                    J.ApplicationDeadline AS ApplicationDeadline,
                    J.EmploymentType,
                    J.Location,
                    C.CompanyName,
                    C.LogoURL AS LogoURL,
                    ISNULL((SELECT COUNT(1) FROM [Application] A WHERE A.JobID = J.JobID), 0) AS Applicants
                FROM [Job] J
                JOIN [Company] C ON J.CompanyID = C.CompanyID
                WHERE J.JobStatus = 'Open'
                ORDER BY J.PostedDate DESC
                OFFSET 0 ROWS
                FETCH NEXT @limit ROWS ONLY
            `)

        return result.recordset
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getJobsByCompanyId = async (companyId, page = 1, limit = 10, titleFilter = '', statusFilter = 'all') => {
    try {
        const pool = GET_SQL_POOL()
        const offset = (page - 1) * limit

        let whereClauses = ['J.CompanyID = @companyId']
        const request = pool.request().input('companyId', companyId)

        if (titleFilter && titleFilter.length > 0) {
            whereClauses.push('J.JobTitle LIKE @title')
            request.input('title', `%${titleFilter}%`)
        }

        if (statusFilter && statusFilter !== 'all') {
            let dbStatus = statusFilter
            if (statusFilter.toLowerCase() === 'active') dbStatus = 'Open'
            if (statusFilter.toLowerCase() === 'closed') dbStatus = 'Closed'
            whereClauses.push('J.JobStatus = @status')
            request.input('status', dbStatus)
        }

        const whereSql = whereClauses.length > 0 ? 'WHERE ' + whereClauses.join(' AND ') : ''

        const countQuery = `SELECT COUNT(*) as total FROM [Job] J ${whereSql}`
        const countResult = await request.query(countQuery)
        const totalJobs = countResult.recordset[0].total
        const totalPages = Math.ceil(totalJobs / limit)

        const dataRequest = pool.request()
            .input('companyId', companyId)
            .input('offset', offset)
            .input('limit', limit)

        if (titleFilter && titleFilter.length > 0) dataRequest.input('title', `%${titleFilter}%`)
        if (statusFilter && statusFilter !== 'all') {
            let dbStatus = statusFilter
            if (statusFilter.toLowerCase() === 'active') dbStatus = 'Open'
            if (statusFilter.toLowerCase() === 'closed') dbStatus = 'Closed'
            dataRequest.input('status', dbStatus)
        }

        const dataWhereSql = whereSql

        const result = await dataRequest.query(`
            SELECT 
                J.JobID, J.JobTitle, J.PostedDate, J.JobStatus as Status, 
                J.ApplicationDeadline AS Deadline, J.EmploymentType, J.Location,
                C.LogoURL AS LogoURL,
                ISNULL((SELECT COUNT(1) FROM [Application] A WHERE A.JobID = J.JobID), 0) AS Applicants
            FROM [Job] J
            LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
            JOIN [Company] C ON J.CompanyID = C.CompanyID
            ${dataWhereSql}
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

            for (const skill of skills) {
                const skillName = skill.SkillName
                const proficiencyLevel = skill.ProficiencyLevel
                const isRequired = skill.IsRequired !== undefined ? skill.IsRequired : true

                let skillId
                const skillCheck = await pool.request()
                    .input('SkillName', skillName)
                    .query(`SELECT SkillID FROM [Skill] WHERE SkillName = @SkillName`)

                if (skillCheck.recordset.length > 0) {
                    skillId = skillCheck.recordset[0].SkillID
                } else {
                    const createSkill = await pool.request()
                        .input('SkillName', skillName)
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
                    .input('ProficiencyLevel', proficiencyLevel)
                    .input('IsRequired', isRequired)
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
    getLatestJobs,
    getJobsByCompanyId,
    deleteJob,
    updateJobStatus,
    updateJob,
    findJobID
}
