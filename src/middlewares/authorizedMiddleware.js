
const isAuthorized = (req, res, next) => {
    if( !req.session.user ) {
        return res.redirect('/login?error=You must be logged in');
    }
    next()
}

export default isAuthorized