import dayjs from 'dayjs'
import utc from 'dayjs/plugin/utc.js'
import timezone from 'dayjs/plugin/timezone.js'

dayjs.extend(utc)
dayjs.extend(timezone)

export const pickUserFields = (user) => {
    return {
        id: user.userId,
        email: user.email,
        userType: user.userType,
        avatarUrl: user.avatarUrl
    }
}

/**
 * Converts a date to Vietnam timezone (UTC+7) and returns a Date object
 * This ensures dates are displayed correctly regardless of server timezone.
 */
export const toVietnamDate = (date) => {
    if (!date) return null
    
    try {
        let parsedDate
        
        if (date instanceof Date) {
            const year = date.getUTCFullYear()
            const month = date.getUTCMonth()
            const day = date.getUTCDate()
            const hours = date.getUTCHours()
            const minutes = date.getUTCMinutes()
            const seconds = date.getUTCSeconds()
            
            parsedDate = dayjs.tz(
                `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')} ${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`,
                'Asia/Ho_Chi_Minh'
            )
        } else {
            // String date from SQL Server - parse it as Vietnam local time
            // SQL Server stores "2024-01-15 17:00:00" which should be interpreted as Vietnam time
            parsedDate = dayjs.tz(date, 'Asia/Ho_Chi_Minh')
        }
        
        if (!parsedDate.isValid()) {
            console.warn('Invalid date:', date)
            return null
        }
        
        return parsedDate.toDate()
    } catch (error) {
        console.warn('Error converting date to Vietnam timezone:', error)
        return null
    }
}

/**
 * Formats a date to Vietnam locale date string
 * @param {Date|string} date - The date to format
 * @returns {string} - Formatted date string in Vietnam locale, or empty string if invalid
 */
export const formatVietnamDate = (date) => {
    const vietnamDate = toVietnamDate(date)
    if (!vietnamDate) return ''
    return vietnamDate.toLocaleDateString('vi-VN')
}