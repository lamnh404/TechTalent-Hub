import { authModel } from '~/models/authModel/authModel.js'
import { regModel } from '~/models/authModel/regModel.js'


const login = async (req, res, next) => {
    try {
        const { email, password } = req.body
        const user = await authModel.login(email, password)
        req.session.user = user

        console.log('User logged in:', user);
        
        req.session.save((err) => {
            if (err) return next(err);
            res.redirect('/')
        });

    } catch (error) {
        next(error)
    }
}

const logout = (req, res) => {
    // 1. Hủy session
    req.session.destroy((err) => {
        if (err) {
            console.error('Error destroying session:', err);
            return res.status(500).send('Could not log out.');
        }
const register = async (req, res, next) => {
    try {
        const { name, email, password, role } = req.body
        const user = await regModel.register(name, email, password, role)
        res.redirect('/login')

        // 2. Xóa cookie ở phía client (tên cookie mặc định là 'connect.sid', kiểm tra lại trong server.js nếu bạn đổi tên)
        res.clearCookie('connect.sid');

        // 3. Chuyển hướng về trang chủ hoặc trang login
        res.redirect('/');
    });
};


    } catch (error) {
        next(error)
    }
}

export const authController = {
    register
    login,
    logout
}