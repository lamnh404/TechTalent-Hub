import { authModel } from '~/models/authModel/authModel.js'


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

        // 2. Xóa cookie ở phía client (tên cookie mặc định là 'connect.sid', kiểm tra lại trong server.js nếu bạn đổi tên)
        res.clearCookie('connect.sid');

        // 3. Chuyển hướng về trang chủ hoặc trang login
        res.redirect('/');
    });
};


export const authController = {
    login,
    logout
}