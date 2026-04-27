export default function Login() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-orange-50">
      
      {/* CARD */}
      <div className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-sm">

        {/* LOGO */}
        <div className="flex flex-col items-center mb-6">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1046/1046784.png"
            alt="Logo"
            className="w-16 mb-2"
          />
          <h1 className="text-xl font-bold text-orange-500">
            Healthy Food
          </h1>
        </div>

        {/* EMAIL */}
        <div className="mb-4">
          <label className="block text-sm mb-1">Email</label>
          <input
            type="email"
            placeholder="Masukkan email"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-400"
          />
        </div>

        {/* PASSWORD */}
        <div className="mb-4">
          <label className="block text-sm mb-1">Password</label>
          <input
            type="password"
            placeholder="Masukkan password"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-orange-400"
          />
        </div>

        {/* BUTTON */}
        <button className="w-full bg-orange-500 hover:bg-orange-600 text-white py-2 rounded-lg transition">
          Login
        </button>

      </div>
    </div>
  );
}