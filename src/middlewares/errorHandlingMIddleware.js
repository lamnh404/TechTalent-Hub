import { StatusCodes } from 'http-status-codes'
import { env } from '~/config/environment.js'

export const errorHandlingMiddlewares = (err, req, res, next) => {
    if (!err.statusCode) err.statusCode = StatusCodes.INTERNAL_SERVER_ERROR

    const response = {
        statusCode: err.statusCode,
        message: err.message,
        ...(env.BUILD_MODE === 'development' && { stack: err.stack })
    }

    res.render('/error/error.ejs', response)

}
