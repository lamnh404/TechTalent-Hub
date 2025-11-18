import sql from 'mssql';
import { env} from '~/config/environment.js';


const config ={
    user: env.SQL_USER,
    password: env.SQL_PASSWORD,
    server: env.SQL_SERVER,
    database: env.SQL_DATABASE,
    port: parseInt(env.SQL_PORT),
    options: {
        encrypt: env.BUILD_MODE === 'production',
        enableArithAbort: true
    }
}

let pool = null

export const INIT_SQL_POOL = async () => {
    try {
        pool = await new sql.ConnectionPool(config).connect();
        console.log('Connected to SQL Server database');
    } catch (error) {
        console.error('Error connecting to SQL Server database:', error);
        throw new Error(error);
    }
};

export const GET_SQL_POOL = () => {
    if (!pool) {
        throw new Error('SQL Pool not initialized. Call INIT_SQL_POOL first.');
    }
    return pool;
};

export const CLOSE_SQL_POOL = async () => {
    try {
        if (pool) {
            await pool.close();
            pool = null;
            console.log('SQL Server connection pool closed');
        }
    } catch (error) {
        console.error('Error closing SQL Server connection pool:', error);
        throw new Error(error);
    }
}