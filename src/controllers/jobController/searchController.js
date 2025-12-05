import searchModel from "~/models/jobModel/searchModel";

const searchController = {
    searchJobs: async (req, res) => {
        try {
            const q = req.query.q || "";
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 7;
            const sort = req.query.sort || 'newest';
            const jobTitle = req.query.jobTitle || '';
            const company = req.query.company || '';
            const minSalary = typeof req.query.minSalary !== 'undefined' ? req.query.minSalary : '';
            const maxSalary = typeof req.query.maxSalary !== 'undefined' ? req.query.maxSalary : '';

            const jobs = await searchModel.searchJobs(q, page, limit, sort, jobTitle, company, minSalary, maxSalary);

            let totalJobs = 0;
            if (jobs.length > 0) {
                totalJobs = jobs[0].TotalCount;
            }
            const totalPages = Math.ceil(totalJobs / limit);

            res.render("homepage/job-listing.ejs", {
                jobs,
                q,
                sort,
                jobTitle,
                company,
                minSalary,
                maxSalary,
                user: req.session.user,

                pagination: {
                    currentPage: page,
                    totalPages: totalPages,
                    totalJobs: totalJobs,
                },
            });
        } catch (error) {
            console.error("Search error:", error);
            res.status(500).send("Internal Server Error");
        }
    },
};

export default searchController;