// kiosk_backend/db.js

require('dotenv').config();       // .env 파일에 정의된 환경 변수를 불러옴.
const sql = require('mssql');    // mssql 패키지: MS SQL Server와 연결/쿼리 수행

// 환경 변수에서 DB 접속 정보를 읽어와 config 객체를 구성
const config = {
  user: process.env.DB_USER,                         // DB 사용자 이름
  password: process.env.DB_PASSWORD,                 // DB 사용자 비밀번호
  server: process.env.DB_SERVER,                     // DB 서버 호스트
  port: parseInt(process.env.DB_PORT_SQL, 10),       // DB 포트 번호
  database: process.env.DB_DATABASE,                 // 사용할 데이터베이스 이름
  options: {
    // Azure 등의 클라우드 환경에서는 encrypt: true로, 로컬 개발에서는 false로 설정
    encrypt: false,
    // 자체 서명된 인증서를 허용하려면 true로 설정 (개발/테스트 환경용)
    trustServerCertificate: true,
  },
  pool: {
    // 연결 풀 설정: 동시 커넥션 최대 10, 최소 0, 유휴 타임아웃 30000ms
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

// 연결 풀을 생성하고 즉시 연결을 시도.
// Promise로 만들어 두어, 다른 파일에서 poolPromise를 사용해 연결이 완료된 후 쿼리를 실행할 수 있음.
const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    // 연결이 성공하면 서버와 데이터베이스 정보를 로그에 출력
    console.log(`✅ MSSQL Connected to ${config.server}:${config.port}/${config.database}`);
    return pool;  // 연결된 pool 객체를 반환
  })
  .catch(err => {
    // 연결에 실패하면 에러 메시지를 출력하고 에러 던짐.
    console.error('MSSQL Connection Failed:', err.message);
    throw err;
  });

// 외부 모듈에서 sql 객체와 poolPromise를 불러다 쓸 수 있도록 export
module.exports = {
  sql,
  poolPromise
};
