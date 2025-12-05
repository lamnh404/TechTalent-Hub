import sql from 'mssql';
import { GET_SQL_POOL } from '~/config/SQLDatabase';

const searchJobs = async (keyword, page = 1, limit = 10, sort = 'newest', jobTitle, company, minSalary, employmentType) => {
        try {
            const pool = GET_SQL_POOL();
            const request = pool.request();

            const offset = (page - 1) * limit;

            request.input("keyword", sql.NVarChar, `%${keyword}%`);
            request.input("offset", sql.Int, offset);
            request.input("limit", sql.Int, limit);

            let extraWhere = '';
            if (jobTitle) {
                request.input("jobTitleFilter", sql.NVarChar, `%${jobTitle}%`);
                extraWhere += ` AND J.JobTitle LIKE @jobTitleFilter`;
            }
            if (company) {
                request.input("companyFilter", sql.NVarChar, `%${company}%`);
                extraWhere += ` AND C.CompanyName LIKE @companyFilter`;
            }

            if (employmentType) {
                request.input("employmentType", sql.NVarChar, employmentType);
                extraWhere += ` AND J.EmploymentType = @employmentType`;
            }

            const hasMin = Number.isFinite(minSalary);
            if (hasMin) {
                request.input("minSalary", sql.Decimal(15,2), minSalary);
                extraWhere += ` AND ( J.SalaryMin IS NOT NULL AND J.SalaryMin >= @minSalary )`;
            }

            let orderClause = 'PostedDate DESC';
            if (sort === 'oldest') orderClause = 'PostedDate ASC';

            const query = `
                ;WITH DistinctJobs AS (
                    SELECT DISTINCT 
                        J.JobID, 
                        J.JobTitle, 
                        J.JobDescription, 
                        J.SalaryMin,
                        J.SalaryMax,
                        J.Location, 
                        J.EmploymentType, 
                        J.PostedDate,
                        C.CompanyName,
                        C.LogoURL,
                        JM.ViewCount,
                        JM.AppliedCount
                    FROM [Job] J
                    JOIN [Company] C ON J.CompanyID = C.CompanyID
                    LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
                    LEFT JOIN [JobRequireSkill] JRS ON J.JobID = JRS.JobID
                    LEFT JOIN [Skill] S ON JRS.SkillID = S.SkillID
                    WHERE (
                        J.JobTitle LIKE @keyword
                        OR C.CompanyName LIKE @keyword
                        OR S.SkillName LIKE @keyword
                    )
                    ${extraWhere}
                )
                SELECT 
                    JobID,
                    JobTitle,
                    JobDescription,
                    SalaryMin,
                    SalaryMax,
                    Location,
                    EmploymentType,
                    PostedDate,
                    CompanyName,
                    LogoURL,
                    ViewCount,
                    AppliedCount,
                    COUNT(*) OVER() as TotalCount 
                FROM DistinctJobs
                ORDER BY ${orderClause}
                OFFSET @offset ROWS
                FETCH NEXT @limit ROWS ONLY
            `;

            const result = await request.query(query);
            return result.recordset;
        } catch (err) {
            throw err;
        }
    };

export const searchModel = {
    searchJobs
}

export default {
    searchJobs
}