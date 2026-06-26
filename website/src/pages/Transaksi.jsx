import Sidebar from "../components/Sidebar";
import { useState, useEffect } from "react";
import axios from "axios";
import { toast } from "react-toastify";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

export default function Transaksi() {

    const [search, setSearch] = useState("");

    const [transaksi, setTransaksi] = useState([]);

    const [selectedTransaksi, setSelectedTransaksi] = useState(null);

    const [showDetail, setShowDetail] = useState(false);

    const [showLaporan, setShowLaporan] = useState(false);


    const [filterLaporan, setFilterLaporan] = useState({

        tanggal_mulai:"",
        tanggal_selesai:"",
        status_transaksi:"",
        metode_transaksi:""

    });

    const getTransaksi = async () => {

        try {

            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/transaksi",
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            setTransaksi(response.data.data);


        } catch(error){

            console.log(error);

        }

    };

    useEffect(()=>{

        getTransaksi();

    },[]);

    const hapusTransaksi = async (id)=>{

        try{

            await axios.delete(
                `http://127.0.0.1:8000/api/admin/transaksi/${id}`,
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            toast.success(
                "Transaksi berhasil dihapus"
            );


            getTransaksi();


        }catch(error){

            toast.error(
                "Gagal menghapus transaksi"
            );

            console.log(error);

        }

    };

    const cetakLaporan = async () => {
        try {
            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/laporan-transaksi",
                {
                    params: filterLaporan,
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem("token")}`,
                    },
                }
            );

            const orders = response.data.data;

            const doc = new jsPDF();

            let totalSemua = 0;
            let totalAdmin = 0;
            let totalItem = 0;

            doc.text("Laporan Transaksi", 14, 15);

            doc.text(
                `Periode: ${filterLaporan.tanggal_mulai || "-"} s/d ${filterLaporan.tanggal_selesai || "-"}`,
                14,
                22
            );

            let y = 30;

            orders.forEach((trx, index) => {
                const subtotalTransaksi = trx.total_harga || 0;
                const admin = trx.biaya_admin || 0;
                const jumlahItem = trx.jumlah_item || 0;
                const ongkir = trx.ongkir;

                totalSemua += subtotalTransaksi;
                totalAdmin += admin;
                totalItem += jumlahItem;

                doc.setFontSize(11);
                doc.text(
                    `${index + 1}. ${trx.external_id} - ${trx.user.username}`,
                    14,
                    y
                );

                doc.setFontSize(10);
                doc.text(
                    `Status: ${trx.status_transaksi} | Order: ${trx.status_order} | Metode: ${trx.metode_transaksi}`,
                    14,
                    y + 6
                );

                doc.text(
                    `Total: Rp ${subtotalTransaksi.toLocaleString()} | Admin: Rp ${admin.toLocaleString()} | Item: ${jumlahItem} | Ongkir: ${ongkir}`,
                    14,
                    y + 12
                );

                y += 18;

                autoTable(doc, {
                    startY: y,
                    head: [["Makanan", "Toko", "Harga", "Qty", "Subtotal"]],
                    body: trx.order_items.map((item) => [
                        item.makanan.nama_makanan,
                        item.makanan.seller.nama_toko,
                        item.makanan.harga.toLocaleString(),
                        item.jumlah,
                        (item.makanan.harga * item.jumlah).toLocaleString(),
                    ]),
                    theme: "grid",
                    styles: { fontSize: 9 },
                });

                y = doc.lastAutoTable.finalY + 10;

                if (y > 260) {
                    doc.addPage();
                    y = 20;
                }
            });

            doc.addPage();

            doc.setFontSize(14);
            doc.text("Ringkasan Laporan", 14, 20);

            doc.setFontSize(11);

            doc.text(
                `Total Semua Transaksi: Rp ${totalSemua.toLocaleString()}`,
                14,
                35
            );

            doc.text(
                `Total Biaya Admin: Rp ${totalAdmin.toLocaleString()}`,
                14,
                45
            );

            doc.text(
                `Total Item Terjual: ${totalItem}`,
                14,
                55
            );

            doc.text(
                `Jumlah Transaksi: ${orders.length}`,
                14,
                65
            );

            doc.save("laporan-transaksi-lengkap.pdf");

            toast.success("Laporan berhasil dibuat");
            setShowLaporan(false);

        } catch (error) {
            console.log(error);
            toast.error("Gagal membuat laporan");
        }
    };


    const filteredTransaksi = transaksi.filter((item)=>{

        const keyword = search.toLowerCase();


        return (
            item.user.username
                ?.toLowerCase()
                .includes(keyword)

            ||

            item.total_harga
                ?.toString()
                .includes(keyword)

            ||

            item.biaya_admin
                ?.toString()
                .includes(keyword)

            ||

            item.jumlah_item
                ?.toString()
                .includes(keyword)

            ||

            item.external_id
                ?.toLowerCase()
                .includes(keyword)

            ||

            item.status_transaksi
                ?.toLowerCase()
                .includes(keyword)

            ||

            item.status_order
                ?.toLowerCase()
                .includes(keyword)

            ||

            item.metode_transaksi
                ?.toLowerCase()
                .includes(keyword)

            ||

            item.tanggal_transaksi
                ?.toLowerCase()
                .includes(keyword)
            ||
            
            item.ongkir
                ?.toLowerCase()
                .includes(keyword)
        );

    });


    const [currentPage,setCurrentPage] = useState(1);

    const itemsPerPage = 10;

    const lastIndex = currentPage * itemsPerPage;
    const firstIndex = lastIndex - itemsPerPage;


    const currentItems = filteredTransaksi.slice(
        firstIndex,
        lastIndex
    );


    const totalPages = Math.ceil(
        filteredTransaksi.length / itemsPerPage
    );


    return (

        <div className="flex bg-gray-100 min-h-screen">

            <Sidebar/>


            <div className="flex-1 p-6">


                <div className="flex justify-between items-center mb-6">

                    <h2 className="text-2xl font-semibold">
                        Transaksi
                    </h2>

                    <button
                        onClick={()=>setShowLaporan(true)}
                        className="bg-orange-500 text-white px-4 py-2 rounded-lg"
                    >
                        Cetak Laporan
                    </button>

                </div>



                <div className="mb-4">

                    <input
                        type="text"
                        placeholder="Cari transaksi..."
                        className="w-full md:w-1/3 bg-white border border-gray-300 rounded-lg px-4 py-2 shadow-sm focus:outline-none focus:ring-2 focus:ring-orange-200"
                        value={search}
                        onChange={(e)=>setSearch(e.target.value)}
                    />

                </div>



                <div className="bg-white rounded-xl shadow overflow-hidden">


                    <table className="w-full text-sm">


                        <thead className="bg-orange-100 text-orange-600 uppercase text-xs">

                            <tr>

                                <th className="p-3 text-center">
                                    No
                                </th>
                                <th className="p-3 text-left">
                                    Nama User
                                </th> 

                                <th className="p-3 text-left">
                                    Total Harga
                                </th>

                                <th className="p-3 text-center">
                                    Biaya Admin
                                </th>

                                <th className="p-3 text-center">
                                    Ongkir
                                </th>

                                <th className="p-3 text-center">
                                    Jumlah Item
                                </th>

                                <th className="p-3 text-left">
                                    Kode Pemesanan
                                </th>

                                <th className="p-3 text-center">
                                    Status Transaksi
                                </th>

                                <th className="p-3 text-center">
                                    Status Order
                                </th>

                                <th className="p-3 text-center">
                                    Metode
                                </th>

                                <th className="p-3 text-center">
                                    Tanggal Transaksi
                                </th>

                                <th className="p-3 text-center">
                                    Aksi
                                </th>

                            </tr>

                        </thead>



                        <tbody className="text-gray-700">


                        {
                            currentItems.map((item,index)=>(

                                <tr
                                    key={item.id}
                                    className="border-t hover:bg-gray-50"
                                >


                                    <td className="p-3 text-center">
                                        {firstIndex + index + 1}
                                    </td>


                                    <td className="p-3">
                                        {item.user.username}
                                    </td>


                                    <td className="p-3">
                                        {item.total_harga}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.biaya_admin}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.ongkir}
                                    </td>

                                    <td className="p-3 text-center">
                                        {item.jumlah_item}
                                    </td>


                                    <td className="p-3">
                                        {item.external_id}
                                    </td>


                                    <td className="p-3 text-center">

                                        <span
                                            className={`
                                            px-2 py-1 rounded text-xs
                                            ${
                                                item.status_transaksi === "dibayar"
                                                ?
                                                "bg-green-100 text-green-600"
                                                :
                                                item.status_transaksi === "belum_bayar"
                                                ?
                                                "bg-yellow-100 text-yellow-600"
                                                :
                                                "bg-red-100 text-red-600"
                                            }
                                            `}
                                        >

                                            {item.status_transaksi}

                                        </span>

                                    </td>


                                    <td className="p-3 text-center">

                                        {item.status_order}

                                    </td>


                                    <td className="p-3 text-center">

                                        {item.metode_transaksi}

                                    </td>


                                    <td className="p-3 text-center">

                                        {item.tanggal_transaksi}

                                    </td>

                                    <td className="p-3">

                                    <div className="flex justify-center gap-2">


                                        <button
                                            className="px-3 py-1 text-xs bg-blue-500 text-white rounded"
                                            onClick={()=>{

                                                setSelectedTransaksi(item);
                                                setShowDetail(true);

                                            }}
                                        >
                                            Detail
                                        </button>


                                        <button
                                            className="px-3 py-1 text-xs bg-red-500 text-white rounded"
                                             onClick={()=>hapusTransaksi(item.id)}
                                        >
                                            Hapus
                                        </button>


                                    </div>

                                </td>

                                    
                                </tr>


                            ))
                        }


                        </tbody>



                    </table>



                    <div className="flex justify-center items-center gap-2 mt-4 pb-4">


                        <button
                            onClick={()=>setCurrentPage(currentPage-1)}
                            disabled={currentPage===1}
                            className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50"
                        >
                            Prev
                        </button>



                        {
                            [...Array(totalPages)].map((_,index)=>(

                                <button
                                    key={index}
                                    onClick={()=>setCurrentPage(index+1)}
                                    className={`
                                    px-3 py-1 rounded
                                    ${
                                        currentPage===index+1
                                        ?
                                        "bg-orange-500 text-white"
                                        :
                                        "bg-gray-200"
                                    }
                                    `}
                                >

                                    {index+1}

                                </button>


                            ))
                        }



                        <button
                            onClick={()=>setCurrentPage(currentPage+1)}
                            disabled={currentPage===totalPages}
                            className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50"
                        >

                            Next

                        </button>



                    </div>


                </div>


            </div>

            {
                showDetail && selectedTransaksi && (

                <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">


                    <div className="bg-white w-full max-w-3xl rounded-xl shadow-lg p-6 max-h-[90vh] overflow-y-auto">


                        <div className="flex justify-between items-center mb-5 border-b pb-3">


                            <h2 className="text-xl font-semibold">
                                Detail Transaksi
                            </h2>


                            <button
                                onClick={()=>setShowDetail(false)}
                                className="text-gray-500"
                            >
                                ✕
                            </button>


                        </div>



                        <div className="grid grid-cols-2 gap-4 text-sm mb-6">


                            <div>
                                <p className="text-gray-500">
                                    Kode Transaksi
                                </p>

                                <p className="font-medium">
                                    {selectedTransaksi.external_id}
                                </p>
                            </div>



                            <div>
                                <p className="text-gray-500">
                                    Pembeli
                                </p>

                                <p className="font-medium">
                                    {selectedTransaksi.user.username}
                                </p>
                            </div>



                            <div>
                                <p className="text-gray-500">
                                    Total Harga
                                </p>

                                <p className="font-medium">
                                    Rp {selectedTransaksi.total_harga.toLocaleString()}
                                </p>
                            </div>



                            <div>
                                <p className="text-gray-500">
                                    Biaya Admin
                                </p>

                                <p className="font-medium">
                                    Rp {selectedTransaksi.biaya_admin?.toLocaleString()}
                                </p>
                            </div>

                            <div>
                                <p className="text-gray-500">
                                    Ongkir
                                </p>

                                <p className="font-medium">
                                    Rp {selectedTransaksi.ongkir}
                                </p>
                            </div>

                            <div>
                                <p className="text-gray-500">
                                    Status Transaksi
                                </p>

                                <p className="font-medium">
                                    {selectedTransaksi.status_transaksi}
                                </p>
                            </div>



                            <div>
                                <p className="text-gray-500">
                                    Metode Pembayaran
                                </p>

                                <p className="font-medium">
                                    {selectedTransaksi.metode_transaksi}
                                </p>
                            </div>


                        </div>





                        <h3 className="font-semibold mb-3">
                            Detail Pesanan
                        </h3>



                        <div className="space-y-3">


                        {
                            selectedTransaksi.order_items.map((item,index)=>(

                                <div
                                    key={index}
                                    className="border rounded-lg p-4"
                                >


                                    <div className="flex justify-between">


                                        <div>


                                            <p className="font-medium">
                                                {item.makanan.nama_makanan}
                                            </p>


                                            <p className="text-sm text-gray-500">
                                                Toko :
                                                {" "}
                                                {item.makanan.seller.nama_toko}
                                            </p>


                                        </div>



                                        <div className="text-right">


                                            <p>
                                                Jumlah :
                                                {" "}
                                                {item.jumlah}
                                            </p>


                                            <p>
                                                Harga :
                                                Rp {item.makanan.harga.toLocaleString()}
                                            </p>


                                        </div>


                                    </div>



                                </div>


                            ))
                        }


                        </div>



                        <div className="mt-6 text-right">


                            <button
                                onClick={()=>setShowDetail(false)}
                                className="px-4 py-2 bg-gray-200 rounded-lg"
                            >
                                Tutup
                            </button>


                        </div>



                    </div>


                </div>

                )
                }

                {
                    showLaporan && (

                        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">


                            <div className="bg-white rounded-xl p-6 w-full max-w-lg">


                                <h2 className="text-xl font-semibold mb-5">
                                    Filter Laporan Transaksi
                                </h2>



                                <div className="space-y-4">

                                     <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Tanggal Mulai
                                    </label>
                                    <input
                                        type="date"
                                        className="w-full border p-2 rounded"
                                        value={filterLaporan.tanggal_mulai}
                                        onChange={(e) =>
                                            setFilterLaporan({
                                                ...filterLaporan,
                                                tanggal_mulai: e.target.value
                                            })
                                        }
                                    />


                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Tanggal Selesai
                                    </label>   
                                    <input
                                        type="date"
                                        className="w-full border p-2 rounded"
                                        value={filterLaporan.tanggal_selesai}
                                        onChange={(e) =>
                                            setFilterLaporan({
                                                ...filterLaporan,
                                                tanggal_selesai: e.target.value
                                            })
                                        }
                                    />


                                     <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Status Transaksi
                                    </label>       
                                    <select
                                        className="w-full border p-2 rounded"
                                        value={filterLaporan.status_transaksi}
                                        onChange={(e) =>
                                            setFilterLaporan({
                                                ...filterLaporan,
                                                status_transaksi: e.target.value
                                            })
                                        }
                                    >

                                        <option value="">
                                            Semua Status
                                        </option>


                                        <option value="dibayar">
                                            Dibayar
                                        </option>


                                        <option value="belumBayar">
                                            Belum Bayar
                                        </option>


                                        <option value="gagal">
                                            Gagal
                                        </option>


                                    </select>
                                </div>





                                <div className="flex justify-end gap-3 mt-6">


                                    <button
                                        onClick={() => setShowLaporan(false)}
                                        className="px-4 py-2 bg-gray-200 rounded"
                                    >
                                        Batal
                                    </button>



                                    <button
                                        className="px-4 py-2 bg-red-500 text-white rounded"
                                        onClick={cetakLaporan}
                                    >
                                        Cetak PDF
                                    </button>


                                </div>


                            </div>


                        </div>

                    )
                }
        </div>

    );

}