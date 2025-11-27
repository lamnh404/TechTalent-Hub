import searchModel from "~/models/jobModel/searchModel";

const searchController = {
    searchJobs: async (req, res) => {
        try {
            const q = req.query.q || "";
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 2;
            
            const jobs = await searchModel.searchJobs(q, page, limit);

            let totalJobs = 0;
            if (jobs.length > 0) {
                totalJobs = jobs[0].TotalCount;
            }
            const totalPages = Math.ceil(totalJobs / limit);

            res.render("homepage/job-listing.ejs", {
                jobs,
                q,
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