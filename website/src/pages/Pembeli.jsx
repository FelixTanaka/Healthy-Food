import Sidebar from "../components/Sidebar";

export default function Pembeli() {
    return (
        <div className="flex bg-gray-100 min-h-screen">

            <Sidebar />

            <div className="flex-1 p-6">
                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-2xl font-semibold">Daftar Pembeli</h2>
                </div>

                <div className="mb-4">
                    <input
                        type="text"
                        placeholder="Cari Pembeli..."
                        className="w-full md:w-1/3 bg-white border border-gray-300 rounded-lg px-4 py-2 shadow-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-200"
                    />
                </div>

                <div className="bg-white rounded-xl shadow overflow-hidden">
                    <table className="w-full text-sm">
                        <thead className="bg-orange-100 text-orange-600 uppercase text-xs">
                            <tr>
                                <th className="p-3 text-center">No</th>
                                <th className="p-3 text-left">Nama</th>
                                <th className="p-3 text-left">Email</th>
                                <th className="p-3 text-left">No Telp</th>
                                <th className="p-3 text-center">Aksi</th>
                            </tr>
                        </thead>

                        <tbody className="text-gray-700">

                            <tr className="border-t hover:bg-gray-50 transition">
                                <td className="p-3 text-center">1</td>
                                <td className="p-3 font-medium">Budi Santoso</td>
                                <td className="p-3">budi@gmail.com</td>
                                <td className="p-3">081234567890</td>
                                <td className="p-3">
                                    <div className="flex justify-center gap-2">
                                        <button className="px-3 py-1 text-xs bg-blue-500 hover:bg-blue-600 text-white rounded">
                                            Edit
                                        </button>
                                        <button className="px-3 py-1 text-xs bg-red-500 hover:bg-red-600 text-white rounded">
                                            Hapus
                                        </button>
                                    </div>
                                </td>
                            </tr>

                            <tr className="border-t hover:bg-gray-50 transition">
                                <td className="p-3 text-center">2</td>
                                <td className="p-3 font-medium">Siti Aminah</td>
                                <td className="p-3">siti@gmail.com</td>
                                <td className="p-3">089876543210</td>
                                <td className="p-3">
                                    <div className="flex justify-center gap-2">
                                        <button className="px-3 py-1 text-xs bg-blue-500 hover:bg-blue-600 text-white rounded">
                                            Edit
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
        </div>
    );
}