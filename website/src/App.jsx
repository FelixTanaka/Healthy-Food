import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Seller from "./pages/Seller";
import Makanan from "./pages/Makanan";
import Dashboard from "./pages/Dashboard";
import User from "./pages/User";
import Transaksi from "./pages/Transaksi";
import Kategori from "./pages/Kategori";
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
        <Route path="/user" element={<User />} />
        <Route path="/transaksi" element={<Transaksi />} />
        <Route path="/kategori" element={<Kategori />} />
      </Routes>


      <ToastContainer
        position="top-right"
        autoClose={2000}
      />
    </BrowserRouter>
  );
}