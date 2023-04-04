import {Box, Typography, useTheme} from "@mui/material"
import { DataGrid, GridToolbar} from "@mui/x-data-grid"
import { tokens } from "../../theme"
import { mockDataCustomers } from "../../data/mockData"
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import LockOpenOutlinedIcon from "@mui/icons-material/LockOpenOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import Header from "../../components/Header";


const Customers = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    
    const columms = [
        {
            field: "phone", 
            headerName: "Phone Number",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "full_name", 
            headerName: "Full Name",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "dob", 
            headerName: "Date of Birth",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "gender", 
            headerName: "Gender",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "email", 
            headerName: "Email",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "address", 
            headerName: "Address",
            headerAlign: "center",
            align: "center",
            flex: 1,

        },
        {
            field: "point",
            headerName: "Point",
            type: "number",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        },
        {
            field: "member_type",
            headerName: "Member Type",
            headerAlign: "center",
            align: "center",
            flex: 0.5,
        }
    ];

    return(
        <Box m="20px">
            <Header title="Customers" subtitle="Manage the Customers" />
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
                    rows={mockDataCustomers}
                    columns={columms}
                    components={{Toolbar: GridToolbar}}
                    getRowId={(row) => row.phone}
                />
            </Box>
        </Box>
    )
};

export default Customers;