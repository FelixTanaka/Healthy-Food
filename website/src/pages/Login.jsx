import Logo from "../assets/Logo.png";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { useState } from "react";
import { toast } from "react-toastify";


export default function Login() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
      try {

          const response = await axios.post(
              "http://127.0.0.1:8000/api/login",
              {
                  email: email,
                  password: password,
              }
          );

          console.log(response.data);

          localStorage.setItem("token", response.data.token);

          toast.success("Login berhasil!");

          setTimeout(() => {
              navigate("/dashboard");
          }, 1500);

      } catch (error) {

          console.log(error);

          toast.error("Email atau password salah");
      }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-orange-50">
    
      <div className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md">

        <div className="flex flex-col items-center mb-6">
          <img
            src={Logo}
            alt="Logo"
            className="w-30 mb-2 brightness-0 saturate-100 invert-[48%] sepia-[93%] saturate-[500%] hue-rotate-[10deg]"
          />
          <h1 className="text-2xl font-bold text-orange-500">
            Healthy Food
          </h1>
        </div>

        <div className="mb-4">
          <label className="block text-m mb-1">Email</label>
          <input
            type="email"
            placeholder="Masukkan email"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-400"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <div className="mb-4">
          <label className="block text-m mb-1">Password</label>
          <input
            type="password"
            placeholder="Masukkan password"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-400"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>

        <button className="w-full bg-orange-500 hover:bg-orange-600 text-white py-2 rounded-lg transition" onClick={() => handleLogin()}>
          Login
        </button>

      </div>
    </div>
  );
}