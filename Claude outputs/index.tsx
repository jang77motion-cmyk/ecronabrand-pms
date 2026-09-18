import React from 'react';

export default function Home() {
  return (
    <div style={{ padding: '40px', fontFamily: 'system-ui, sans-serif' }}>
      <h1>🚀 Ecronabrand PMS</h1>
      <h2>Product Management System</h2>

      <div style={{ marginTop: '30px', color: '#666' }}>
        <p>Backend API가 정상 작동 중입니다.</p>
        <p>API 문서: <a href="http://localhost:3001/api/docs" target="_blank">http://localhost:3001/api/docs</a></p>
      </div>

      <div style={{ marginTop: '20px', padding: '20px', backgroundColor: '#f5f5f5', borderRadius: '8px' }}>
        <h3>다음 단계</h3>
        <ul>
          <li>재고 관리 모듈 구현</li>
          <li>주문 관리 시스템 개발</li>
          <li>분석 대시보드 구성</li>
        </ul>
      </div>
    </div>
  );
}
