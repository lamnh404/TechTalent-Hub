import express from 'express'
import { env } from '~/config/environment.js'
const START_SERVER = () => {
    const app = express()

    // Parse incoming JSON requests
    app.use(express.json())

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
}

(() => {
    START_SERVER()
})()


