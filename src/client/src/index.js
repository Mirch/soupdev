import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Profile } from './pages/profile';
import 'bootstrap/dist/css/bootstrap.min.css';
import { PaymentSuccessful } from './pages/paymentSuccessful';
import { PaymentCancelled } from './pages/paymentCancelled';


ReactDOM.render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<App />} />
        <Route path="/profile" element={<Profile />}>
          <Route exact strict sensitive path=":username" element={<Profile />} />
        </Route>
        <Route path="/payment/success" element={<PaymentSuccessful />} />
        <Route path="/payment/cancel" element={<PaymentCancelled />} />
      </Routes>
    </BrowserRouter>
  </React.StrictMode>,
  document.getElementById('root')
);
