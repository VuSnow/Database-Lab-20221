import {Box, Typography, useTheme} from "@mui/material"
import { DataGrid, GridToolbar} from "@mui/x-data-grid"
import { tokens } from "../../theme"
import { mockDataStaffs } from "../../data/mockData"
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import LockOpenOutlinedIcon from "@mui/icons-material/LockOpenOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import Header from "../../components/Header";


const Staff = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    
    const columms = [
        {
            field: "id", 
            headerName: "ID",
            headerAlign: "center",
            align: "center",
            flex: 0.3,
        },
        {
            field: "username", 
            headerName: "User Name",
            flex: 2,
            cellClassName: "name-column--cell",
            headerAlign: "center",
            align: "center",
        },
        {
            field: "password", 
            headerName: "Password",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "full_name", 
            headerName: "Full Name",
            headerAlign: "center",
            align: "center",
            flex: 1.5,
        },
        {
            field: "dob", 
            headerName: "Date of Birth",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "gender", 
            headerName: "Gender",
            flex: 1,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "phone", 
            headerName: "Phone",
            headerAlign: "center",
            align: "center",
            flex: 1,
        },
        {
            field: "email", 
            headerName: "Email",
            flex: 1,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "address", 
            headerName: "Address",
            flex: 1,

        },
        {
            field: "working_status", 
            headerName: "Working Status",
            flex: 1,
            headerAlign: "center",
            align: "center",
        },
        {
            field: "permissions", 
            headerName: "Permission",
            flex: 1,
            headerAlign: "center",
            align: "center",
            returnCell: ({row: {permissions}}) => {
                return (
                    <Box
                        width="60%"
                        m = "0 auto"
                        p = "5px"
                        display="flex"
                        justifyContent="center"
                        backgroundColor={
                            permissions === "admin" 
                                ? colors.greenAccent[600]
                                : colors.greenAccent[700]
                        }
                        borderRadius="4px"
                    >
                        {permissions === "admin" && <AdminPanelSettingsOutlinedIcon/>}
                        {permissions === "staff" && <LockOpenOutlinedIcon/>}
                        <Typography color={colors.grey[100]} sx={{ml: "0px"}}>
                            {permissions}
                        </Typography>
                    </Box>
                );
            },
        },
    ];

    return(
        <Box m="20px">
            <Header title="STAFFS" subtitle="Manage the Staff Member" />
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
                    rows={mockDataStaffs}
                    columns={columms}
                    components={{Toolbar: GridToolbar}}
                    // getRowId={(row: any) => row.id}
                />
            </Box>
        </Box>
    )
};

export default Staff;