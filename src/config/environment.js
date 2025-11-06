import dotenv from 'dotenv';

dotenv.config();

export const env = {
    LOCAL_DEV_APP_HOST: process.env.LOCAL_DEV_APP_HOST || 'localhost',
    LOCAL_DEV_APP_PORT: process.env.LOCAL_DEV_APP_PORT || 8017,

    BUILD_MODE: process.env.BUILD_MODE
}