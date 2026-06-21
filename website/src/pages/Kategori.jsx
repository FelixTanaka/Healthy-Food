import Sidebar from "../components/Sidebar";
import { useEffect, useState } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export default function Kategori() {
    const [kategori, setKategori] = useState([]);
    const [namaKategori, setNamaKategori] = useState("");
    const [showModal, setShowModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [selectedKategori, setSelectedKategori] = useState(null);
    const [search, setSearch] = useState("");
    const getKategori = async () => {
        try {
            const response = await axios.get(
                "http://127.0.0.1:8000/api/kategori",
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            setKategori(response.data.data);
        } catch (error) {
            console.log(error);
        }
    };

    useEffect(() => {
        getKategori();
    }, []);

    const tambahKategori = async () => {
        try {
            const response = await axios.post(
                "http://127.0.0.1:8000/api/kategori",
                {
                    nama_kategori: namaKategori,
                },
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            toast.success("Kategori berhasil ditambahkan 🎉");

            setNamaKategori("");
            setShowModal(false);
            getKategori();
            console.log(response.data);
        } catch (error) {
            console.log(error);
            toast.error("Gagal menambahkan kategori 😢");
        }
    };

    const updateKategori = async () => {
        try {
            const response = await axios.put(
                `http://127.0.0.1:8000/api/kategori/${selectedKategori.id}`,
                {
                    nama_kategori: namaKategori,
                },
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            toast.success("Kategori berhasil diupdate 🎉");

            setShowEditModal(false);
            setNamaKategori("");
            getKategori();
            console.log(response.data);
        } catch (error) {
            console.log(error);
            toast.error("Gagal mengupdate kategori 😢");
        }
    };

    const deleteKategori = async (id) => {
        try {
            const response = await axios.delete(
                `http://127.0.0.1:8000/api/kategori/${id}`,
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            toast.success("Kategori berhasil dihapus 🗑️");

            getKategori();
            console.log(response.data);
        } catch (error) {
            console.log(error);
            toast.error("Gagal menghapus kategori 😢");
        }
    };

    const openEditModal = (item) => {
        setSelectedKategori(item);
        setNamaKategori(item.nama_kategori);
        setShowEditModal(true);
    };

    const filteredKategori = kategori.filter((item) =>
        item.nama_kategori
            .toLowerCase()
            .includes(search.toLowerCase())
    );

    return (
        <div className="flex bg-gray-100 min-h-screen">
            <Sidebar />

            <div className="flex-1 p-6">

                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-semibold">Kategori</h2>
                    <button
                        onClick={() => setShowModal(true)}
                        className="bg-orange-500 text-white px-4 py-2 rounded-lg text-sm"
                    >
                        + Tambah Kategori
                    </button>
                </div>

                <div className="mb-4">
                    <input
                        type="text"
                        placeholder="Cari kategori..."
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
                                <th className="p-3 text-center">Nama Kategori</th>
                                <th className="p-3 text-center">Aksi</th>
                            </tr>
                        </thead>

                        <tbody className="text-gray-700">
                            {filteredKategori.map((item, index) => (
                                <tr
                                    key={item.id}
                                    className="border-t hover:bg-gray-50 transition"
                                >
                                    <td className="p-3 text-center">
                                        {index + 1}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.nama_kategori}
                                    </td>

                                    <td className="p-3 text-center">
                                        <div className="flex justify-center gap-2">
                                            <button className="px-3 py-1 text-xs bg-blue-500 text-white rounded" onClick={() => openEditModal(item)}>
                                                Edit
                                            </button>

                                            <button className="px-3 py-1 text-xs bg-red-500 text-white rounded" onClick={() => deleteKategori(item.id)}>
                                                Hapus
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

            </div>

            {showModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center">
                    <div className="bg-white p-6 rounded-xl w-96 shadow-lg">
                        
                        <h2 className="text-lg font-semibold mb-4">
                            Tambah Kategori
                        </h2>

                        <input
                            type="text"
                            placeholder="Nama kategori"
                            className="w-full border px-3 py-2 rounded-lg mb-4"
                            value={namaKategori}
                            onChange={(e) => setNamaKategori(e.target.value)}
                        />

                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setShowModal(false)}
                                className="px-3 py-1 bg-gray-300 rounded"
                            >
                                Batal
                            </button>

                            <button
                                onClick={tambahKategori}
                                className="px-3 py-1 bg-orange-500 text-white rounded"
                            >
                                Simpan
                            </button>
                        </div>

                    </div>
                </div>
            )}

            {showEditModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white p-6 rounded-xl w-96 shadow-lg">

                        <h2 className="text-lg font-semibold mb-4">
                            Edit Kategori
                        </h2>

                        <input
                            type="text"
                            className="w-full border px-3 py-2 rounded-lg mb-4"
                            value={namaKategori}
                            onChange={(e) => setNamaKategori(e.target.value)}
                        />

                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setShowEditModal(false)}
                                className="px-3 py-1 bg-gray-300 rounded"
                            >
                                Batal
                            </button>

                            <button
                                onClick={updateKategori}
                                className="px-3 py-1 bg-orange-500 text-white rounded"
                            >
                                Update
                            </button>
                        </div>

                    </div>
                </div>
            )}
        </div>
    );
}