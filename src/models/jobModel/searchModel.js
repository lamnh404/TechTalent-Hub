import sql from 'mssql';
import { GET_SQL_POOL } from '~/config/SQLDatabase';

const searchModel = {
    searchJobs: async (keyword, page = 1, limit = 10) => {
        try {
            const pool = GET_SQL_POOL();
            const request = pool.request();

            const offset = (page - 1) * limit;

            request.input("keyword", sql.NVarChar, `%${keyword}%`);
            request.input("offset", sql.Int, offset);
            request.input("limit", sql.Int, limit);

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
                    WHERE J.JobTitle LIKE @keyword
                       OR C.CompanyName LIKE @keyword
                       OR S.SkillName LIKE @keyword
                )
                SELECT 
                    *, 
                    COUNT(*) OVER() as TotalCount 
                FROM DistinctJobs
                ORDER BY PostedDate DESC
                OFFSET @offset ROWS
                FETCH NEXT @limit ROWS ONLY
            `;

            const result = await request.query(query);
            return result.recordset;
        } catch (err) {
            throw err;
        }
    },
};

export default searchModel;
