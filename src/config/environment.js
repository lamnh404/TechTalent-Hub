import dotenv from 'dotenv';

dotenv.config();

export const env = {
    LOCAL_DEV_APP_HOST: process.env.LOCAL_DEV_APP_HOST || 'localhost',
    LOCAL_DEV_APP_PORT: process.env.LOCAL_DEV_APP_PORT || 8017,

    SQL_SERVER: process.env.SQL_SERVER || 'localhost',

    SQL_USER: process.env.SQL_USER || 'root',

    SQL_PASSWORD: process.env.SQL_PASSWORD,

    SQL_DATABASE: process.env.SQL_DATABASE || 'TechTalentHub',

    SQL_PORT: process.env.SQL_PORT || 1433,

    SESSION_SECRET_KEY: process.env.SESSION_SECRET_KEY,

    COOKIE_LIFE: process.env.COOKIE_LIFE,

    BUILD_MODE: process.env.BUILD_MODE
}