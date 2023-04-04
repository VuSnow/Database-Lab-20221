import {Box, Typography, useTheme} from "@mui/material"
import { DataGrid } from "@mui/x-data-grid"
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
        {field: "username", headerName: "User Name"},
        {field: "password", headerName: "Password"},
        {field: "manager_id", headerName: "Manager ID"},
        {field: "full_name", headerName: "Full Name"},
        {field: "dob", headerName: "Date of Birth"},
        {field: "gender", headerName: "Gender"},
        {field: "phone", headerName: "Phone"},
        {field: "email", headerName: "Email"},
        {field: "address", headerName: "Address"},
        {field: "working_status", headerName: "Working Status"},
        {field: "permission", headerName: "Permission"}
    ];

    return(
        <Box>
            <Header title="STAFFS" subtitle="Manage the Staff Member" />
            <Box>
                <DataGrid 
                    rows={mockDataStaffs}
                    columns={columms}
                />
            </Box>
        </Box>
    )
};

export default Staff;