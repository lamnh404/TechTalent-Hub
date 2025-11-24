
export const pickUserFields = (user) => {
    return {
        id: user.userId,
        email: user.email,
        userType: user.userType,
        avatarUrl: user.avatarUrl
    }
}