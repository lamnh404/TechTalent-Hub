import sql from 'mssql';
import { GET_SQL_POOL } from '~/config/SQLDatabase';

const searchModel = {
    searchJobs: async (keyword) => {
        try {
            const pool = GET_SQL_POOL();
            const request = pool.request();
            request.input("keyword", sql.NVarChar, `%${keyword}%`);

            const query = `
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
          JM.AppliedCount,
          JM.ViewCount
        FROM [Job] J
        JOIN [Company] C ON J.CompanyID = C.CompanyID
        LEFT JOIN [JobRequireSkill] JRS ON J.JobID = JRS.JobID
        LEFT JOIN [Skill] S ON JRS.SkillID = S.SkillID
        LEFT JOIN [JobMetrics] JM ON J.JobID = JM.JobMetricID
        WHERE J.JobTitle LIKE @keyword
           OR C.CompanyName LIKE @keyword
           OR S.SkillName LIKE @keyword
        ORDER BY J.PostedDate DESC
      `;

            const result = await request.query(query);
            return result.recordset;
        } catch (err) {
            throw err;
        }
    },
};

export default searchModel;
