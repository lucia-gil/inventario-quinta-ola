package org.quintaola;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

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

            // Create statement
            Statement stmt = conn.createStatement();

            // Execute query
            ResultSet rs = stmt.executeQuery(
                    "SELECT i.id, i.name, i.cached_quantity, i.status, GROUP_CONCAT(t.name) AS tags FROM items i LEFT JOIN item_tags it ON it.item_id = i.id LEFT JOIN tags t ON t.id = it.tag_id GROUP BY i.id, i.name, i.cached_quantity, i.status;");

            // Read results
            while (rs.next()) {
                String id = rs.getString("id");
                String name = rs.getString("name");
                Object tags = rs.getObject("tags");

                System.out.println(id + " " + name + " " + tags.toString());
            }

            // Close
            rs.close();
            stmt.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
