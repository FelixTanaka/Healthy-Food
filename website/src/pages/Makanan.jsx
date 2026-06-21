import Sidebar from "../components/Sidebar";
import { useState, useEffect } from "react";
import axios from "axios";
import { toast } from "react-toastify";

export default function Makanan() {
    const [showModal, setShowModal] = useState(false);
    const [makanan, setMakanan] = useState([]);
    const [selectedMakanan, setSelectedMakanan] = useState(null);
    const [search, setSearch] = useState("");

    const fetchData = async () => {
        try {

            const response = await axios.get(
                "http://127.0.0.1:8000/api/semua-makanan",
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            setMakanan(response.data.data);

        } catch (error) {
            console.log(error);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const approveMakanan = async (id) => {
        try {

            await axios.put(
                `http://127.0.0.1:8000/api/makanan/${id}/approve`,
                {},
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            fetchData();

            toast.success("Makanan berhasil dikonfirmasi");

        } catch (error) {
            console.log(error);
        }
    };

    const rejectMakanan = async (id) => {
        try {

            await axios.put(
                `http://127.0.0.1:8000/api/makanan/${id}/reject`,
                {},
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            fetchData();

            toast.error("Makanan berhasil ditolak");

        } catch (error) {
            console.log(error);
        }
    };

    const deleteMakanan = async (id) => {
        try {

            await axios.delete(
                `http://127.0.0.1:8000/api/admin/makanan/${id}`,
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            fetchData();

            toast.success("Makanan berhasil dihapus");

        } catch (error) {
            console.log(error);

            toast.error("Gagal menghapus makanan");
        }
    };

    const filteredMakanan = makanan.filter((item) =>
        item.nama_makanan.toLowerCase().includes(search.toLowerCase()) ||

        item.status.toLowerCase().includes(search.toLowerCase()) ||

        item.kategori.nama_kategori.toLowerCase().includes(search.toLowerCase()) ||

        item.seller.nama_toko.toLowerCase().includes(search.toLowerCase()) ||

        item.harga.toString().includes(search) ||

        item.kalori.toString().includes(search) ||

        item.protein.toString().includes(search) ||

        item.karbohidrat.toString().includes(search) ||

        item.lemak.toString().includes(search)
    );

    const [currentPage, setCurrentPage] = useState(1);

    const itemsPerPage = 10;

    const lastIndex = currentPage * itemsPerPage;

    const firstIndex = lastIndex - itemsPerPage;

    const currentItems = filteredMakanan.slice(firstIndex, lastIndex);

    const totalPages = Math.ceil(filteredMakanan.length / itemsPerPage);

    return (
        <div className="flex bg-gray-100 min-h-screen">

            <Sidebar />

            <div className="flex-1 p-6">

                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-semibold">Menu Makanan</h2>
                </div>

                <div className="mb-4">
                    <input
                        type="text"
                        placeholder="Cari Makanan..."
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
                            <th className="p-3 text-left">Nama Makanan</th>
                            <th className="p-3 text-left">Kategori</th>
                            <th className="p-3 text-left">Harga</th>
                            <th className="p-3 text-left">Nama Toko</th>
                            <th className="p-3 text-center">Protein</th>
                            <th className="p-3 text-center">Karbo</th>
                            <th className="p-3 text-center">Lemak</th>
                            <th className="p-3 text-center">Kalori</th>
                            <th className="p-3 text-center">Status</th>
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

                                    <td className="p-3 font-medium">
                                        {item.nama_makanan}
                                    </td>

                                    <td className="p-3">
                                        {item.kategori.nama_kategori}
                                    </td>

                                    <td className="p-3">
                                        Rp {item.harga}
                                    </td>

                                    <td className="p-3">
                                        {item.seller.nama_toko}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.protein}g
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.karbohidrat}g
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.lemak}g
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.kalori} kcal
                                    </td>

                                    <td className="p-3 text-center">
                                        <span
                                            className={`px-3 py-1 rounded-full text-xs font-medium ${
                                                item.status === "dikonfirmasi"
                                                    ? "bg-green-100 text-green-600"
                                                    : item.status === "pending"
                                                    ? "bg-orange-100 text-orange-600"
                                                    : "bg-red-100 text-red-600"
                                            }`}
                                        >
                                            {item.status}
                                        </span>
                                    </td>

                                    <td className="p-3">
                                        <div className="flex justify-center gap-2">

                                            {item.status === "pending" ? (
                                                <>
                                                    <button className="w-8 h-8 rounded-full bg-green-500 text-white" onClick={() => approveMakanan(item.id)}>
                                                        ✓
                                                    </button>

                                                    <button className="w-8 h-8 rounded-full bg-red-500 text-white" onClick={() => rejectMakanan(item.id)}>
                                                        ✕
                                                    </button>
                                                </>
                                            ) : (
                                                <>
                                                    <button
                                                        className="px-3 py-1 text-xs bg-blue-500 text-white rounded"
                                                        onClick={() => {
                                                            setShowModal(true);
                                                            setSelectedMakanan(item);
                                                        }}
                                                    >
                                                        Detail
                                                    </button>

                                                    <button
                                                        className="px-3 py-1 text-xs bg-red-500 text-white rounded" onClick={()=> deleteMakanan(item.id)}
                                                    >
                                                        Hapus
                                                    </button>
                                                </>
                                            )}

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

            {showModal && (
                <div className="fixed inset-0 backdrop-blur-sm bg-black/30 flex items-center justify-center z-50">
                    <div className="bg-white/90 backdrop-blur-lg rounded-2xl shadow-2xl w-full max-w-3xl p-6 border border-white/20">
                        <div className="flex justify-between items-center mb-5">
                            <h2 className="text-xl font-semibold text-gray-800">
                                Detail Makanan
                            </h2>
                            <button 
                                onClick={() => setShowModal(false)}
                                className="text-gray-400 hover:text-gray-600 text-lg"
                            >
                                ✕
                            </button>
                        </div>

                        <div className="flex gap-6">
                            <div className="w-1/3">
                                <img
                                    src={`http://127.0.0.1:8000/storage/${selectedMakanan.gambar_makanan}`}
                                    alt="makanan"
                                    className="w-full h-48 object-cover rounded-xl shadow"
                                />

                                <div className="mt-3">
                                    <span className="px-3 py-1 text-xs rounded-full bg-green-100 text-green-600 font-medium">
                                        {selectedMakanan.status}
                                    </span>
                                </div>
                            </div>

                            <div className="w-2/3 flex flex-col justify-between">
                                <div className="space-y-3 text-sm text-gray-700">
                                    <div>
                                        <p className="text-gray-400">Nama</p>
                                        <p className="font-semibold text-lg">{selectedMakanan.nama_makanan}</p>

                                        <p className="text-sm text-gray-400 mt-1">Toko</p>
                                        <p className="text-sm font-medium text-gray-700">{selectedMakanan.seller.nama_toko}</p>
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Kategori</p>
                                        <p>{selectedMakanan.kategori.nama_kategori}</p>
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Harga</p>
                                        <p className="text-orange-500 font-medium">Rp {selectedMakanan.harga}</p>
                                    </div>

                                    <div className="grid grid-cols-4 gap-3 mt-2">

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Kalori</p>
                                            <p className="font-semibold">{selectedMakanan.kalori}</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Protein</p>
                                            <p className="font-semibold">{selectedMakanan.protein}g</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Karbo</p>
                                            <p className="font-semibold">{selectedMakanan.karbohidrat}g</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Lemak</p>
                                            <p className="font-semibold">{selectedMakanan.lemak}g</p>
                                        </div> 
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Deskripsi</p>
                                        <p className="leading-relaxed">
                                            {selectedMakanan.deskripsi}
                                        </p>
                                    </div>
                                </div>

                                <div className="flex justify-end gap-3 mt-6">
                                    <button
                                        onClick={() => setShowModal(false)}
                                        className="px-4 py-2 rounded-lg bg-gray-200 hover:bg-gray-300 text-sm"
                                    >
                                        Batal
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}