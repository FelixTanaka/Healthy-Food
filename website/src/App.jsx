import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Seller from "./pages/Seller";
import Makanan from "./pages/Makanan";
import Dashboard from "./pages/Dashboard";
import Pembeli from "./pages/Pembeli";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/seller" element={<Seller />} />
        <Route path="/makanan" element={<Makanan />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/pembeli" element={<Pembeli />} />
      </Routes>
    </BrowserRouter>
  );
}