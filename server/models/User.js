import mongoose from "mongoose"
{/*Schema to input user in mongoDB*/}

const userSchema = new mongoose.Schema(
    {
        user_id:{
            type: String,
            require: true,
            unique: true,
        },
        name:{
            type: String,
            require: true,
            min: 2,
            max: 100,
        },
        email:{
            type: String,
            require: true,
            max: 50,
            unique: true,
        },
        password: {
            type: String,
            require: true,
            min: 8,
        },
        phoneNumber:{
            type: String,
            require: true,
        },
        city: String,
        state: String,
        country: String,
        occupation: String,
        transactions: Array,
        role: {
            type: String,
            enum: ["user", "admin", "superadmin"],
            default: "staff"
        },
    },
    { timestamps: true }
);

const User = mongoose.model("User", userSchema, 'UserInfo');
export default User;