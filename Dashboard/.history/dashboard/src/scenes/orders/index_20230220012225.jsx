import {Box, Modal, Typography, useTheme} from "@mui/material"
import { DataGrid, GridToolbar} from "@mui/x-data-grid"
import { tokens } from "../../theme"
import { mockDataOrders } from "../../data/mockData"
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import LockOpenOutlinedIcon from "@mui/icons-material/LockOpenOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import Header from "../../components/Header";
import Button from '@mui/material/Button';
import { mockDataOrderlines } from "../../data/mockData";
import { color } from "@mui/system";
import { useState } from "react";


const Orders = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const [open, setOpen] = useState(false);
    const handleOpen = () => setOpen(true);
    const handleClose = () => setOpen(false);
    const style = {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: 400,
        bgcolor: 'background.paper',
        border: '2px solid #000',
        boxShadow: 24,
        p: 4,
    };
    
    const columnsOrderlines = [
        {
            field: "order_id",
            headerName: "Order ID",
        },
        {
            field: "product_id",
            headerName: "Product ID",
        },
        {
            field: "product_name",
            headerName: "Product Name",
        },
        {
            field: "quantity",
            headerName: "Quantity",
        },
        {
            field: "total_amount",
            headerName: "Subtotal",
        }
    ];

    const columnsOrders = [
        {
            field: "order_id", 
            headerName: "Order ID",
            headerAlign: "center",
            align: "center",
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
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "staff_id", 
            headerName: "Staff ID",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "discount", 
            headerName: "Discount",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "total_amount", 
            headerName: "Total",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "point",
            headerName: "Point",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "payment_type",
            headerName: "Payment Type",
            headerAlign: "center",
            align: "center",
            flex: 0.6,
        },
        {
            field: "DETAILS",
            headerName: "DETAILS",
            align: "center",
            headerAlign: "center",
            renderCell: () => {
                return (
                    <Box
                        width="100%"
                        m="0 auto"
                        p="5px"
                        display="flex"
                        justifyContent="center"
                        borderRadius="4px"
                        backgroundColor="red"
                        color={colors.greenAccent[500]} 
                    >
                        <Button onClick={handleOpen}>More Details</Button>
                        <Modal
                            open={open}
                            onClose={handleClose}
                            aria-labelledby="modal-modal-title"
                            aria-describedby="modal-modal-description"
                            >
                            <Box sx={style}>
                                <Typography id="modal-modal-title" variant="h6" component="h2">
                                ORDERLINES
                                </Typography>
                                <Typography id="modal-modal-description" sx={{ mt: 2 }} height="75vh">
                                    <DataGrid 
                                        rows={mockDataOrderlines}
                                        columns={columnsOrderlines}
                                        getRowId={(row) => row.order_id + row.product_id}
                                    />
                                </Typography>
                            </Box>
                        </Modal>      
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
                    columns={columnsOrders}
                    components={{Toolbar: GridToolbar}}
                    getRowId={(row) => row.order_id}
                />
            </Box>
        </Box>
    )
};

export default Orders;