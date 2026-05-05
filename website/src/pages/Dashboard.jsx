import Sidebar from "../components/Sidebar";
import { useState } from "react";
import { Users, Utensils, Clock, CheckCircle } from "lucide-react";

export default function Dashboard() {
    const [showModal, setShowModal] = useState(false);

    return (
        <div className="flex bg-gray-100 min-h-screen">

            <Sidebar />

            <div className="flex-1 p-6">

                <h2 className="text-2xl font-semibold mb-6">Dashboard</h2>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-blue-100 text-blue-600">
                            <Users size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Total Seller</p>
                            <h2 className="text-2xl font-bold text-blue-500">10</h2>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-orange-100 text-orange-600">
                            <Utensils size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Total Makanan</p>
                            <h2 className="text-2xl font-bold text-orange-500">25</h2>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-yellow-100 text-yellow-600">
                            <Clock size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Pending</p>
                            <h2 className="text-2xl font-bold text-yellow-500">5</h2>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-green-100 text-green-600">
                            <CheckCircle size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Approved</p>
                            <h2 className="text-2xl font-bold text-green-500">20</h2>
                        </div>
                    </div>
                </div>

                <div className="bg-white p-4 rounded-xl shadow mb-6">
                    <div className="flex justify-between items-center mb-4">
                        <h3 className="text-lg font-semibold">Kategori</h3>

                        <button className="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded-lg text-sm" onClick={() => setShowModal(true)}>
                            + Tambah
                        </button>
                    </div>

                    <div className="flex flex-wrap gap-2">
                        <span className="px-3 py-1 bg-orange-100 text-orange-600 text-xs rounded-full">
                            Diet
                        </span>
                        <span className="px-3 py-1 bg-blue-100 text-blue-600 text-xs rounded-full">
                            Tinggi Protein
                        </span>
                        <span className="px-3 py-1 bg-yellow-100 text-yellow-600 text-xs rounded-full">
                            Rendah Kalori
                        </span>
                        <span className="px-3 py-1 bg-purple-100 text-purple-600 text-xs rounded-full">
                            Minuman
                        </span>
                    </div>
                </div>

                {showModal && (

                    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50">

                        <div className="bg-white w-full max-w-sm rounded-xl shadow-lg p-5">

                            <h2 className="text-lg font-semibold mb-4">Tambah Kategori</h2>

                            <input
                                type="text"
                                placeholder="Nama kategori..."
                                className="w-full border border-gray-300 rounded-lg px-3 py-2 mb-4"
                            />

                            <div className="flex justify-end gap-2">
                                <button className="px-3 py-1 bg-gray-100 rounded" onClick={() => setShowModal(false)}>
                                    Batal
                                </button>

                                <button className="px-3 py-1 bg-orange-500 text-white rounded" onClick={() => setShowModal(false)}>
                                    Simpan
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}