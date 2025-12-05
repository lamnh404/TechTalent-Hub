import { GET_SQL_POOL } from '~/config/SQLDatabase'
import { ApiError } from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'

const sendInAppNotification = async (receiverId, notificationType, notificationContent) => {
    try {
        const pool = GET_SQL_POOL()
        const insertRes = await pool.request()
            .input('notificationType', notificationType)
            .input('notificationContent', notificationContent)
            .input('deliveryMethod', 'InApp')
            .query(`
                INSERT INTO [Notification] (NotificationType, NotificationContent, SendDate, ReadStatus, DeliveryMethod)
                VALUES (@notificationType, @notificationContent, GETDATE(), 0, @deliveryMethod);
                SELECT SCOPE_IDENTITY() AS NotificationID;
            `)

        const notificationId = insertRes.recordset && insertRes.recordset[0] && insertRes.recordset[0].NotificationID
        if (!notificationId) return null

        await pool.request()
            .input('notificationId', notificationId)
            .input('receiverId', receiverId)
            .query(`
                INSERT INTO [ReceiveNotification] (NotificationID, ReceiverID)
                VALUES (@notificationId, @receiverId)
            `)

        return notificationId
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

const getRole = async (userId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('userId', userId)
            .query(`
                SELECT UserType
                FROM [User]
                WHERE UserID = @userId
            `)
        return result.recordset[0]
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

 

const getNotifications = async (userId) => {
    try {
        const pool = GET_SQL_POOL()
        const result = await pool.request()
            .input('ReceiverID', userId)
            .query(`
                SELECT n.NotificationID, n.NotificationType, n.NotificationContent, n.SendDate, n.ReadStatus
                FROM [ReceiveNotification] rn
                JOIN [Notification] n ON rn.NotificationID = n.NotificationID
                WHERE rn.ReceiverID = @ReceiverID
                ORDER BY n.SendDate DESC
            `)
        return result.recordset || []
    } catch (error) {
        throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
    }
}

export const userModel = {
    getRole,
    getNotifications
    ,sendInAppNotification
}
