import { useLocation, Link, useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from "react-toastify";

export default function Sidebar() {
    const location = useLocation();
    const navigate = useNavigate();

    const menus = [
        { name: "Dashboard", path: "/dashboard" },
        { name: "Seller", path: "/seller" },
        { name: "Makanan", path: "/makanan" },
        { name: "User", path: "/user" },
        { name: "Transaksi", path: "/transaksi" },
        { name: "Kategori", path: "/kategori" },
    ];

    const handleLogout = async () => {
        try {
            await axios.post(
                "http://localhost:8000/api/logout",
                {},
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            localStorage.removeItem("token");
            localStorage.removeItem("user");
            toast.success("Logout berhasil!");

            navigate("/");

        } catch (error) {
            console.log(error);
        }
    };

    return (
        <div className="w-64 bg-white shadow-lg p-5 min-h-screen flex flex-col justify-between">
            <div>
                <div className="text-center mb-6 border-b border-orange-600 pb-4 -mx-5">
                    <h1 className="text-xl font-bold text-orange-500">
                        Healthy Food
                    </h1>
                </div>

                <ul className="space-y-2">
                    {menus.map((menu) => {
                        const isActive = location.pathname === menu.path;

                        return (
                            <li key={menu.path}>
                                <Link
                                    to={menu.path}
                                    className={`block px-3 py-2 rounded-lg transition ${
                                        isActive
                                            ? "bg-orange-100 text-orange-600 font-semibold"
                                            : "hover:bg-orange-100 text-gray-700"
                                    }`}
                                >
                                    {menu.name}
                                </Link>
                            </li>
                        );
                    })}
                </ul>
            </div>

            <div className="pt-4 border-t border-orange-400 -mx-5 px-5">
                <button
                    className="w-full px-3 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white transition"
                    onClick={handleLogout}
                >
                    Logout
                </button>
            </div>

        </div>
    );
}