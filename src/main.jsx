import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { ConfigProvider } from 'antd';
import frFR from 'antd/locale/fr_FR';
import dayjs from 'dayjs';
import 'dayjs/locale/fr';
import App from './App';
import './styles/global.css';

dayjs.locale('fr');

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ConfigProvider locale={frFR} theme={{ token: { borderRadius: 8 } }}>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </ConfigProvider>
  </StrictMode>
);
