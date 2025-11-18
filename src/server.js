import express from 'express'
import { env } from '~/config/environment.js'
import { API } from '~/routes/router.js'
import path from 'path'
import { INIT_SQL_POOL, CLOSE_SQL_POOL} from '~/config/SQLDatabase.js'
import exitHook from 'async-exit-hook'
import { errorHandlingMiddlewares } from '~/middlewares/errorHandlingMIddleware'
import session from 'express-session'
import ms from 'ms'

const START_SERVER = () => {
    const app = express()

    // Parse incoming JSON requests
    app.use(express.json())

    //  Parse URL-encoded requests
    app.use(express.urlencoded({ extended: true }))

    // Use error handling middlewares
    app.use(errorHandlingMiddlewares)


    // Set up session management
    app.use(session({
        secret: env.SESSION_SECRET_KEY,
        resave: false,
        saveUninitialized: true,
        cookie: {
            secure: env.BUILD_MODE === 'production',
            httpOnly: true,
            sameSite: 'lax',
            maxAge: ms(env.COOKIE_LIFE)
        }
    }))

    // Use the API routes
    app.use('/', API)

    // Serve static files from the "public" directory
    app.use(express.static(path.join(__dirname, 'public')))

    // Set EJS as the templating engine
    app.set('view engine', 'ejs')
    app.set('views', path.join(__dirname, 'views'))

    if (env.BUILD_MODE === 'production') {
        app.listen(env.LOCAL_DEV_APP_PORT, env.LOCAL_DEV_APP_HOST, () => {

        })
    }
    else {
        app.listen(env.LOCAL_DEV_APP_PORT, env.LOCAL_DEV_APP_HOST, () => {
            console.log(`Server running on development mode at http://${env.LOCAL_DEV_APP_HOST}:${env.LOCAL_DEV_APP_PORT}`)
        })
    }

    exitHook(async () => {
        console.log('Shutting down server...')
        await CLOSE_SQL_POOL()
        console.log('Server shut down complete.')
    })
}

(async () => {
    try {
        await INIT_SQL_POOL()
        START_SERVER()
    } catch (error) {
        console.error('error starting server:', error)
        process.exit(1)
    }
})()


