import express from 'express'
import { env } from '~/config/environment.js'
import { API} from '~/routes/router.js'
import path from 'path'
import { INIT_MYSQL_POOL, CLOSE_MYSQL_POOL } from '~/config/mysqlDatabase.js'
import exitHook from 'async-exit-hook'

const START_SERVER = () => {
    const app = express()

    // Parse incoming JSON requests
    app.use(express.json())

    // Use the API routes
    app.use('/', API)

    // Set EJS as the templating engine
    app.set('view engine', 'ejs');
    app.set('views', path.join(__dirname, 'views'));

    if (env.BUILD_MODE === 'production') {
        app.listen(env.LOCAL_DEV_APP_PORT, env.LOCAL_DEV_APP_HOST, () => {
            console.log(`Server running on production mode on port ${process.env.PORT}`)
        })
    }
    else {
        app.listen(env.LOCAL_DEV_APP_PORT, env.LOCAL_DEV_APP_HOST, () => {
            console.log(`Server running on development mode at http://${env.LOCAL_DEV_APP_HOST}:${env.LOCAL_DEV_APP_PORT}`)
        })
    }

    exitHook(async () => {
        console.log('Shutting down server...')
        await CLOSE_MYSQL_POOL();
        console.log('Server shut down complete.')
    });
}

(async () => {
    try {
    await INIT_MYSQL_POOL()
    START_SERVER()
    } catch (error) {
        console.error('Error starting server:', error)
        process.exit(1);
    }
})()


