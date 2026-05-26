import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Seller from "./pages/Seller";
import Makanan from "./pages/Makanan";
import Dashboard from "./pages/Dashboard";
import Pembeli from "./pages/Pembeli";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

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


      <ToastContainer
        position="top-right"
        autoClose={2000}
      />
    </BrowserRouter>
  );
}