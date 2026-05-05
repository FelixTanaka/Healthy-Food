import Sidebar from "../components/Sidebar";
import { useState } from "react";

export default function Makanan() {
    const [showModal, setShowModal] = useState(false);

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

                            <tr className="border-t hover:bg-gray-50 transition">
                                <td className="p-3 text-center">1</td>
                                <td className="p-3 font-medium">Nasi Ayam</td>
                                <td className="p-3 font-medium">Diet</td>
                                <td className="p-3">Rp 25.000</td>
                                <td className="p-3">Warung Budi</td>
                                <td className="p-3 text-center">20g</td>
                                <td className="p-3 text-center">40g</td>
                                <td className="p-3 text-center">10g</td>
                                <td className="p-3 text-center">350 kcal</td>
                                <td className="p-3 text-center">Approved</td>
                                <td className="p-3">
                                <div className="flex justify-center gap-2">
                                    <button className="px-3 py-1 text-xs bg-blue-500 hover:bg-blue-600 text-white rounded" onClick={() => setShowModal(true)}>
                                        Detail
                                    </button>
                                    <button className="px-3 py-1 text-xs bg-red-500 hover:bg-red-600 text-white rounded">
                                        Hapus
                                    </button>
                                </div>
                                </td>
                            </tr>

                            <tr className="border-t hover:bg-gray-50 transition">
                                <td className="p-3 text-center">2</td>
                                <td className="p-3 font-medium">Salad Buah</td>
                                <td className="p-3 font-medium">Diet</td>
                                <td className="p-3">Rp 18.000</td>
                                <td className="p-3">Toko Siti</td>
                                <td className="p-3 text-center">5g</td>
                                <td className="p-3 text-center">30g</td>
                                <td className="p-3 text-center">2g</td>
                                <td className="p-3 text-center">150 kcal</td>
                                <td className="p-3 text-center">Approved</td>
                                <td className="p-3">
                                <div className="flex justify-center gap-2">
                                    <button className="px-3 py-1 text-xs bg-blue-500 hover:bg-blue-600 text-white rounded" onClick={() => setShowModal(true)}>
                                        Detail
                                    </button>
                                    <button className="px-3 py-1 text-xs bg-red-500 hover:bg-red-600 text-white rounded">
                                        Hapus
                                    </button>
                                </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
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
                                    src="https://images.unsplash.com/photo-1604908176997-431c8d4b7f34"
                                    alt="makanan"
                                    className="w-full h-48 object-cover rounded-xl shadow"
                                />

                                <div className="mt-3">
                                    <span className="px-3 py-1 text-xs rounded-full bg-green-100 text-green-600 font-medium">
                                        Approved
                                    </span>
                                </div>
                            </div>

                            <div className="w-2/3 flex flex-col justify-between">
                                <div className="space-y-3 text-sm text-gray-700">
                                    <div>
                                        <p className="text-gray-400">Nama</p>
                                        <p className="font-semibold text-lg">Nasi Ayam</p>

                                        <p className="text-sm text-gray-400 mt-1">Toko</p>
                                        <p className="text-sm font-medium text-gray-700">Warung Budi</p>
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Kategori</p>
                                        <p>Diet</p>
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Harga</p>
                                        <p className="text-orange-500 font-medium">Rp 25.000</p>
                                    </div>

                                    <div className="grid grid-cols-4 gap-3 mt-2">

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Kalori</p>
                                            <p className="font-semibold">350 kcal</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Protein</p>
                                            <p className="font-semibold">20g</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Karbo</p>
                                            <p className="font-semibold">40g</p>
                                        </div>

                                        <div className="bg-gray-100 rounded-lg p-3 text-center">
                                            <p className="text-xs text-gray-400">Lemak</p>
                                            <p className="font-semibold">10g</p>
                                        </div> 
                                    </div>

                                    <div>
                                        <p className="text-gray-400">Deskripsi</p>
                                        <p className="leading-relaxed">
                                            Nasi ayam sehat dengan protein tinggi, cocok untuk diet dan menjaga nutrisi harian.
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

                                    <button
                                        className="px-4 py-2 rounded-lg bg-orange-500 hover:bg-orange-600 text-white text-sm shadow-md"
                                    >
                                        Edit
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