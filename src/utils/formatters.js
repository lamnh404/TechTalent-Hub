
export const pickUserFields = (user) => {
    return {
        id: user.UserId,
        email: user.Email,
        userType: user.UserType,
        avatarUrl: user.AvatarUrl
    }
}
