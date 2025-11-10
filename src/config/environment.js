import dotenv from 'dotenv';

dotenv.config();

export const env = {
    LOCAL_DEV_APP_HOST: process.env.LOCAL_DEV_APP_HOST || 'localhost',
    LOCAL_DEV_APP_PORT: process.env.LOCAL_DEV_APP_PORT || 8017,

    MYSQL_HOST: process.env.MYSQL_HOST || 'localhost',

    MYSQL_USER: process.env.MYSQL_USER || 'root',

    MYSQL_PASSWORD: process.env.MYSQL_PASSWORD,

    MYSQL_DATABASE: process.env.MYSQL_DATABASE || 'techtalenthub',

    MYSQL_PORT: process.env.MYSQL_PORT || 3306,

    BUILD_MODE: process.env.BUILD_MODE
}