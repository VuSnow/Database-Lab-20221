import {Box, Typography, useTheme} from "@mui/material"
import { DataGrid, GridToolbar} from "@mui/x-data-grid"
import { tokens } from "../../theme"
import { mockDataOrders } from "../../data/mockData"
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import LockOpenOutlinedIcon from "@mui/icons-material/LockOpenOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import Header from "../../components/Header";
import Button from '@mui/material/Button';
import { color } from "@mui/system";


const Orders = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    
    const columms = [
        {
            field: "order_id", 
            headerName: "Order ID",
            flex: 0.5,
        },
        {
            field: "customer_name", 
            headerName: "Customer Name",
            flex: 1,
            cellClassName: "name-column--cell",
        },
        {
            field: "order_date", 
            headerName: "Order Date",
            flex: 1,
        },
        {
            field: "staff_id", 
            headerName: "Staff ID",
            flex: 1,
        },
        {
            field: "discount", 
            headerName: "Discount",
            flex: 1,
        },
        {
            field: "total_amount", 
            headerName: "Total",
            flex: 1,
        },
        {
            field: "point",
            headerName: "Point",
            flex: 0.5,
        },
        {
            field: "payment_type",
            headerName: "Payment Type",
            flex: 0.6,
        },
        {
            field: "DETAILS",
            headerName: "DETAILS",
            renderCell: () => {
                return (
                    <Box
                        width="60%"
                        m="0 auto"
                        p="5px"
                        display="flex"
                        justifyContent="center"
                        borderRadius="4px"
                    >
                        <Typography color={colors.greenAccent[500]} sx={{ml:"5px"}}>
                            <Button color="white">More Details</Button>
                        </Typography>
                    </Box>
                );
            }
        }
    ];

    return(
        <Box m="20px">
            <Header title="Orders" subtitle="Manage Orders" />
            <Box
                m="40px 0 0 0"
                height="75vh"
                sx={{
                "& .MuiDataGrid-root": {
                    border: "none",
                },
                "& .MuiDataGrid-cell": {
                    borderBottom: "none",
                },
                "& .name-column--cell": {
                    color: colors.greenAccent[300],
                },
                "& .MuiDataGrid-columnHeaders": {
                    backgroundColor: colors.blueAccent[700],
                    borderBottom: "none",
                },
                "& .MuiDataGrid-virtualScroller": {
                    backgroundColor: colors.primary[400],
                },
                "& .MuiDataGrid-footerContainer": {
                    borderTop: "none",
                    backgroundColor: colors.blueAccent[700],
                },
                "& .MuiCheckbox-root": {
                    color: `${colors.greenAccent[200]} !important`,
                },
                "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
                    color: `${colors.grey[100]} !important`,
                },
                }}
            >
                <DataGrid
                    rows={mockDataOrders}
                    columns={columms}
                    components={{Toolbar: GridToolbar}}
                    getRowId={(row) => row.order_id}
                />
            </Box>
        </Box>
    )
};

export default Orders;