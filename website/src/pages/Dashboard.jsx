import Sidebar from "../components/Sidebar";
import { useState, useEffect } from "react";
import { Users, Utensils, Store, DollarSign } from "lucide-react";
import axios from "axios";
import ChartDataLabels from "chartjs-plugin-datalabels";
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Tooltip,
    Legend,
    Filler,
    BarElement
} from "chart.js";

import { Line, Bar } from "react-chartjs-2";

ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Tooltip,
    Legend,
    ArcElement,
    ChartDataLabels,
    Filler,
    BarElement
);

import {
    Doughnut
} from "react-chartjs-2";


import {
    ArcElement
} from "chart.js";

export default function Dashboard() {

    const [grafikTransaksi, setGrafikTransaksi] = useState([]);

    const [statusTransaksi,setStatusTransaksi] = useState([]);

    const [pendapatanAdmin,setPendapatanAdmin] = useState([]);

    const [statistik,setStatistik] = useState({

        total_seller:0,
        total_pembeli:0,
        total_makanan:0,
        pendapatan_admin:0

    });

    const getGrafikTransaksi = async()=>{

        try{

            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/dashboard/transaksi-bulanan",
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            setGrafikTransaksi(response.data.data);


        }catch(error){

            console.log(error);

        }

    }

    const getStatusTransaksi = async()=>{

        try{

            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/dashboard/status-transaksi",
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            setStatusTransaksi(response.data.data);


        }catch(error){

            console.log(error);

        }

    }

    const getPendapatanAdmin = async()=>{

        try{

            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/dashboard/pendapatan-admin",
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            setPendapatanAdmin(response.data.data);


        }catch(error){

            console.log(error);

        }

    }

    const getStatistik = async()=>{

        try{

            const response = await axios.get(
                "http://127.0.0.1:8000/api/admin/dashboard/statistik",
                {
                    headers:{
                        Authorization:
                        `Bearer ${localStorage.getItem("token")}`
                    }
                }
            );


            setStatistik(
                response.data.data
            );


        }catch(error){

            console.log(error);

        }

    }


    useEffect(()=>{

        getGrafikTransaksi();
        getStatusTransaksi();
        getPendapatanAdmin();
        getStatistik();

    },[]);

    const dataChart = {

        labels: grafikTransaksi.map(
            item => item.nama_bulan
        ),

        datasets:[
            {
                label:"Jumlah Transaksi",

                data:grafikTransaksi.map(
                    item => item.jumlah
                ),

                tension:0.4,

                borderColor:"#f97316",

                backgroundColor:"rgba(249, 115, 22, 0.2)",

                pointBackgroundColor:"#ea580c",

                pointBorderColor:"#fff",

                pointRadius:5,

                fill:true
            }
        ]

    }


    const optionChart = {

        responsive:true,

        plugins:{
            legend:{
                display:true
            },
            datalabels:{
                display:false
            }
        }

    };

    const totalStatus = statusTransaksi.reduce(
        (total,item)=> total + item.jumlah,
        0
    );

    const doughnutData = {

        labels: statusTransaksi.map(
            item => item.status_transaksi
        ),

        datasets:[
            {
                data: statusTransaksi.map(
                    item => item.jumlah
                ),

                backgroundColor:[
                    "#22c55e",
                    "#eab308",
                    "#ef4444"
                ]
            }
        ]

    };

    const dataPendapatan = {

        labels:[
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "Mei",
            "Jun",
            "Jul",
            "Agu",
            "Sep",
            "Okt",
            "Nov",
            "Des"
        ],


        datasets:[
            {
                label:"Pendapatan Admin",

                data:pendapatanAdmin.map(
                    item=>item.total
                ),

                borderRadius:8,

                backgroundColor:"#4beb86",

                borderColor:"#16a34a",

                borderWidth:2,

                hoverBackgroundColor:"#34ed78"
            }

        ]

    };


    return (
        <div className="flex bg-gray-100 min-h-screen">

            <Sidebar />

            <div className="flex-1 p-6">

                <h2 className="text-2xl font-semibold mb-6">Dashboard</h2>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-blue-100 text-blue-600">
                            <Store size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Total Seller</p>
                            <h2 className="text-2xl font-bold text-blue-500">
                                {statistik.total_seller}
                            </h2>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">

                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-purple-100 text-purple-600">
                            <Users size={24}/>
                        </div>

                        <div>

                            <p className="text-gray-500 text-sm">
                                Total Pembeli
                            </p>

                            <h2 className="text-2xl font-bold text-purple-500">
                                {statistik.total_pembeli}
                            </h2>

                        </div>

                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">
                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-yellow-100 text-yellow-600">
                            <Utensils size={24} />
                        </div>
                        <div>
                            <p className="text-gray-500 text-sm">Total Makanan</p>
                            <h2 className="text-2xl font-bold text-orange-500">
                                {statistik.total_makanan}
                            </h2>
                        </div>
                    </div>

                    <div className="bg-white p-4 rounded-xl shadow flex items-center gap-4 hover:shadow-md transition">

                        <div className="w-12 h-12 flex items-center justify-center rounded-lg bg-green-100 text-green-600">

                            <DollarSign size={24}/>

                        </div>


                        <div>

                            <p className="text-gray-500 text-sm">
                                Pendapatan Admin
                            </p>


                            <h2 className="text-xl font-bold text-green-500">

                                Rp {statistik.pendapatan_admin.toLocaleString()}

                            </h2>

                        </div>


                    </div>
                </div>

                <div className="bg-white p-5 rounded-xl shadow mb-6">

                    <h3 className="text-lg font-semibold mb-4">
                        Grafik Transaksi Bulanan
                    </h3>


                     <div className="h-80">
                        <Line
                            data={dataChart}
                            options={{
                                ...optionChart,
                                maintainAspectRatio: false
                            }}
                        />
                    </div>

                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                    <div className="bg-white p-5 rounded-xl shadow">

                        <h3 className="text-lg font-semibold mb-4">
                            Status Transaksi
                        </h3>

                        <div className="w-72 mx-auto">

                            <Doughnut
                                data={doughnutData}
                                options={{

                                    plugins:{

                                        legend:{
                                            display:true,
                                            position:"right"
                                        },


                                        datalabels:{


                                            color:"#fff",

                                            font:{
                                                weight:"bold",
                                                size:14
                                            },


                                            formatter:(value)=>{

                                                if(totalStatus === 0){
                                                    return "0%";
                                                }


                                                return (
                                                    ((value / totalStatus) * 100)
                                                    .toFixed(1)
                                                    +"%"
                                                );

                                            }

                                        }

                                    }

                                }}
                            />

                        </div>

                    </div>

                    <div className="bg-white p-5 rounded-xl shadow">


                        <h3 className="text-lg font-semibold mb-4">
                            Pendapatan Admin Bulanan
                        </h3>


                        <div className="h-72">

                            <Bar
                                data={dataPendapatan}
                                options={{
                                    responsive:true,
                                    maintainAspectRatio:false,

                                    plugins:{
                                        legend:{
                                            display:true
                                        },
                                        datalabels:{
                                            color:"black",
                                        },
                                    }
                                }}
                            />

                        </div>


                    </div>

                </div>
            </div>
        </div>
    );
}