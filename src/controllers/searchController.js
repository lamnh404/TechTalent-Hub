import searchModel from "~/models/searchModel";

const searchController = {
    searchJobs: async (req, res) => {
        try {
            const keyword = req.query.q || "";
            const jobs = await searchModel.searchJobs(keyword);

            res.render("jobs/jobs", {
                jobs,
                keyword,
                user: req.user
            });
        } catch (error) {
            console.error("Search error:", error);
            res.status(500).send("Internal Server Error");
        }
    },
};

export default searchController;