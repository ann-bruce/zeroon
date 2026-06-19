import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ConfigProvider } from 'antd'
import App from './App'
import './styles.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ConfigProvider
      theme={{
        token: {
          colorPrimary: '#55C7D9',
          borderRadius: 12,
          colorBgBase: '#F7F2E8',
          colorTextBase: '#18202A',
        },
      }}
    >
      <App />
    </ConfigProvider>
  </StrictMode>,
)

