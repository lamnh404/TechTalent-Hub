import mysql from 'mysql2/promise';
import { env } from '~/config/environment.js';


const config = {
    host: env.MYSQL_HOST,
    user: env.MYSQL_USER,
    password: env.MYSQL_PASSWORD,
    database: env.MYSQL_DATABASE,
    port: env.MYSQL_PORT,
    connectionLimit: 10
}

let mysqlPool = null


const mysqlDatabase = mysql.createPool(config);

export const INIT_MYSQL_POOL = async () => {
    mysqlPool = mysql.createPool(config);
    console.log('MySQL Pool initialized');
}

export const GET_MYSQL_CONNECTION = () => {
    if (!mysqlPool) {
        throw new Error('MySQL Pool not initialized. Call INIT_MYSQL_POOL first.');
    }
    const connection = mysqlPool.getConnection();
    console.log('MySQL Connection acquired from pool');
    return connection;
}

export const CLOSE_MYSQL_POOL = async () => {
  if (mysqlPool) {
    await mysqlPool.end()
    console.log('MySQL pool closed')
  }
}
