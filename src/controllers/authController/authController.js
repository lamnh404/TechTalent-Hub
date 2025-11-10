
const login = async (req, res) => {

    const {email, password} = req.body;
    const result = await authModel.login(email, password);

}



export const authController = {
    login
};