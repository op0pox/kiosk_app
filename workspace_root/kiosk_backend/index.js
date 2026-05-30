// kiosk_backend/index.js

// 1) 모듈 불러오기
const express = require('express');     //Express 프레임 워크
const cors = require('cors');       // CORS 설정을 위한 미들웨어
const path = require('path');       // 파일 경로 조작을 위한 내장 모듈
require('dotenv').config();     // .env 파일 로드
const { poolPromise } = require('./db');        // SQL Server 연결

// 2) app 초기화
const app = express();

// 3) 정적 파일 서빙: /images 경로로 assets/images 폴더 노출
app.use(
  '/images',        // 클라이언트에서 http://localhost:3006/images/파일명 으로 접근 시
  express.static(path.join(__dirname, 'assets/images'))     //assets/images 폴더 내부의 해당 파일을 반환
);

// 4) 미들웨어 설정
app.use(cors());        // 모든 출처에서 CORS 허용
app.use(express.json());        //요청 본문이 JSON일 때 파싱해 req.body에 넣어줌

// 5) Ping 테스트 라우트
app.get('/ping', (req, res) => {
  console.log('[PING] /ping 호출됨');
  res.send('pong');
});     // 서버가 정상 작동 중인지 확인할 때 사용함

// 6) 메뉴 목록 조회 (이미지 URL 및 restaurantId 필터 포함)
app.get('/api/menu', async (req, res) => {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    // 기본 SELECT문: menu_id, name, price, restaurant_id, image_url 가져오기
    let sqlText = `
      SELECT
        menu_id       AS id,
        name,
        price,
        restaurant_id,
        image_url
      FROM Menu
    `;

    //restaurantId 쿼리 파라미터가 있으면 WHERE 절 추가
    if (req.query.restaurantId) {
      sqlText += ' WHERE restaurant_id = @rid';
      request.input('rid', parseInt(req.query.restaurantId, 10));
    }
    const { recordset } = await request.query(sqlText);     //쿼리 실행
    res.json(recordset);        //결과: JSON으로 반환
  } catch (err) {
    console.error('[API] /api/menu error:', err);
    res.status(500).json({ error: err.message });
  }
});

// 7) 주문 저장
app.post('/api/order', async (req, res) => {
  console.log('▶ Received body:', JSON.stringify(req.body));
  const items = req.body.items;     //items가 배열이 아니거나 비어있으먄 400 에러 발생
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'items가 비어있습니다.' });
  }

  let tx;
  try {
    const pool = await poolPromise;
    tx = await pool.transaction();      //트랜잭션 시작
    await tx.begin();

    // 새 주문 생성 : Orders 테이블에 기본값 삽입 후 SCOPE_IDENTITY()로 orderId 가져오기
    const orderResult = await tx.request()
      .query(`INSERT INTO Orders DEFAULT VALUES;
              SELECT SCOPE_IDENTITY() AS orderId`);
    const orderId = orderResult.recordset[0].orderId;

    // 주문-메뉴 연결 테이블(Orders_Menu) 삽입
    for (const it of items) {
      const menuId = it.menu_id;
      const quantity = it.qty;
      //데이터 타입 검증: menuId와 quantity가 숫자인지 확인
      if (typeof menuId !== 'number' || typeof quantity !== 'number') {
        throw new Error(`잘못된 항목: ${JSON.stringify(it)}`);
      }

      await tx.request()
        .input('orderId', orderId)
        .input('menuId', menuId)
        .input('qty', quantity)
        .query(
          `INSERT INTO Orders_Menu(order_id, menu_id, quantity)
           VALUES(@orderId, @menuId, @qty)`
        );
    }

    // 트랜잭션 커밋
    await tx.commit();
    console.log(`▶ Order ${orderId} committed.`);
    res.json({ success: true, orderId });

  } catch (err) {
    console.error('[API] /api/order error:', err);
    // 오류 발생 시 트랜잭션 롤백 시도
    if (tx) {
      try { await tx.rollback(); console.log('▶ Rolled back'); } catch (_) {}
    }
    res.status(500).json({ error: err.message });
  }
});

// 8) 주문 상세 조회
app.get('/api/order/:id', async (req, res) => {
  const orderId = parseInt(req.params.id, 10);
  try {
    const pool = await poolPromise;

    // 1) 주문 헤더 정보 조회: Orders 테이블에서 Order_id, Order_time 가져오기
    const orderHeaderResult = await pool.request()
      .input('orderId', orderId)
      .query(`
        SELECT order_id AS id,
               order_time
        FROM Orders
        WHERE order_id = @orderId
      `);
    const orderHeader = orderHeaderResult.recordset[0];

    // 2) 주문 아이템 리스트 조회: Orders_Menu와 Menu 테이블 조인
    const orderItemsResult = await pool.request()
      .input('orderId', orderId)
      .query(`
        SELECT m.menu_id   AS id,
               m.name      AS name,
               m.price     AS price,
               om.quantity AS quantity
        FROM Orders_Menu om
        JOIN Menu m ON om.menu_id = m.menu_id
        WHERE om.order_id = @orderId
      `);
    const orderItems = orderItemsResult.recordset;

    // 헤더와 아이템을 합친 JSON 반환
    res.json({ header: orderHeader, items: orderItems });
  } catch (err) {
    console.error('[API] /api/order/:id error:', err);
    res.status(500).json({ error: err.message });
  }
});

// 9) 서버 시작
const port = process.env.PORT || 3006;
app.listen(port, '0.0.0.0', () =>
  console.log(`API 서버 실행: http://0.0.0.0:${port}`)
);