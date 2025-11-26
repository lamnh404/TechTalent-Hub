import searchModel from "~/models/jobModel/searchModel";

const searchController = {
    searchJobs: async (req, res) => {
        try {
            const q = req.query.q || "";
            const jobs = await searchModel.searchJobs(q);

            res.render("homepage/job-listing.ejs", {
                jobs,
                q,
                user: req.session.user
            });
        } catch (error) {
            console.error("Search error:", error);
            res.status(500).send("Internal Server Error");
        }
    },
};

export default searchController;