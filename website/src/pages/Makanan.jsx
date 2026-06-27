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

    const bahan =
    typeof selectedMakanan?.bahan === "string"
        ? JSON.parse(selectedMakanan.bahan)
        : selectedMakanan?.bahan || [];

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

                                    <td className="p-3">
                                        <div className="flex justify-center items-center gap-2">
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
                                                className="px-3 py-1 text-xs bg-red-500 text-white rounded"
                                                onClick={() => deleteMakanan(item.id)}
                                            >
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

            {showModal && selectedMakanan && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">

                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[85vh] overflow-hidden">

                        <div className="flex justify-between items-center px-6 py-4 border-b bg-gradient-to-r from-orange-500 to-orange-400">

                            <div>
                                <h2 className="text-xl font-bold text-white">
                                    Detail Makanan
                                </h2>
                                <p className="text-sm text-orange-100">
                                    Informasi lengkap menu
                                </p>
                            </div>

                            <button
                                onClick={() => setShowModal(false)}
                                className="w-9 h-9 rounded-full bg-white/20 hover:bg-white/30 text-white transition"
                            >
                                ✕
                            </button>

                        </div>

                        <div className="overflow-y-auto max-h-[calc(85vh-80px)] p-6">

                            <div className="flex gap-6">

                                <div className="w-1/3">

                                    <img
                                        src={`http://127.0.0.1:8000/storage/${selectedMakanan.gambar_makanan}`}
                                        alt={selectedMakanan.nama_makanan}
                                        className="w-full h-60 object-cover rounded-xl shadow-md"
                                    />

                                </div>

                                <div className="w-2/3">

                                    <h1 className="text-2xl font-bold text-gray-800">
                                        {selectedMakanan.nama_makanan}
                                    </h1>

                                    <p className="text-gray-500 mt-1">
                                        {selectedMakanan.seller.nama_toko}
                                    </p>

                                    <div className="flex gap-2 mt-3">

                                        <span className="px-3 py-1 rounded-full bg-orange-100 text-orange-600 text-xs font-semibold">
                                            {selectedMakanan.kategori.nama_kategori}
                                        </span>

                                    </div>

                                    <div className="mt-5">

                                        <p className="text-sm text-gray-400">
                                            Harga
                                        </p>

                                        <h2 className="text-3xl font-bold text-orange-500">
                                            Rp {Number(selectedMakanan.harga).toLocaleString("id-ID")}
                                        </h2>

                                    </div>


                                    <div className="grid grid-cols-4 gap-3 mt-6">

                                        <div className="bg-orange-50 rounded-xl border h-24 flex flex-col items-center justify-center">
                                            <p className="text-sm text-gray-600">Kalori</p>
                                            <p className="font-bold text-lg text-orange-600">
                                                {selectedMakanan.kalori} Kcal
                                            </p>
                                        </div>

                                        <div className="bg-blue-50 rounded-xl border h-24 flex flex-col items-center justify-center">
                                            <p className="text-sm text-gray-600">Protein</p>
                                            <p className="font-bold text-lg text-blue-600">
                                                {selectedMakanan.protein} g
                                            </p>
                                        </div>

                                        <div className="bg-yellow-50 rounded-xl border h-24 flex flex-col items-center justify-center">
                                            <p className="text-sm text-gray-600">Karbo</p>
                                            <p className="font-bold text-lg text-yellow-600">
                                                {selectedMakanan.karbohidrat} g
                                            </p>
                                        </div>

                                        <div className="bg-pink-50 rounded-xl border h-24 flex flex-col items-center justify-center">
                                            <p className="text-sm text-gray-600">Lemak</p>
                                            <p className="font-bold text-lg text-pink-600">
                                                {selectedMakanan.lemak} g
                                            </p>
                                        </div>

                                    </div>

                                </div>

                            </div>


                            <div className="mt-6">

                                <h3 className="font-semibold text-gray-700 mb-3">
                                    Bahan Makanan
                                </h3>

                                <div className="border rounded-xl overflow-hidden">

                                    {bahan.map((item, index) => (

                                        <div
                                            key={index}
                                            className="flex justify-between items-center px-4 py-3 border-b last:border-b-0 hover:bg-gray-50"
                                        >

                                            <span className="font-medium text-gray-700">
                                                {item.nama_indonesia}
                                            </span>

                                            <span className="text-orange-500 font-semibold">
                                                {item.amount} {item.unit}
                                            </span>

                                        </div>

                                    ))}

                                </div>


                            </div>


                            <div className="mt-6">

                                <h3 className="font-semibold text-gray-700 mb-3">
                                    Deskripsi
                                </h3>

                                <div className="bg-gray-50 rounded-xl p-4 border">

                                    <p className="text-gray-600 leading-7 text-sm">
                                        {selectedMakanan.deskripsi || "-"}
                                    </p>

                                </div>

                            </div>

                            {/* Footer */}

                            <div className="flex justify-end mt-8">

                                <button
                                    onClick={() => setShowModal(false)}
                                    className="px-6 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-white font-medium transition"
                                >
                                    Tutup
                                </button>

                            </div>

                        </div>

                    </div>

                </div>
            )}
        </div>
    );
}