import { renderLayout } from "./layout";

const content = document.getElementById("content").innerHTML

document.getElementById("content").innerHTML = renderLayout(
    "Solicitudes",
    content,
    "admin-requests"
);