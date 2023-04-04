import {Box, Typography, useTheme} from "@mui/material"
import { DataGrid, GridToolbar} from "@mui/x-data-grid"
import { tokens } from "../../theme"
import { mockDataProducts } from "../../data/mockData"
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import LockOpenOutlinedIcon from "@mui/icons-material/LockOpenOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import Header from "../../components/Header";


const Products = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    
    const columms = [
        {
            field: "product_id", 
            headerName: "Product ID",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "name", 
            headerName: "Product Name",
            flex: 1.7,
            headerAlign: "center",
            align: "center",
            cellClassName: "name-column--cell",
        },
        {
            field: "size", 
            headerName: "Size",
            flex: 0.5,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "color", 
            headerName: "Color",
            flex: 0.8,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "sale_price", 
            headerName: "Sale Price",
            flex: 1,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "quan_in_stock", 
            headerName: "IN STOCK",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "description",
            headerName: "Description",
            headerAlign: "center",
            flex: 6,
        }
    ];

    return(
        <Box m="20px">
            <Header title="Product" subtitle="Manage Products" />
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
                    rows={mockDataProducts}
                    columns={columms}
                    components={{Toolbar: GridToolbar}}
                    getRowId={(row) => row.product_id}
                />
            </Box>
        </Box>
    )
};

export default Products;