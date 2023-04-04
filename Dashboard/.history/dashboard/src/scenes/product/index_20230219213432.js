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
            flex: 1,
        },
        {
            field: "name", 
            headerName: "Product Name",
            flex: 2,
            cellClassName: "name-column--cell",
        },
        {
            field: "size", 
            headerName: "Size",
            flex: 0.5,
        },
        {
            field: "color", 
            headerName: "Color",
            flex: 0.8,
        },
        {
            field: "sale_price", 
            headerName: "Sale Price",
            flex: 1,
        },
        {
            field: "quan_in_stock", 
            headerName: "Quantity in Stock",
            flex: 1,
        },
        {
            field: "description",
            headerName: "Description",
            flex: 4,
        }
    ];

    return(
        <Box m="20px">
            <Header title="ProductS" subtitle="Manage the Product Member" />
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