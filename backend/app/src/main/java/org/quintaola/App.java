package org.quintaola;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import org.quintaola.dao.ItemDAO;
import org.quintaola.dao.UserDAO;

public class App {
    public String getGreeting() {
        return "Hello World!";
    }

    public static void main(String[] args) {

        System.out.println(new App().getGreeting());
        String url = "jdbc:mysql://localhost:3306/inventario_db";
        String user = "root";
        String password = "admin123";

        try {
            // Connect to DB
            Connection conn = DriverManager.getConnection(url, user, password);

            ItemDAO itemDAO = new ItemDAO(conn);
            ResultSet rs = itemDAO.getAverageConsumptionPerDay();

            while (rs.next()) {
                String name = rs.getString("name");
                Integer avd_daily_out = rs.getInt("avg_daily_out");

                System.out.println(name + ": " + avd_daily_out);
            }
            rs.close();

            UserDAO userDAO = new UserDAO(conn);
            rs = userDAO.getUsersWithHighestApprovalSuccessRate();

            while (rs.next()) {
                String name = rs.getString("name");
                Float succ_rate = rs.getFloat("success_rate");

                System.out.println(name + ": " + succ_rate);
            }
            rs.close();

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
