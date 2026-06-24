import Sidebar from "../components/Sidebar";
import { useState } from "react";
import { useEffect } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export default function Selller() {
    const [showModal, setShowModal] = useState(false);
    const [seller, setSeller] = useState([]);
    const [search, setSearch] = useState("");
    const [selectedSeller, setSelectedSeller] = useState(null);

    const [showEditModal, setShowEditModal] = useState(false);

    const [namaToko, setNamaToko] = useState("");
    const [alamat, setAlamat] = useState("");
    const [deskripsi, setDeskripsi] = useState("");

    const getSeller = async () => {
        try {
            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/sellers",
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            setSeller(response.data.data);
        } catch (error) {
            console.log(error);
        }
    };

    useEffect(() => {
        getSeller();
    }, []);

    const filteredSeller = seller.filter((item) => {
        const keyword = search.toLowerCase();

        return (
            item.user?.username?.toLowerCase().includes(keyword) ||
            item.user?.no_telp?.toLowerCase().includes(keyword) ||
            item.nama_toko?.toLowerCase().includes(keyword) ||
            item.alamat?.toLowerCase().includes(keyword)
        );
    });

    const [currentPage, setCurrentPage] = useState(1);

    const itemsPerPage = 10;

    const lastIndex = currentPage * itemsPerPage;
    const firstIndex = lastIndex - itemsPerPage;

    const currentItems = filteredSeller.slice(
        firstIndex,
        lastIndex
    );

    const totalPages = Math.ceil(
        filteredSeller.length / itemsPerPage
    );

    const updateSeller = async () => {
        try {
            const response = await axios.put(
                `http://127.0.0.1:8000/api/seller/${selectedSeller.id}`,
                {
                    nama_toko: namaToko,
                    alamat: alamat,
                    deskripsi: deskripsi,
                },
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            toast.success("Seller berhasil diupdate 🎉");

            setShowEditModal(false);
            getSeller();

            console.log(response.data);
        } catch (error) {
            console.log(error);
            toast.error("Gagal update seller 😢");
        }
    };

    const openEditModal = (item) => {
        setSelectedSeller(item);

        setNamaToko(item.nama_toko || "");
        setAlamat(item.alamat || "");
        setDeskripsi(item.deskripsi || "");

        setShowEditModal(true);
    };

    const deleteSeller = async (id) => {
        try {
            const response = await axios.delete(
                `http://127.0.0.1:8000/api/seller/${id}`,
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            toast.success("Seller berhasil dihapus 🗑️");

            getSeller(); 
            console.log(response.data);
        } catch (error) {
            console.log(error);
            toast.error("Gagal menghapus seller 😢");
        }
    };

    return (
        <div className="flex bg-gray-100 min-h-screen">
            <Sidebar />

            <div className="flex-1 p-6">
                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-semibold">Seller</h2>
                </div>

                <div className="mb-4">
                    <input
                        type="text"
                        placeholder="Cari seller..."
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
                            <th className="p-3 text-left">No Telp</th>
                            <th className="p-3 text-left">Nama Toko</th>
                            <th className="p-3 text-left">Alamat</th>
                            <th className="p-3 text-center">Jam Buka</th>
                            <th className="p-3 text-center">Jam Tutup</th>
                            <th className="p-3 text-center">Jumlah Makanan</th>
                            <th className="p-3 text-center">Aksi</th>
                        </tr>
                        </thead>

                        <tbody className="text-gray-700">
                        
                            {currentItems.map((item, index) => (
                                <tr
                                    key={item.id}
                                    className="border-t hover:bg-gray-50 transition"
                                >
                                    <td className="p-3 text-center">
                                        {firstIndex + index + 1}
                                    </td>

                                    <td className="p-3">
                                        {item.user?.username}
                                    </td>

                                    <td className="p-3">
                                        {item.user?.no_telp}
                                    </td>

                                    <td className="p-3">
                                        {item.nama_toko || "-"}
                                    </td>

                                    <td className="p-3">
                                        {item.alamat || "-"}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.jam_buka || "-"}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.jam_tutup || "-"}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.makanan_count}
                                    </td>

                                    <td className="p-3">
                                        <div className="flex justify-center gap-2">
                                            <button
                                                className="px-3 py-1 text-xs bg-blue-500 text-white rounded"
                                                onClick={() => {
                                                    setSelectedSeller(item);
                                                    setShowModal(true);
                                                }}
                                            >
                                                Detail
                                            </button>

                                            <button className="px-3 py-1 text-xs bg-red-500 text-white rounded" onClick={() => deleteSeller(item.id)}>
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
                            className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50"
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
                                        : "bg-gray-200"
                                }`}
                            >
                                {index + 1}
                            </button>
                        ))}

                        <button
                            onClick={() => setCurrentPage(currentPage + 1)}
                            disabled={currentPage === totalPages}
                            className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50"
                        >
                            Next
                        </button>

                    </div>
                </div>
            </div>

            {showModal && (
                <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50">
                    
                    <div className="bg-white w-full max-w-xl rounded-2xl shadow-xl p-6 relative animate-fadeIn">

                        <div className="-mx-6 px-6 flex justify-between items-center border-b pb-3 mb-4">
                            <h2 className="text-lg font-semibold text-gray-800">
                                Detail Seller
                            </h2>

                            <button
                                onClick={() => setShowModal(false)}
                                className="text-gray-400 hover:text-gray-700 text-lg"
                            >
                                ✕
                            </button>
                        </div>

                        <div className="flex flex-col items-center mb-6">
                            <img
                                src={
                                    selectedSeller?.foto_toko
                                        ? `http://127.0.0.1:8000/storage/${selectedSeller.foto_toko}`
                                        : "https://via.placeholder.com/120"
                                }
                                alt="Foto Toko"
                                className="w-28 h-28 rounded-full object-cover border shadow"
                            />

                            <h3 className="mt-3 text-lg font-semibold">
                                {selectedSeller?.nama_toko || "-"}
                            </h3>
                        </div>

                        <div className="grid grid-cols-2 gap-4 text-sm text-gray-700">

                            <div>
                                <p className="text-gray-500">Username</p>
                                <p className="font-medium">
                                    {selectedSeller?.user?.username || "-"}
                                </p>
                            </div>

                            <div>
                                <p className="text-gray-500">Email</p>
                                <p className="font-medium">
                                    {selectedSeller?.user?.email || "-"}
                                </p>
                            </div>

                            <div>
                                <p className="text-gray-500">No Telp</p>
                                <p className="font-medium">
                                    {selectedSeller?.user?.no_telp || "-"}
                                </p>
                            </div>

                            <div>
                                <p className="text-gray-500">Jumlah Makanan</p>
                                <p className="font-medium">
                                    {selectedSeller?.makanan_count || 0}
                                </p>
                            </div>

                            <div className="col-span-2">
                                <p className="text-gray-500">Alamat</p>
                                <p className="font-medium">
                                    {selectedSeller?.alamat || "-"}
                                </p>
                            </div>

                            <div className="col-span-2">
                                <p className="text-gray-500">Deskripsi</p>
                                <p className="font-medium">
                                    {selectedSeller?.deskripsi || "-"}
                                </p>
                            </div>

                        </div>

                        <div className="mt-6 flex justify-end gap-2">
                            <button
                                onClick={() => setShowModal(false)}
                                className="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg text-sm"
                            >
                                Tutup
                            </button>

                            <button
                                onClick={() => {
                                    setShowModal(false);
                                    openEditModal(selectedSeller);
                                }}
                                className="px-4 py-2 bg-orange-500 hover:bg-orange-600 text-white rounded-lg text-sm"
                            >
                                Edit
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {showEditModal && (
                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
                    <div className="bg-white w-full max-w-lg p-6 rounded-xl shadow-lg">

                        <h2 className="text-lg font-semibold mb-4">
                            Edit Seller
                        </h2>

                        <input
                            className="w-full border px-3 py-2 mb-2 rounded"
                            placeholder="Nama Toko"
                            value={namaToko}
                            onChange={(e) => setNamaToko(e.target.value)}
                        />

                        <input
                            className="w-full border px-3 py-2 mb-2 rounded"
                            placeholder="Alamat"
                            value={alamat}
                            onChange={(e) => setAlamat(e.target.value)}
                        />

                        <textarea
                            className="w-full border px-3 py-2 mb-3 rounded"
                            placeholder="Deskripsi"
                            value={deskripsi}
                            onChange={(e) => setDeskripsi(e.target.value)}
                        />

                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setShowEditModal(false)}
                                className="px-3 py-1 bg-gray-300 rounded"
                            >
                                Batal
                            </button>

                            <button
                                onClick={updateSeller}
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