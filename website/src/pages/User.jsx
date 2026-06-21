import Sidebar from "../components/Sidebar";
import { useEffect, useState } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export default function Pembeli() {
    const [users, setUsers] = useState([]);
    const [search, setSearch] = useState("");
    const [currentPage, setCurrentPage] = useState(1);

    const [showModal, setShowModal] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);

    const [selectedUser, setSelectedUser] = useState(null);

    const [username, setUsername] = useState("");
    const [email, setEmail] = useState("");
    const [noTelp, setNoTelp] = useState("");
    const [password, setPassword] = useState("");

    const openEditModal = (user) => {
        setSelectedUser(user);

        setUsername(user.username);
        setEmail(user.email);
        setNoTelp(user.no_telp);
        setPassword("");

        setShowEditModal(true);
    };

    const [formData, setFormData] = useState({
        username: "",
        email: "",
        no_telp: "",
        password: "",
        role: "",
    });

    const getPembeli = async () => {
        try {
            const token = localStorage.getItem("token");

            const response = await axios.get(
                "http://127.0.0.1:8000/api/users",
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                }
            );

            setUsers(response.data.data);
        } catch (error) {
            console.error(error);
        }
    };

    useEffect(() => {
        getPembeli();
    }, []);

    const filteredUsers = users.filter((user) => {
        const keyword = search.toLowerCase();

        return (
            user.username?.toLowerCase().includes(keyword) ||
            user.email?.toLowerCase().includes(keyword) ||
            user.no_telp?.toLowerCase().includes(keyword) ||
            user.role?.nama_role?.toLowerCase().includes(keyword)
        );
    });

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            const token = localStorage.getItem("token");

            await axios.post(
                "http://127.0.0.1:8000/api/users",
                formData,
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                }
            );

            toast.success("Berhasil menambahkan user");

            setShowModal(false);

            setFormData({
                username: "",
                email: "",
                no_telp: "",
                password: "",
                role: "",
            });

            getPembeli();
        } catch (error) {
            console.error(error);
            toast.error("Gagal menambahkan user");
        }

        setShowModal(false);
    };

    const itemsPerPage = 10;

    const lastIndex = currentPage * itemsPerPage;

    const firstIndex = lastIndex - itemsPerPage;

    const currentUsers = filteredUsers.slice(firstIndex, lastIndex);

    const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);

    const deleteUser = async (id) => {
        try {
            const token = localStorage.getItem("token");

            await axios.delete(
                `http://127.0.0.1:8000/api/users/${id}`,
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                }
            );

            toast.success("User berhasil dihapus");

            getPembeli();

        } catch (error) {
            console.error(error);
            toast.error("Gagal menghapus user");
        }
    };

    const updateUser = async () => {
        try {
            const token = localStorage.getItem("token");

            await axios.put(
                `http://127.0.0.1:8000/api/users/${selectedUser.id}`,
                {
                    username,
                    email,
                    no_telp: noTelp,
                    password, // optional
                },
                {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                }
            );

            toast.success("User berhasil diupdate 🎉");

            setShowEditModal(false);

            setUsername("");
            setEmail("");
            setNoTelp("");
            setPassword("");

            getPembeli();
        } catch (error) {
            console.log(error);
            toast.error("Gagal update user 😢");
        }
    };

    return (
        <>
            <div className="flex bg-gray-100 min-h-screen">

                <Sidebar />

                <div className="flex-1 p-6">
                    <div className="flex justify-between items-center mb-6">
                        <h2 className="text-2xl font-semibold">Daftar User</h2>

                        <button
                            className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg shadow transition"
                            onClick={() => setShowModal(true)}
                        >
                            + Tambah User
                        </button>
                    </div>

                    <div className="mb-4">
                        <input
                            type="text"
                            placeholder="Cari User..."
                            className="w-full md:w-1/3 bg-white border border-gray-300 rounded-lg px-4 py-2 shadow-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-200"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                        />
                    </div>

                    <div className="bg-white rounded-xl shadow overflow-hidden">
                        <table className="w-full text-sm">
                            <thead className="bg-orange-100 text-orange-600 uppercase text-xs">
                                <tr>
                                    <th className="p-3 text-center">No</th>
                                    <th className="p-3 text-left">Username</th>
                                    <th className="p-3 text-left">Email</th>
                                    <th className="p-3 text-left">No Telp</th>
                                    <th className="p-3 text-left">Role</th>
                                    <th className="p-3 text-center">Aksi</th>
                                </tr>
                            </thead>

                            <tbody className="text-gray-700">

                                {currentUsers.map((user, index) => (
                                    <tr
                                        key={user.id}
                                        className="border-t hover:bg-gray-50 transition"
                                    >
                                        <td className="p-3 text-center">
                                            {firstIndex + index + 1}
                                        </td>

                                        <td className="p-3 font-medium">
                                            {user.username}
                                        </td>

                                        <td className="p-3">
                                            {user.email}
                                        </td>

                                        <td className="p-3">
                                            {user.no_telp}
                                        </td>

                                        <td className="p-3">
                                            <span className={`px-2 py-1 rounded text-xs font-medium ${
                                                user.role?.nama_role === "admin"
                                                    ? "bg-red-100 text-red-600"
                                                    : user.role?.nama_role === "seller"
                                                    ? "bg-blue-100 text-blue-600"
                                                    : "bg-green-100 text-green-600"
                                            }`}>
                                                {user.role.nama_role}
                                            </span>
                                        </td>

                                        <td className="p-3">
                                            <div className="flex justify-center gap-2">
                                                <button className="px-3 py-1 text-xs bg-blue-500 hover:bg-blue-600 text-white rounded" onClick={() => openEditModal(user)}>
                                                    Edit
                                                </button>

                                                <button className="px-3 py-1 text-xs bg-red-500 hover:bg-red-600 text-white rounded" onClick={() => deleteUser(user.id)}>
                                                    Hapus
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>

                        <div className="flex justify-center items-center gap-2 mt-4 pb-4">

                            <button
                                onClick={() => setCurrentPage(currentPage - 1)}
                                disabled={currentPage === 1}
                                className="px-3 py-1 rounded bg-gray-200 text-black disabled:opacity-50"
                            >
                                Prev
                            </button>

                            {[...Array(totalPages)].map((_, index) => (
                                <button
                                    key={index}
                                    onClick={() => setCurrentPage(index + 1)}
                                    className={`px-3 py-1 rounded ${
                                        currentPage === index + 1
                                            ? "bg-orange-500 text-white"
                                            : "bg-gray-200 text-black"
                                    }`}
                                >
                                    {index + 1}
                                </button>
                            ))}

                            <button
                                onClick={() => setCurrentPage(currentPage + 1)}
                                disabled={currentPage === totalPages}
                                className="px-3 py-1 rounded bg-gray-200 text-black disabled:opacity-50"
                            >
                                Next
                            </button>

                        </div>
                    </div>
                </div>
            </div>

            {showModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-xl shadow-lg w-full max-w-md p-6">
                        <h2 className="text-xl font-semibold mb-4">
                            Tambah User
                        </h2>

                        <form onSubmit={handleSubmit} className="space-y-4">

                            <input
                                type="text"
                                name="username"
                                placeholder="Username"
                                value={formData.username}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-3 py-2"
                                required
                            />

                            <input
                                type="email"
                                name="email"
                                placeholder="Email"
                                value={formData.email}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-3 py-2"
                                required
                            />

                            <input
                                type="text"
                                name="no_telp"
                                placeholder="Nomor Telepon"
                                value={formData.no_telp}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-3 py-2"
                                required
                            />

                            <input
                                type="password"
                                name="password"
                                placeholder="Password"
                                value={formData.password}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-3 py-2"
                                required
                            />

                            <select
                                name="role"
                                value={formData.role}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-3 py-2"
                            >
                                <option value="">Pilih Role</option>
                                <option value="seller">Seller</option>
                                <option value="pembeli">Pembeli</option>
                            </select>

                            <div className="flex justify-end gap-2 pt-2">
                                <button
                                    type="button"
                                    onClick={() => setShowModal(false)}
                                    className="px-4 py-2 rounded-lg bg-gray-200 hover:bg-gray-300"
                                >
                                    Batal
                                </button>

                                <button
                                    type="submit"
                                    className="px-4 py-2 rounded-lg bg-orange-500 text-white hover:bg-orange-600"
                                >
                                    Simpan
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {showEditModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white rounded-xl shadow-lg w-full max-w-md p-6">

                        <h2 className="text-xl font-semibold mb-4">
                            Edit User
                        </h2>

                        <div className="space-y-3">

                            <input
                                type="text"
                                placeholder="Username"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                className="w-full border rounded-lg px-3 py-2"
                            />

                            <input
                                type="email"
                                placeholder="Email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="w-full border rounded-lg px-3 py-2"
                            />

                            <input
                                type="text"
                                placeholder="No Telp"
                                value={noTelp}
                                onChange={(e) => setNoTelp(e.target.value)}
                                className="w-full border rounded-lg px-3 py-2"
                            />

                            <input
                                type="password"
                                placeholder="Password (kosongkan jika tidak diubah)"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full border rounded-lg px-3 py-2"
                            />
                        </div>

                        <div className="flex justify-end gap-3 mt-5">

                            <button
                                onClick={() => setShowEditModal(false)}
                                className="px-4 py-2 bg-gray-200 rounded-lg"
                            >
                                Batal
                            </button>

                            <button
                                onClick={updateUser}
                                className="px-4 py-2 bg-orange-500 text-white rounded-lg"
                            >
                                Update
                            </button>

                        </div>

                    </div>
                </div>
            )}
        </>
    );
}